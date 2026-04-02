package com.murat.book_exchange_api.controller.response;

import java.time.Instant;

import com.murat.book_exchange_api.domain.enums.ReminderStatus;
import com.murat.book_exchange_api.domain.enums.ReminderType;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoanReminderResponse {

    private Long id;
    private Long bookId;
    private String bookTitle;
    private Long recipientUserId;
    private String recipientUserName;
    private ReminderType reminderType;
    private Instant dueAtSnapshot;
    private Instant createdAt;
    private Instant processedAt;
    private ReminderStatus status;
}