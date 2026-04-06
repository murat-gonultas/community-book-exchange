package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Request body used when approving a borrow request.
 *
 * <p>
 * The decision note is optional and may contain practical details
 * about pickup, handover, or availability.
 */

@Getter
@Setter
public class ApproveBorrowRequest {

    @Size(max = 1000, message = "Decision note must not exceed 1000 characters")
    private String decisionNote;

    public ApproveBorrowRequest() {
    }

    public ApproveBorrowRequest(String decisionNote) {
        this.decisionNote = decisionNote;
    }
}