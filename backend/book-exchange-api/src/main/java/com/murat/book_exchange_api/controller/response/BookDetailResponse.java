package com.murat.book_exchange_api.controller.response;

import java.time.Instant;
import java.util.List;

import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class BookDetailResponse {

    private Long bookId;
    private String title;
    private String author;
    private String isbn;
    private String language;
    private String category;
    private String condition;
    private String notes;

    private OwnershipType ownershipType;
    private Long ownerUserId;
    private Long ownerCommunityId;

    private Long currentHolderUserId;
    private Long currentShelfId;
    private BookStatus status;
    private Instant loanStartAt;
    private Instant dueAt;

    private Integer loanExtendedCount;
    private Boolean overdue;
    private Long overdueDays;

    private List<BookTransactionResponse> transactions;
}