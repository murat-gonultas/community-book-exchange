package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Request body used when a previously approved borrow request
 * is physically fulfilled and converted into an actual loan.
 *
 * <p>
 * The actual loan period is currently determined by the existing
 * backend loan policy inside BookService.
 */

@Getter
@Setter
public class FulfillBorrowRequest {

    @Size(max = 1000, message = "Note must not exceed 1000 characters")
    private String note;

    public FulfillBorrowRequest() {
    }

    public FulfillBorrowRequest(String note) {
        this.note = note;
    }

}