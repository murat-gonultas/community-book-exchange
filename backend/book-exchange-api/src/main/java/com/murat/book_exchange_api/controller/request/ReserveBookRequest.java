package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReserveBookRequest {

    @NotNull(message = "reservedForUserId is required")
    private Long reservedForUserId;

    @NotNull(message = "reservedDays is required")
    @Positive(message = "reservedDays must be greater than 0")
    private Integer reservedDays;

    private String note;
}