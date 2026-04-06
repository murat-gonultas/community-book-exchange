package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Request body used when a user wants to create a borrow request for a book.
 *
 * <p>
 * The message is optional and can be used to provide context to the
 * owner/admin.
 * Example: "I would like to borrow this for two weeks."
 */

@Getter
@Setter
public class CreateBorrowRequest {

    @Size(max = 1000, message = "Message must not exceed 1000 characters")
    private String message;

    public CreateBorrowRequest() {
    }

    public CreateBorrowRequest(String message) {
        this.message = message;
    }
}