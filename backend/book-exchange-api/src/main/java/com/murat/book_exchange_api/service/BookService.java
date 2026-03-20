package com.murat.book_exchange_api.service;

import java.time.Instant;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.request.GiftBookRequest;
import com.murat.book_exchange_api.controller.request.LoanBookRequest;
import com.murat.book_exchange_api.controller.request.ReserveBookRequest;
import com.murat.book_exchange_api.controller.request.ReturnBookRequest;
import com.murat.book_exchange_api.controller.response.BookDetailResponse;
import com.murat.book_exchange_api.controller.response.BookResponse;
import com.murat.book_exchange_api.controller.response.BookTransactionResponse;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.BookOwnership;
import com.murat.book_exchange_api.domain.book.BookTransaction;
import com.murat.book_exchange_api.domain.community.Community;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
import com.murat.book_exchange_api.domain.enums.TransactionType;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.BookOwnershipRepository;
import com.murat.book_exchange_api.repository.BookRepository;
import com.murat.book_exchange_api.repository.BookTransactionRepository;
import com.murat.book_exchange_api.repository.CommunityRepository;
import com.murat.book_exchange_api.repository.UserRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BookService {

        private final BookRepository bookRepository;
        private final BookOwnershipRepository bookOwnershipRepository;
        private final BookHoldingRepository bookHoldingRepository;
        private final BookTransactionRepository bookTransactionRepository;
        private final UserRepository userRepository;
        private final CommunityRepository communityRepository;

        @Transactional
        public BookResponse createBook(CreateBookRequest request) {
                User ownerUser = null;
                Community ownerCommunity = null;

                if (request.getOwnershipType() == OwnershipType.USER) {
                        if (request.getOwnerUserId() == null) {
                                throw new IllegalArgumentException(
                                                "ownerUserId is required when ownershipType is USER");
                        }
                        ownerUser = userRepository.findById(request.getOwnerUserId())
                                        .orElseThrow(() -> new EntityNotFoundException(
                                                        "User not found: " + request.getOwnerUserId()));
                }

                if (request.getOwnershipType() == OwnershipType.COMMUNITY) {
                        if (request.getOwnerCommunityId() == null) {
                                throw new IllegalArgumentException(
                                                "ownerCommunityId is required when ownershipType is COMMUNITY");
                        }
                        ownerCommunity = communityRepository.findById(request.getOwnerCommunityId())
                                        .orElseThrow(
                                                        () -> new EntityNotFoundException("Community not found: "
                                                                        + request.getOwnerCommunityId()));
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
                                .reservedForUser(null)
                                .currentShelf(null)
                                .status(BookStatus.AVAILABLE)
                                .loanStartAt(null)
                                .dueAt(null)
                                .reservedUntil(null)
                                .build();

                bookHoldingRepository.save(holding);

                return mapToBookResponse(savedBook, ownership, holding);
        }

        @Transactional(readOnly = true)
        public List<BookResponse> getAllBooks() {
                return bookRepository.findAll()
                                .stream()
                                .map(book -> {
                                        BookOwnership ownership = bookOwnershipRepository.findByBook(book)
                                                        .orElseThrow(
                                                                        () -> new EntityNotFoundException(
                                                                                        "Ownership not found for book: "
                                                                                                        + book.getId()));

                                        BookHolding holding = bookHoldingRepository.findByBook(book)
                                                        .orElseThrow(
                                                                        () -> new EntityNotFoundException(
                                                                                        "Holding not found for book: "
                                                                                                        + book.getId()));

                                        return mapToBookResponse(book, ownership, holding);
                                })
                                .toList();
        }

        @Transactional(readOnly = true)
        public BookDetailResponse getBookById(Long id) {
                Book book = bookRepository.findById(id)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + id));

                BookOwnership ownership = bookOwnershipRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Ownership not found for book: " + book.getId()));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                List<BookTransactionResponse> transactions = bookTransactionRepository.findByBookOrderByIdDesc(book)
                                .stream()
                                .map(this::mapToTransactionResponse)
                                .toList();

                return BookDetailResponse.builder()
                                .bookId(book.getId())
                                .title(book.getTitle())
                                .author(book.getAuthor())
                                .isbn(book.getIsbn())
                                .language(book.getLanguage())
                                .category(book.getCategory())
                                .condition(book.getCondition())
                                .notes(book.getNotes())
                                .ownershipType(ownership.getOwnershipType())
                                .ownerUserId(ownership.getOwnerUser() != null ? ownership.getOwnerUser().getId() : null)
                                .ownerCommunityId(ownership.getOwnerCommunity() != null
                                                ? ownership.getOwnerCommunity().getId()
                                                : null)
                                .currentHolderUserId(
                                                holding.getCurrentHolderUser() != null
                                                                ? holding.getCurrentHolderUser().getId()
                                                                : null)
                                .currentShelfId(holding.getCurrentShelf() != null ? holding.getCurrentShelf().getId()
                                                : null)
                                .reservedForUserId(holding.getReservedForUser() != null
                                                ? holding.getReservedForUser().getId()
                                                : null)
                                .status(holding.getStatus())
                                .reservedUntil(holding.getReservedUntil())
                                .loanStartAt(holding.getLoanStartAt())
                                .dueAt(holding.getDueAt())
                                .transactions(transactions)
                                .build();
        }

        private BookResponse mapToBookResponse(Book book, BookOwnership ownership, BookHolding holding) {
                return BookResponse.builder()
                                .bookId(book.getId())
                                .title(book.getTitle())
                                .author(book.getAuthor())
                                .isbn(book.getIsbn())
                                .ownershipType(ownership.getOwnershipType())
                                .ownerUserId(ownership.getOwnerUser() != null ? ownership.getOwnerUser().getId() : null)
                                .ownerCommunityId(ownership.getOwnerCommunity() != null
                                                ? ownership.getOwnerCommunity().getId()
                                                : null)
                                .currentHolderUserId(
                                                holding.getCurrentHolderUser() != null
                                                                ? holding.getCurrentHolderUser().getId()
                                                                : null)
                                .currentShelfId(holding.getCurrentShelf() != null ? holding.getCurrentShelf().getId()
                                                : null)
                                .reservedForUserId(holding.getReservedForUser() != null
                                                ? holding.getReservedForUser().getId()
                                                : null)
                                .status(holding.getStatus())
                                .build();
        }

        private BookTransactionResponse mapToTransactionResponse(BookTransaction transaction) {
                return BookTransactionResponse.builder()
                                .id(transaction.getId())
                                .type(transaction.getType())
                                .fromUserId(transaction.getFromUser() != null ? transaction.getFromUser().getId()
                                                : null)
                                .toUserId(transaction.getToUser() != null ? transaction.getToUser().getId() : null)
                                .startDate(transaction.getStartDate())
                                .endDate(transaction.getEndDate())
                                .note(transaction.getNote())
                                .build();
        }

        @Transactional
        public BookDetailResponse reserveBook(Long bookId, ReserveBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.AVAILABLE) {
                        throw new IllegalStateException("Book is not available for reservation");
                }

                User reservedForUser = userRepository.findById(request.getReservedForUserId())
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "User not found: " + request.getReservedForUserId()));

                holding.setStatus(BookStatus.RESERVED);
                holding.setReservedForUser(reservedForUser);
                holding.setReservedUntil(Instant.now().plusSeconds(request.getReservedDays() * 24L * 60L * 60L));

                bookHoldingRepository.save(holding);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.RESERVATION)
                                .fromUser(null)
                                .toUser(reservedForUser)
                                .startDate(Instant.now())
                                .endDate(holding.getReservedUntil())
                                .note(request.getNote())
                                .build();

                bookTransactionRepository.save(transaction);

                return getBookById(bookId);
        }

        @Transactional
        public BookDetailResponse loanBook(Long bookId, LoanBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.AVAILABLE && holding.getStatus() != BookStatus.RESERVED) {
                        throw new IllegalStateException("Book is not available for loan");
                }

                User loanedToUser = userRepository.findById(request.getLoanedToUserId())
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "User not found: " + request.getLoanedToUserId()));

                if (holding.getStatus() == BookStatus.RESERVED
                                && holding.getReservedForUser() != null
                                && !holding.getReservedForUser().getId().equals(request.getLoanedToUserId())) {
                        throw new IllegalStateException("Book is reserved for another user");
                }

                holding.setCurrentHolderUser(loanedToUser);
                holding.setCurrentShelf(null);
                holding.setStatus(BookStatus.ON_LOAN);
                holding.setLoanStartAt(Instant.now());
                holding.setDueAt(Instant.now().plusSeconds(request.getLoanDays() * 24L * 60L * 60L));
                holding.setReservedForUser(null);
                holding.setReservedUntil(null);

                bookHoldingRepository.save(holding);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.LOAN)
                                .fromUser(null)
                                .toUser(loanedToUser)
                                .startDate(holding.getLoanStartAt())
                                .endDate(holding.getDueAt())
                                .note(request.getNote())
                                .build();

                bookTransactionRepository.save(transaction);

                return getBookById(bookId);
        }

        @Transactional
        public BookDetailResponse returnBook(Long bookId, ReturnBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.ON_LOAN) {
                        throw new IllegalStateException("Book is not currently on loan");
                }

                if (holding.getCurrentHolderUser() == null) {
                        throw new IllegalStateException("Book is marked as ON_LOAN but has no current holder");
                }

                if (request.getReturnedByUserId() == null) {
                        throw new IllegalArgumentException("returnedByUserId is required");
                }

                if (!holding.getCurrentHolderUser().getId().equals(request.getReturnedByUserId())) {
                        throw new IllegalStateException("Only the current holder can return this book");
                }

                BookOwnership ownership = bookOwnershipRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Ownership not found for book: " + book.getId()));

                User returnedByUser = holding.getCurrentHolderUser();

                holding.setCurrentHolderUser(ownership.getOwnerUser());
                holding.setCurrentShelf(null);
                holding.setStatus(BookStatus.AVAILABLE);
                holding.setLoanStartAt(null);
                holding.setDueAt(null);
                holding.setReservedForUser(null);
                holding.setReservedUntil(null);

                bookHoldingRepository.save(holding);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.RETURN)
                                .fromUser(returnedByUser)
                                .toUser(ownership.getOwnerUser())
                                .startDate(Instant.now())
                                .endDate(null)
                                .note(request.getNote())
                                .build();

                bookTransactionRepository.save(transaction);

                return getBookById(bookId);
        }

        @Transactional
        public BookDetailResponse giftBook(Long bookId, GiftBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookOwnership ownership = bookOwnershipRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Ownership not found for book: " + book.getId()));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.AVAILABLE) {
                        throw new IllegalStateException("Only available books can be gifted");
                }

                if (ownership.getOwnershipType() != OwnershipType.USER) {
                        throw new IllegalStateException("Only user-owned books can be gifted");
                }

                if (ownership.getOwnerUser() == null) {
                        throw new IllegalStateException("Book owner user is missing");
                }

                User newOwnerUser = userRepository.findById(request.getNewOwnerUserId())
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "User not found: " + request.getNewOwnerUserId()));

                User previousOwnerUser = ownership.getOwnerUser();

                if (previousOwnerUser.getId().equals(newOwnerUser.getId())) {
                        throw new IllegalStateException("Book is already owned by this user");
                }

                ownership.setOwnerUser(newOwnerUser);
                ownership.setOwnerCommunity(null);
                ownership.setOwnershipType(OwnershipType.USER);
                ownership.setOwnershipAcquiredAt(Instant.now());

                bookOwnershipRepository.save(ownership);

                holding.setCurrentHolderUser(newOwnerUser);
                holding.setCurrentShelf(null);
                holding.setStatus(BookStatus.AVAILABLE);
                holding.setReservedForUser(null);
                holding.setReservedUntil(null);
                holding.setLoanStartAt(null);
                holding.setDueAt(null);

                bookHoldingRepository.save(holding);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.GIFT)
                                .fromUser(previousOwnerUser)
                                .toUser(newOwnerUser)
                                .startDate(Instant.now())
                                .endDate(null)
                                .note(request.getNote())
                                .build();

                bookTransactionRepository.save(transaction);

                return getBookById(bookId);
        }
}