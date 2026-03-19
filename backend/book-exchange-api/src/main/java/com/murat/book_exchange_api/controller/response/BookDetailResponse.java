package com.murat.book_exchange_api.controller.response;

import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
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
    private Long reservedForUserId;
    private BookStatus status;
    private Instant reservedUntil;
    private Instant loanStartAt;
    private Instant dueAt;

    private List<BookTransactionResponse> transactions;
}