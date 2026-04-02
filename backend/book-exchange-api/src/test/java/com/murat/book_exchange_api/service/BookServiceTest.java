package com.murat.book_exchange_api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.time.ZoneId;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.murat.book_exchange_api.controller.request.ExtendLoanRequest;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.BookOwnership;
import com.murat.book_exchange_api.domain.book.BookTransaction;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.BookOwnershipRepository;
import com.murat.book_exchange_api.repository.BookRepository;
import com.murat.book_exchange_api.repository.BookTransactionRepository;
import com.murat.book_exchange_api.repository.CommunityRepository;
import com.murat.book_exchange_api.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @Mock
    private BookOwnershipRepository bookOwnershipRepository;

    @Mock
    private BookHoldingRepository bookHoldingRepository;

    @Mock
    private BookTransactionRepository bookTransactionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private CommunityRepository communityRepository;

    @InjectMocks
    private BookService bookService;

    private Book book;
    private User borrower;
    private BookHolding holding;
    private BookOwnership ownership;

    @BeforeEach
    void setUp() {
        borrower = User.builder()
                .id(2L)
                .name("Murat")
                .build();

        book = Book.builder()
                .id(10L)
                .title("Test Book")
                .author("Test Author")
                .language("tr")
                .category("Novel")
                .condition("Good")
                .notes("Test notes")
                .build();

        holding = BookHolding.builder()
                .book(book)
                .currentHolderUser(borrower)
                .currentShelf(null)
                .status(BookStatus.ON_LOAN)
                .loanStartAt(Instant.now().minusSeconds(3 * 24 * 60 * 60))
                .dueAt(Instant.now().plusSeconds(10 * 24 * 60 * 60))
                .loanExtendedCount(0)
                .lastExtendedAt(null)
                .build();

        ownership = BookOwnership.builder()
                .book(book)
                .ownershipType(OwnershipType.USER)
                .ownerUser(borrower)
                .ownerCommunity(null)
                .ownershipAcquiredAt(Instant.now())
                .build();
    }

    @Test
    void extendLoan_shouldExtendDueDateAndIncrementCount_whenValid() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(2L);

        Instant originalDueAt = holding.getDueAt();

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));
        when(bookOwnershipRepository.findByBook(book)).thenReturn(java.util.Optional.of(ownership));
        when(bookHoldingRepository.save(any(BookHolding.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(bookTransactionRepository.save(any(BookTransaction.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(bookTransactionRepository.findByBookOrderByIdDesc(book)).thenReturn(java.util.List.of());

        var response = bookService.extendLoan(10L, request);

        assertNotNull(response);
        assertEquals(1, holding.getLoanExtendedCount());
        assertNotNull(holding.getLastExtendedAt());
        assertTrue(holding.getDueAt().isAfter(originalDueAt));

        Instant expectedDueAt = originalDueAt.atZone(ZoneId.systemDefault())
                .plusMonths(1)
                .toInstant();

        assertEquals(expectedDueAt, holding.getDueAt());
        assertEquals(1, response.getLoanExtendedCount());
        assertFalse(Boolean.TRUE.equals(response.getOverdue()));
    }

    @Test
    void extendLoan_shouldThrow_whenBookIsNotOnLoan() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(2L);

        holding.setStatus(BookStatus.AVAILABLE);

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));

        IllegalStateException ex = assertThrows(
                IllegalStateException.class,
                () -> bookService.extendLoan(10L, request));

        assertEquals("Book is not currently on loan", ex.getMessage());
    }

    @Test
    void extendLoan_shouldThrow_whenRequesterIsNotCurrentHolder() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(999L);

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));

        IllegalStateException ex = assertThrows(
                IllegalStateException.class,
                () -> bookService.extendLoan(10L, request));

        assertEquals("Only the current holder can extend the loan", ex.getMessage());
    }

    @Test
    void extendLoan_shouldThrow_whenLoanIsOverdue() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(2L);

        holding.setDueAt(Instant.now().minusSeconds(24 * 60 * 60));

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));

        IllegalStateException ex = assertThrows(
                IllegalStateException.class,
                () -> bookService.extendLoan(10L, request));

        assertEquals("Overdue loans cannot be extended", ex.getMessage());
    }

    @Test
    void extendLoan_shouldThrow_whenMaxExtensionsReached() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(2L);

        holding.setLoanExtendedCount(2);

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));

        IllegalStateException ex = assertThrows(
                IllegalStateException.class,
                () -> bookService.extendLoan(10L, request));

        assertEquals("Maximum number of loan extensions reached", ex.getMessage());
    }

    @Test
    void extendLoan_shouldThrow_whenDueAtIsMissing() {
        ExtendLoanRequest request = new ExtendLoanRequest();
        request.setRequesterUserId(2L);

        holding.setDueAt(null);

        when(bookRepository.findById(10L)).thenReturn(java.util.Optional.of(book));
        when(bookHoldingRepository.findByBook(book)).thenReturn(java.util.Optional.of(holding));

        IllegalStateException ex = assertThrows(
                IllegalStateException.class,
                () -> bookService.extendLoan(10L, request));

        assertEquals("Loan due date is missing", ex.getMessage());
    }
}