package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GiftBookRequest {

    @NotNull(message = "newOwnerUserId is required")
    private Long newOwnerUserId;

    private String note;
}