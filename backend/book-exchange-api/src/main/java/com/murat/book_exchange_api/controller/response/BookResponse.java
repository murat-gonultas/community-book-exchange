package com.murat.book_exchange_api.controller.response;

import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class BookResponse {

    private Long bookId;
    private String title;
    private String author;
    private String isbn;

    private OwnershipType ownershipType;
    private Long ownerUserId;
    private Long ownerCommunityId;

    private Long currentHolderUserId;
    private Long currentShelfId;
    private BookStatus status;
}