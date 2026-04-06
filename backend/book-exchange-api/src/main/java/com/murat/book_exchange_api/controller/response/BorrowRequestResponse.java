package com.murat.book_exchange_api.controller.response;

import java.time.LocalDateTime;

import com.murat.book_exchange_api.domain.enums.BorrowRequestStatus;
import com.murat.book_exchange_api.domain.request.BorrowRequest;

import lombok.Getter;
import lombok.Setter;

/**
 * Response DTO returned for borrow request operations.
 */
@Getter
@Setter
public class BorrowRequestResponse {

    private Long id;
    private Long bookId;
    private String bookTitle;
    private String bookAuthor;

    private Long requesterUserId;
    private String requesterName;

    private BorrowRequestStatus status;
    private String message;
    private String rejectionReason;
    private String decisionNote;

    private Long decidedByUserId;
    private String decidedByName;
    private LocalDateTime decidedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public BorrowRequestResponse() {
    }

    public BorrowRequestResponse(
            Long id,
            Long bookId,
            String bookTitle,
            String bookAuthor,
            Long requesterUserId,
            String requesterName,
            BorrowRequestStatus status,
            String message,
            String rejectionReason,
            String decisionNote,
            Long decidedByUserId,
            String decidedByName,
            LocalDateTime decidedAt,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {
        this.id = id;
        this.bookId = bookId;
        this.bookTitle = bookTitle;
        this.bookAuthor = bookAuthor;
        this.requesterUserId = requesterUserId;
        this.requesterName = requesterName;
        this.status = status;
        this.message = message;
        this.rejectionReason = rejectionReason;
        this.decisionNote = decisionNote;
        this.decidedByUserId = decidedByUserId;
        this.decidedByName = decidedByName;
        this.decidedAt = decidedAt;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static BorrowRequestResponse from(BorrowRequest borrowRequest) {
        return new BorrowRequestResponse(
                borrowRequest.getId(),
                borrowRequest.getBook() != null ? borrowRequest.getBook().getId() : null,
                borrowRequest.getBook() != null ? borrowRequest.getBook().getTitle() : null,
                borrowRequest.getBook() != null ? borrowRequest.getBook().getAuthor() : null,
                borrowRequest.getRequester() != null ? borrowRequest.getRequester().getId() : null,
                borrowRequest.getRequester() != null ? borrowRequest.getRequester().getName() : null,
                borrowRequest.getStatus(),
                borrowRequest.getMessage(),
                borrowRequest.getRejectionReason(),
                borrowRequest.getDecisionNote(),
                borrowRequest.getDecidedBy() != null ? borrowRequest.getDecidedBy().getId() : null,
                borrowRequest.getDecidedBy() != null ? borrowRequest.getDecidedBy().getName() : null,
                borrowRequest.getDecidedAt(),
                borrowRequest.getCreatedAt(),
                borrowRequest.getUpdatedAt());
    }

}