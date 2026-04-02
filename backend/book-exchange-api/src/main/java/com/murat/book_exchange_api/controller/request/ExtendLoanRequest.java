package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;

public class ExtendLoanRequest {

    @NotNull
    private Long requesterUserId;

    public Long getRequesterUserId() {
        return requesterUserId;
    }

    public void setRequesterUserId(Long requesterUserId) {
        this.requesterUserId = requesterUserId;
    }
}