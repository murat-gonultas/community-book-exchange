package com.murat.book_exchange_api.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.murat.book_exchange_api.controller.response.LoanReminderResponse;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.LoanReminder;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.ReminderStatus;
import com.murat.book_exchange_api.domain.enums.ReminderType;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.domain.user.UserRepository;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.LoanReminderRepository;

import jakarta.persistence.EntityNotFoundException;

@ExtendWith(MockitoExtension.class)
class LoanReminderServiceTest {

    @Mock
    private BookHoldingRepository bookHoldingRepository;

    @Mock
    private LoanReminderRepository loanReminderRepository;

    @Mock
    private UserRepository userRepository;

    private LoanReminderService loanReminderService;

    @BeforeEach
    void setUp() {
        loanReminderService = new LoanReminderService(
                bookHoldingRepository,
                loanReminderRepository,
                userRepository);
    }

    @Test
    void shouldGenerateDueSoonReminder() {
        Instant dueAt = Instant.now().plus(3, ChronoUnit.DAYS);
        BookHolding holding = buildOnLoanHolding(1L, "Due Soon Book", 10L, "Ayse", dueAt);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(loanReminderRepository.existsByBookAndRecipientUserAndReminderTypeAndDueAtSnapshot(
                holding.getBook(),
                holding.getCurrentHolderUser(),
                ReminderType.DUE_SOON,
                dueAt)).thenReturn(false);

        int created = loanReminderService.generateDueSoonReminders();

        assertThat(created).isEqualTo(1);

        ArgumentCaptor<LoanReminder> captor = ArgumentCaptor.forClass(LoanReminder.class);
        verify(loanReminderRepository, times(1)).save(captor.capture());

        LoanReminder saved = captor.getValue();
        assertThat(saved.getBook().getId()).isEqualTo(1L);
        assertThat(saved.getRecipientUser().getId()).isEqualTo(10L);
        assertThat(saved.getReminderType()).isEqualTo(ReminderType.DUE_SOON);
        assertThat(saved.getDueAtSnapshot()).isEqualTo(dueAt);
        assertThat(saved.getStatus()).isEqualTo(ReminderStatus.PENDING);
        assertThat(saved.getProcessedAt()).isNull();
        assertThat(saved.getCreatedAt()).isNotNull();
    }

    @Test
    void shouldNotGenerateDuplicateDueSoonReminderForSameDueDate() {
        Instant dueAt = Instant.now().plus(2, ChronoUnit.DAYS);
        BookHolding holding = buildOnLoanHolding(2L, "Duplicate Due Soon Book", 11L, "Merve", dueAt);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(loanReminderRepository.existsByBookAndRecipientUserAndReminderTypeAndDueAtSnapshot(
                holding.getBook(),
                holding.getCurrentHolderUser(),
                ReminderType.DUE_SOON,
                dueAt)).thenReturn(true);

        int created = loanReminderService.generateDueSoonReminders();

        assertThat(created).isEqualTo(0);
        verify(loanReminderRepository, never()).save(any(LoanReminder.class));
    }

    @Test
    void shouldGenerateOverdueReminder() {
        Instant dueAt = Instant.now().minus(3, ChronoUnit.DAYS);
        BookHolding holding = buildOnLoanHolding(3L, "Overdue Book", 12L, "Ali", dueAt);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(loanReminderRepository.existsByBookAndRecipientUserAndReminderTypeAndCreatedAtBetween(
                eq(holding.getBook()),
                eq(holding.getCurrentHolderUser()),
                eq(ReminderType.OVERDUE),
                any(Instant.class),
                any(Instant.class))).thenReturn(false);

        int created = loanReminderService.generateOverdueReminders();

        assertThat(created).isEqualTo(1);

        ArgumentCaptor<LoanReminder> captor = ArgumentCaptor.forClass(LoanReminder.class);
        verify(loanReminderRepository, times(1)).save(captor.capture());

        LoanReminder saved = captor.getValue();
        assertThat(saved.getBook().getId()).isEqualTo(3L);
        assertThat(saved.getRecipientUser().getId()).isEqualTo(12L);
        assertThat(saved.getReminderType()).isEqualTo(ReminderType.OVERDUE);
        assertThat(saved.getDueAtSnapshot()).isEqualTo(dueAt);
        assertThat(saved.getStatus()).isEqualTo(ReminderStatus.PENDING);
        assertThat(saved.getProcessedAt()).isNull();
        assertThat(saved.getCreatedAt()).isNotNull();
    }

    @Test
    void shouldNotGenerateDuplicateOverdueReminderOnSameDay() {
        Instant dueAt = Instant.now().minus(5, ChronoUnit.DAYS);
        BookHolding holding = buildOnLoanHolding(4L, "Duplicate Overdue Book", 13L, "Zeynep", dueAt);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(loanReminderRepository.existsByBookAndRecipientUserAndReminderTypeAndCreatedAtBetween(
                eq(holding.getBook()),
                eq(holding.getCurrentHolderUser()),
                eq(ReminderType.OVERDUE),
                any(Instant.class),
                any(Instant.class))).thenReturn(true);

        int created = loanReminderService.generateOverdueReminders();

        assertThat(created).isEqualTo(0);
        verify(loanReminderRepository, never()).save(any(LoanReminder.class));
    }

    @Test
    void shouldIgnoreAvailableBooks() {
        Instant dueAt = Instant.now().plus(3, ChronoUnit.DAYS);
        BookHolding holding = buildHolding(5L, "Available Book", 14L, "Can", dueAt, BookStatus.AVAILABLE);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));

        int dueSoonCreated = loanReminderService.generateDueSoonReminders();
        int overdueCreated = loanReminderService.generateOverdueReminders();

        assertThat(dueSoonCreated).isEqualTo(0);
        assertThat(overdueCreated).isEqualTo(0);
        verify(loanReminderRepository, never()).save(any(LoanReminder.class));
    }

    @Test
    void shouldIgnoreLoansWithoutDueDate() {
        BookHolding holding = buildHolding(6L, "No Due Date Book", 15L, "Kemal", null, BookStatus.ON_LOAN);

        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));

        int dueSoonCreated = loanReminderService.generateDueSoonReminders();
        int overdueCreated = loanReminderService.generateOverdueReminders();

        assertThat(dueSoonCreated).isEqualTo(0);
        assertThat(overdueCreated).isEqualTo(0);
        verify(loanReminderRepository, never()).save(any(LoanReminder.class));
    }

    @Test
    void shouldReturnUserReminders() {
        User user = new User();
        user.setId(20L);
        user.setName("Ayse");

        Book book = new Book();
        book.setId(100L);
        book.setTitle("Reminder Book");

        Instant dueAtSnapshot = Instant.now().plus(2, ChronoUnit.DAYS);
        Instant createdAt = Instant.now();

        LoanReminder reminder = LoanReminder.builder()
                .id(99L)
                .book(book)
                .recipientUser(user)
                .reminderType(ReminderType.DUE_SOON)
                .dueAtSnapshot(dueAtSnapshot)
                .createdAt(createdAt)
                .processedAt(null)
                .status(ReminderStatus.PENDING)
                .build();

        when(userRepository.findById(20L)).thenReturn(Optional.of(user));
        when(loanReminderRepository.findByRecipientUserOrderByCreatedAtDesc(user))
                .thenReturn(List.of(reminder));

        List<LoanReminderResponse> responses = loanReminderService.getRemindersForUser(20L);

        assertThat(responses).hasSize(1);

        LoanReminderResponse response = responses.get(0);
        assertThat(response.getId()).isEqualTo(99L);
        assertThat(response.getBookId()).isEqualTo(100L);
        assertThat(response.getBookTitle()).isEqualTo("Reminder Book");
        assertThat(response.getRecipientUserId()).isEqualTo(20L);
        assertThat(response.getRecipientUserName()).isEqualTo("Ayse");
        assertThat(response.getReminderType()).isEqualTo(ReminderType.DUE_SOON);
        assertThat(response.getDueAtSnapshot()).isEqualTo(dueAtSnapshot);
        assertThat(response.getCreatedAt()).isEqualTo(createdAt);
        assertThat(response.getProcessedAt()).isNull();
        assertThat(response.getStatus()).isEqualTo(ReminderStatus.PENDING);
    }

    @Test
    void shouldThrowWhenUserNotFound() {
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> loanReminderService.getRemindersForUser(999L))
                .isInstanceOf(EntityNotFoundException.class)
                .hasMessage("User not found: 999");
    }

    private BookHolding buildOnLoanHolding(
            Long bookId,
            String title,
            Long userId,
            String userName,
            Instant dueAt) {
        return buildHolding(bookId, title, userId, userName, dueAt, BookStatus.ON_LOAN);
    }

    private BookHolding buildHolding(
            Long bookId,
            String title,
            Long userId,
            String userName,
            Instant dueAt,
            BookStatus status) {
        Book book = new Book();
        book.setId(bookId);
        book.setTitle(title);

        User user = new User();
        user.setId(userId);
        user.setName(userName);

        BookHolding holding = new BookHolding();
        holding.setBook(book);
        holding.setCurrentHolderUser(user);
        holding.setStatus(status);
        holding.setLoanStartAt(Instant.now().minus(10, ChronoUnit.DAYS));
        holding.setDueAt(dueAt);
        holding.setLoanExtendedCount(0);

        return holding;
    }
}