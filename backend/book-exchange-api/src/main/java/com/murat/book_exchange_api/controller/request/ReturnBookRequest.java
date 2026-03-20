package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReturnBookRequest {

    @NotNull(message = "returnedByUserId is required")
    private Long returnedByUserId;

    private String note;
}