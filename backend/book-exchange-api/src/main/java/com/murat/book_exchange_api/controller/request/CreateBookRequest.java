package com.murat.book_exchange_api.controller.request;

import com.murat.book_exchange_api.domain.enums.OwnershipType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateBookRequest {

    @NotBlank
    private String title;

    private String author;
    private String isbn;
    private String language;
    private String category;
    private String condition;
    private String notes;

    @NotNull
    private OwnershipType ownershipType;

    private Long ownerUserId;
    private Long ownerCommunityId;
}