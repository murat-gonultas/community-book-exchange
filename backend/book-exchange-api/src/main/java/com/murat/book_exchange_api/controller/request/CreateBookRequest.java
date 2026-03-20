package com.murat.book_exchange_api.controller.request;

import com.murat.book_exchange_api.domain.enums.OwnershipType;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateBookRequest {

    @NotBlank(message = "title is required")
    @Size(max = 200, message = "title must be at most 200 characters")
    private String title;

    @Size(max = 200, message = "author must be at most 200 characters")
    private String author;

    @Size(max = 50, message = "isbn must be at most 50 characters")
    private String isbn;

    @Size(max = 50, message = "language must be at most 50 characters")
    private String language;

    @Size(max = 100, message = "category must be at most 100 characters")
    private String category;

    @Size(max = 100, message = "condition must be at most 100 characters")
    private String condition;

    @Size(max = 1000, message = "notes must be at most 1000 characters")
    private String notes;

    @NotNull(message = "ownershipType is required")
    private OwnershipType ownershipType;

    private Long ownerUserId;
    private Long ownerCommunityId;
}