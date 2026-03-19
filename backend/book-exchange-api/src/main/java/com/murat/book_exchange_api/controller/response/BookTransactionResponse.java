package com.murat.book_exchange_api.controller.response;

import com.murat.book_exchange_api.domain.enums.TransactionType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class BookTransactionResponse {

    private Long id;
    private TransactionType type;
    private Long fromUserId;
    private Long toUserId;
    private Instant startDate;
    private Instant endDate;
    private String note;
}