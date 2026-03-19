package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReserveBookRequest {

    @NotNull
    private Long reservedForUserId;

    @NotNull
    private Integer reservedDays;

    private String note;
}