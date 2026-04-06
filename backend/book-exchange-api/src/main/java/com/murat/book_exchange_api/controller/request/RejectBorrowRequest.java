package com.murat.book_exchange_api.controller.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Request body used when rejecting a borrow request.
 *
 * <p>
 * A rejection reason is required so the requester can later receive
 * a meaningful explanation in the product UI.
 */
@Getter
@Setter
public class RejectBorrowRequest {

    @NotBlank(message = "Rejection reason is required")
    @Size(max = 1000, message = "Rejection reason must not exceed 1000 characters")
    private String rejectionReason;

    @Size(max = 1000, message = "Decision note must not exceed 1000 characters")
    private String decisionNote;

    public RejectBorrowRequest() {
    }

    public RejectBorrowRequest(String rejectionReason, String decisionNote) {
        this.rejectionReason = rejectionReason;
        this.decisionNote = decisionNote;
    }

}