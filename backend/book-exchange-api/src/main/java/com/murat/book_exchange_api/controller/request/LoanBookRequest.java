package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoanBookRequest {

    @NotNull(message = "loanedToUserId is required")
    private Long loanedToUserId;

    @NotNull(message = "loanDays is required")
    @Positive(message = "loanDays must be greater than 0")
    private Integer loanDays;

    private String note;
}