package com.murat.book_exchange_api.service;

import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.murat.book_exchange_api.controller.response.LoanReminderResponse;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.LoanReminder;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.ReminderStatus;
import com.murat.book_exchange_api.domain.enums.ReminderType;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.LoanReminderRepository;
import com.murat.book_exchange_api.repository.UserRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class LoanReminderService {

    private static final int DUE_SOON_REMINDER_DAYS = 7;

    private final BookHoldingRepository bookHoldingRepository;
    private final LoanReminderRepository loanReminderRepository;
    private final UserRepository userRepository;

    @Transactional
    public int generateDueSoonReminders() {
        List<BookHolding> holdings = bookHoldingRepository.findAll();
        Instant now = Instant.now();
        Instant dueSoonThreshold = now.plusSeconds(DUE_SOON_REMINDER_DAYS * 24L * 60L * 60L);

        int createdCount = 0;

        for (BookHolding holding : holdings) {
            if (!isEligibleForReminder(holding)) {
                continue;
            }

            Instant dueAt = holding.getDueAt();

            if (dueAt.isBefore(now)) {
                continue;
            }

            if (dueAt.isAfter(dueSoonThreshold)) {
                continue;
            }

            Book book = holding.getBook();
            User recipientUser = holding.getCurrentHolderUser();

            boolean alreadyExists = loanReminderRepository
                    .existsByBookAndRecipientUserAndReminderTypeAndDueAtSnapshot(
                            book,
                            recipientUser,
                            ReminderType.DUE_SOON,
                            dueAt);

            if (alreadyExists) {
                continue;
            }

            LoanReminder reminder = LoanReminder.builder()
                    .book(book)
                    .recipientUser(recipientUser)
                    .reminderType(ReminderType.DUE_SOON)
                    .dueAtSnapshot(dueAt)
                    .createdAt(now)
                    .processedAt(null)
                    .status(ReminderStatus.PENDING)
                    .build();

            loanReminderRepository.save(reminder);
            createdCount++;
        }

        return createdCount;
    }

    @Transactional
    public int generateOverdueReminders() {
        List<BookHolding> holdings = bookHoldingRepository.findAll();
        Instant now = Instant.now();

        Instant startOfToday = startOfDay(now);
        Instant endOfToday = startOfTomorrow(now);

        int createdCount = 0;

        for (BookHolding holding : holdings) {
            if (!isEligibleForReminder(holding)) {
                continue;
            }

            Instant dueAt = holding.getDueAt();

            if (!dueAt.isBefore(now)) {
                continue;
            }

            Book book = holding.getBook();
            User recipientUser = holding.getCurrentHolderUser();

            boolean alreadyExistsToday = loanReminderRepository
                    .existsByBookAndRecipientUserAndReminderTypeAndCreatedAtBetween(
                            book,
                            recipientUser,
                            ReminderType.OVERDUE,
                            startOfToday,
                            endOfToday);

            if (alreadyExistsToday) {
                continue;
            }

            LoanReminder reminder = LoanReminder.builder()
                    .book(book)
                    .recipientUser(recipientUser)
                    .reminderType(ReminderType.OVERDUE)
                    .dueAtSnapshot(dueAt)
                    .createdAt(now)
                    .processedAt(null)
                    .status(ReminderStatus.PENDING)
                    .build();

            loanReminderRepository.save(reminder);
            createdCount++;
        }

        return createdCount;
    }

    @Transactional(readOnly = true)
    public List<LoanReminderResponse> getRemindersForUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found: " + userId));

        return loanReminderRepository.findByRecipientUserOrderByCreatedAtDesc(user)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private LoanReminderResponse mapToResponse(LoanReminder reminder) {
        return LoanReminderResponse.builder()
                .id(reminder.getId())
                .bookId(reminder.getBook() != null ? reminder.getBook().getId() : null)
                .bookTitle(reminder.getBook() != null ? reminder.getBook().getTitle() : null)
                .recipientUserId(reminder.getRecipientUser() != null ? reminder.getRecipientUser().getId() : null)
                .recipientUserName(reminder.getRecipientUser() != null ? reminder.getRecipientUser().getName() : null)
                .reminderType(reminder.getReminderType())
                .dueAtSnapshot(reminder.getDueAtSnapshot())
                .createdAt(reminder.getCreatedAt())
                .processedAt(reminder.getProcessedAt())
                .status(reminder.getStatus())
                .build();
    }

    private boolean isEligibleForReminder(BookHolding holding) {
        return holding != null
                && holding.getStatus() == BookStatus.ON_LOAN
                && holding.getBook() != null
                && holding.getCurrentHolderUser() != null
                && holding.getDueAt() != null;
    }

    private Instant startOfDay(Instant instant) {
        ZonedDateTime zonedDateTime = instant.atZone(ZoneId.systemDefault())
                .toLocalDate()
                .atStartOfDay(ZoneId.systemDefault());

        return zonedDateTime.toInstant();
    }

    private Instant startOfTomorrow(Instant instant) {
        ZonedDateTime zonedDateTime = instant.atZone(ZoneId.systemDefault())
                .toLocalDate()
                .plusDays(1)
                .atStartOfDay(ZoneId.systemDefault());

        return zonedDateTime.toInstant();
    }
}