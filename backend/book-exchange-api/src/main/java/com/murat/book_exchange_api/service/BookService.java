package com.murat.book_exchange_api.service;

import java.time.Instant;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.request.DonateBookRequest;
import com.murat.book_exchange_api.controller.request.ExtendLoanRequest;
import com.murat.book_exchange_api.controller.request.GiftBookRequest;
import com.murat.book_exchange_api.controller.request.LoanBookRequest;
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
import com.murat.book_exchange_api.domain.user.UserRepository;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.BookOwnershipRepository;
import com.murat.book_exchange_api.repository.BookRepository;
import com.murat.book_exchange_api.repository.BookTransactionRepository;
import com.murat.book_exchange_api.repository.CommunityRepository;

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

        private static final int DEFAULT_LOAN_PERIOD_MONTHS = 1;
        private static final int EXTENSION_PERIOD_MONTHS = 1;
        private static final int MAX_LOAN_EXTENSIONS = 2;

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
                                        .orElseThrow(() -> new EntityNotFoundException(
                                                        "Community not found: " + request.getOwnerCommunityId()));
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

                validateOwnershipConsistency(ownership);
                bookOwnershipRepository.save(ownership);

                BookHolding holding = BookHolding.builder()
                                .book(savedBook)
                                .currentHolderUser(ownerUser)
                                .currentShelf(null)
                                .status(BookStatus.AVAILABLE)
                                .loanStartAt(null)
                                .dueAt(null)
                                .loanExtendedCount(0)
                                .lastExtendedAt(null)
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
                                                        .orElseThrow(() -> new EntityNotFoundException(
                                                                        "Ownership not found for book: "
                                                                                        + book.getId()));

                                        BookHolding holding = bookHoldingRepository.findByBook(book)
                                                        .orElseThrow(() -> new EntityNotFoundException(
                                                                        "Holding not found for book: " + book.getId()));

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

                return mapToBookDetailResponse(book, ownership, holding, transactions);
        }

        @Transactional
        public BookDetailResponse loanBook(Long bookId, LoanBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.AVAILABLE) {
                        throw new IllegalStateException("Book is not available for loan");
                }

                User loanedToUser = userRepository.findById(request.getLoanedToUserId())
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "User not found: " + request.getLoanedToUserId()));

                Instant now = Instant.now();
                Instant dueAt = addCalendarMonths(now, DEFAULT_LOAN_PERIOD_MONTHS);

                holding.setCurrentHolderUser(loanedToUser);
                holding.setCurrentShelf(null);
                holding.setStatus(BookStatus.ON_LOAN);
                holding.setLoanStartAt(now);
                holding.setDueAt(dueAt);
                holding.setLoanExtendedCount(0);
                holding.setLastExtendedAt(null);

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

                validateOwnershipConsistency(ownership);

                User returnedByUser = holding.getCurrentHolderUser();

                if (ownership.getOwnershipType() == OwnershipType.USER) {
                        holding.setCurrentHolderUser(ownership.getOwnerUser());
                        holding.setCurrentShelf(null);
                } else {
                        holding.setCurrentHolderUser(null);
                        holding.setCurrentShelf(null);
                }

                holding.setStatus(BookStatus.AVAILABLE);
                holding.setLoanStartAt(null);
                holding.setDueAt(null);
                holding.setLoanExtendedCount(0);
                holding.setLastExtendedAt(null);

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
        public BookDetailResponse extendLoan(Long bookId, ExtendLoanRequest request) {
                if (request.getRequesterUserId() == null) {
                        throw new IllegalArgumentException("requesterUserId is required");
                }

                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (holding.getStatus() != BookStatus.ON_LOAN) {
                        throw new IllegalStateException("Book is not currently on loan");
                }

                if (holding.getCurrentHolderUser() == null) {
                        throw new IllegalStateException("Current holder is missing");
                }

                if (!holding.getCurrentHolderUser().getId().equals(request.getRequesterUserId())) {
                        throw new IllegalStateException("Only the current holder can extend the loan");
                }

                if (holding.getDueAt() == null) {
                        throw new IllegalStateException("Loan due date is missing");
                }

                Instant now = Instant.now();

                if (holding.getDueAt().isBefore(now)) {
                        throw new IllegalStateException("Overdue loans cannot be extended");
                }

                int currentExtensionCount = holding.getLoanExtendedCount() == null
                                ? 0
                                : holding.getLoanExtendedCount();

                if (currentExtensionCount >= MAX_LOAN_EXTENSIONS) {
                        throw new IllegalStateException("Maximum number of loan extensions reached");
                }

                Instant extendedDueAt = addCalendarMonths(holding.getDueAt(), EXTENSION_PERIOD_MONTHS);

                holding.setDueAt(extendedDueAt);
                holding.setLoanExtendedCount(currentExtensionCount + 1);
                holding.setLastExtendedAt(now);

                bookHoldingRepository.save(holding);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.LOAN_EXTENSION)
                                .fromUser(holding.getCurrentHolderUser())
                                .toUser(holding.getCurrentHolderUser())
                                .startDate(now)
                                .endDate(extendedDueAt)
                                .note("Loan extended by 1 month")
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

                validateOwnershipConsistency(ownership);
                bookOwnershipRepository.save(ownership);

                syncAvailableHoldingAfterOwnershipChange(holding, previousOwnerUser, newOwnerUser);

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

        @Transactional
        public BookDetailResponse donateBook(Long bookId, DonateBookRequest request) {
                Book book = bookRepository.findById(bookId)
                                .orElseThrow(() -> new EntityNotFoundException("Book not found: " + bookId));

                BookOwnership ownership = bookOwnershipRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Ownership not found for book: " + book.getId()));

                BookHolding holding = bookHoldingRepository.findByBook(book)
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Holding not found for book: " + book.getId()));

                if (ownership.getOwnershipType() != OwnershipType.USER) {
                        throw new IllegalStateException("Only user-owned books can be donated");
                }

                if (ownership.getOwnerUser() == null) {
                        throw new IllegalStateException("Book owner user is missing");
                }

                Community community = communityRepository.findById(request.getCommunityId())
                                .orElseThrow(() -> new EntityNotFoundException(
                                                "Community not found: " + request.getCommunityId()));

                User previousOwnerUser = ownership.getOwnerUser();

                ownership.setOwnerUser(null);
                ownership.setOwnerCommunity(community);
                ownership.setOwnershipType(OwnershipType.COMMUNITY);
                ownership.setOwnershipAcquiredAt(Instant.now());

                validateOwnershipConsistency(ownership);
                bookOwnershipRepository.save(ownership);

                syncAvailableHoldingAfterOwnershipChange(holding, previousOwnerUser, null);

                BookTransaction transaction = BookTransaction.builder()
                                .book(book)
                                .type(TransactionType.DONATION)
                                .fromUser(previousOwnerUser)
                                .toUser(null)
                                .startDate(Instant.now())
                                .endDate(null)
                                .note(request.getNote())
                                .build();

                bookTransactionRepository.save(transaction);

                return getBookById(bookId);
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
                                .currentHolderUserId(holding.getCurrentHolderUser() != null
                                                ? holding.getCurrentHolderUser().getId()
                                                : null)
                                .currentShelfId(holding.getCurrentShelf() != null ? holding.getCurrentShelf().getId()
                                                : null)
                                .status(holding.getStatus())
                                .build();
        }

        private BookDetailResponse mapToBookDetailResponse(
                        Book book,
                        BookOwnership ownership,
                        BookHolding holding,
                        List<BookTransactionResponse> transactions) {
                boolean overdue = isOverdue(holding);

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
                                .currentHolderUserId(holding.getCurrentHolderUser() != null
                                                ? holding.getCurrentHolderUser().getId()
                                                : null)
                                .currentShelfId(holding.getCurrentShelf() != null ? holding.getCurrentShelf().getId()
                                                : null)
                                .status(holding.getStatus())
                                .loanStartAt(holding.getLoanStartAt())
                                .dueAt(holding.getDueAt())
                                .loanExtendedCount(
                                                holding.getLoanExtendedCount() != null ? holding.getLoanExtendedCount()
                                                                : 0)
                                .overdue(overdue)
                                .overdueDays(overdue ? calculateOverdueDays(holding) : 0L)
                                .transactions(transactions)
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

        private void validateOwnershipConsistency(BookOwnership ownership) {
                if (ownership.getOwnershipType() == OwnershipType.USER) {
                        if (ownership.getOwnerUser() == null) {
                                throw new IllegalStateException("USER ownership requires ownerUser");
                        }
                        if (ownership.getOwnerCommunity() != null) {
                                throw new IllegalStateException("USER ownership cannot have ownerCommunity");
                        }
                }

                if (ownership.getOwnershipType() == OwnershipType.COMMUNITY) {
                        if (ownership.getOwnerCommunity() == null) {
                                throw new IllegalStateException("COMMUNITY ownership requires ownerCommunity");
                        }
                        if (ownership.getOwnerUser() != null) {
                                throw new IllegalStateException("COMMUNITY ownership cannot have ownerUser");
                        }
                }
        }

        private void syncAvailableHoldingAfterOwnershipChange(
                        BookHolding holding,
                        User previousOwnerUser,
                        User newOwnerUser) {
                if (holding.getStatus() != BookStatus.AVAILABLE) {
                        return;
                }

                if (holding.getCurrentHolderUser() == null || previousOwnerUser == null) {
                        return;
                }

                if (!holding.getCurrentHolderUser().getId().equals(previousOwnerUser.getId())) {
                        return;
                }

                holding.setCurrentHolderUser(newOwnerUser);
                holding.setCurrentShelf(null);
                bookHoldingRepository.save(holding);
        }

        private boolean isOverdue(BookHolding holding) {
                return holding != null
                                && holding.getStatus() == BookStatus.ON_LOAN
                                && holding.getDueAt() != null
                                && holding.getDueAt().isBefore(Instant.now());
        }

        private long calculateOverdueDays(BookHolding holding) {
                if (!isOverdue(holding)) {
                        return 0;
                }

                return ChronoUnit.DAYS.between(holding.getDueAt(), Instant.now());
        }

        private Instant addCalendarMonths(Instant baseInstant, int months) {
                return baseInstant
                                .atZone(ZoneId.systemDefault())
                                .plusMonths(months)
                                .toInstant();
        }
}