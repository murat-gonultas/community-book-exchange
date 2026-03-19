package com.murat.book_exchange_api.service;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.response.BookResponse;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.BookOwnership;
import com.murat.book_exchange_api.domain.community.Community;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.BookOwnershipRepository;
import com.murat.book_exchange_api.repository.BookRepository;
import com.murat.book_exchange_api.repository.CommunityRepository;
import com.murat.book_exchange_api.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;
    private final BookOwnershipRepository bookOwnershipRepository;
    private final BookHoldingRepository bookHoldingRepository;
    private final UserRepository userRepository;
    private final CommunityRepository communityRepository;

    @Transactional
    public BookResponse createBook(CreateBookRequest request) {
        User ownerUser = null;
        Community ownerCommunity = null;

        if (request.getOwnershipType() == OwnershipType.USER) {
            if (request.getOwnerUserId() == null) {
                throw new IllegalArgumentException("ownerUserId is required when ownershipType is USER");
            }
            ownerUser = userRepository.findById(request.getOwnerUserId())
                    .orElseThrow(() -> new EntityNotFoundException("User not found: " + request.getOwnerUserId()));
        }

        if (request.getOwnershipType() == OwnershipType.COMMUNITY) {
            if (request.getOwnerCommunityId() == null) {
                throw new IllegalArgumentException("ownerCommunityId is required when ownershipType is COMMUNITY");
            }
            ownerCommunity = communityRepository.findById(request.getOwnerCommunityId())
                    .orElseThrow(() -> new EntityNotFoundException("Community not found: " + request.getOwnerCommunityId()));
        }

        Book book = Book.builder()
                .title(request.getTitle())
                .author(request.getAuthor())
                .isbn(request.getIsbn())
                .language(request.getLanguage())
                .category(request.getCategory())
                .condition(request.getCondition())
                .notes(request.getNotes())
                .build();

        Book savedBook = bookRepository.save(book);

        BookOwnership ownership = BookOwnership.builder()
                .book(savedBook)
                .ownershipType(request.getOwnershipType())
                .ownerUser(ownerUser)
                .ownerCommunity(ownerCommunity)
                .ownershipAcquiredAt(Instant.now())
                .build();

        bookOwnershipRepository.save(ownership);

        BookHolding holding = BookHolding.builder()
                .book(savedBook)
                .currentHolderUser(ownerUser)
                .currentShelf(null)
                .status(BookStatus.AVAILABLE)
                .loanStartAt(null)
                .dueAt(null)
                .reservedUntil(null)
                .build();

        bookHoldingRepository.save(holding);

        return BookResponse.builder()
                .bookId(savedBook.getId())
                .title(savedBook.getTitle())
                .author(savedBook.getAuthor())
                .isbn(savedBook.getIsbn())
                .ownershipType(ownership.getOwnershipType())
                .ownerUserId(ownerUser != null ? ownerUser.getId() : null)
                .ownerCommunityId(ownerCommunity != null ? ownerCommunity.getId() : null)
                .currentHolderUserId(holding.getCurrentHolderUser() != null ? holding.getCurrentHolderUser().getId() : null)
                .currentShelfId(null)
                .status(holding.getStatus())
                .build();
    }
}