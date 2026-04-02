package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoanBookRequest {

    @NotNull(message = "loanedToUserId is required")
    private Long loanedToUserId;

    private String note;
}