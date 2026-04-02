package com.murat.book_exchange_api.repository;

import java.time.Instant;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.LoanReminder;
import com.murat.book_exchange_api.domain.enums.ReminderType;
import com.murat.book_exchange_api.domain.user.User;

public interface LoanReminderRepository extends JpaRepository<LoanReminder, Long> {

    boolean existsByBookAndRecipientUserAndReminderTypeAndDueAtSnapshot(
            Book book,
            User recipientUser,
            ReminderType reminderType,
            Instant dueAtSnapshot);

    boolean existsByBookAndRecipientUserAndReminderTypeAndCreatedAtBetween(
            Book book,
            User recipientUser,
            ReminderType reminderType,
            Instant start,
            Instant end);

    List<LoanReminder> findByRecipientUserOrderByCreatedAtDesc(User recipientUser);
}