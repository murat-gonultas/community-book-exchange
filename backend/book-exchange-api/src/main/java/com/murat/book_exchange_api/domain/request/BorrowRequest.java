package com.murat.book_exchange_api.domain.request;

import java.time.LocalDateTime;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.enums.BorrowRequestStatus;
import com.murat.book_exchange_api.domain.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * Represents a user's request to borrow a specific book.
 *
 * <p>
 * This entity does NOT represent the actual loan itself.
 * It represents the request/approval workflow that may later lead
 * to a real loan after physical handover is confirmed.
 */
@Entity
@Table(name = "borrow_request", indexes = {
        @Index(name = "idx_borrow_request_book", columnList = "book_id"),
        @Index(name = "idx_borrow_request_requester", columnList = "requester_id"),
        @Index(name = "idx_borrow_request_status", columnList = "status")
})
@Getter
@Setter
public class BorrowRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * The book that is being requested.
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    /**
     * The user who wants to borrow the book.
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    /**
     * Current state of the borrow request lifecycle.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private BorrowRequestStatus status;

    /**
     * Optional message written by the requester.
     * Example: "I would like to borrow this for two weeks."
     */
    @Column(name = "message", length = 1000)
    private String message;

    /**
     * Optional structured rejection reason, saved when a request is rejected.
     */
    @Column(name = "rejection_reason", length = 1000)
    private String rejectionReason;

    /**
     * Optional decision note written by the owner/admin while approving or
     * rejecting.
     */
    @Column(name = "decision_note", length = 1000)
    private String decisionNote;

    /**
     * The user who approved or rejected the request.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "decided_by_user_id")
    private User decidedBy;

    /**
     * Timestamp of the decision (approve/reject).
     */
    @Column(name = "decided_at")
    private LocalDateTime decidedAt;

    /**
     * Creation timestamp.
     */
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    /**
     * Last update timestamp.
     */
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public BorrowRequest() {
    }

    public BorrowRequest(
            Long id,
            Book book,
            User requester,
            BorrowRequestStatus status,
            String message,
            String rejectionReason,
            String decisionNote,
            User decidedBy,
            LocalDateTime decidedAt,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {
        this.id = id;
        this.book = book;
        this.requester = requester;
        this.status = status;
        this.message = message;
        this.rejectionReason = rejectionReason;
        this.decisionNote = decisionNote;
        this.decidedBy = decidedBy;
        this.decidedAt = decidedAt;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        if (this.status == null) {
            this.status = BorrowRequestStatus.PENDING;
        }

        if (this.createdAt == null) {
            this.createdAt = now;
        }

        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isPending() {
        return this.status == BorrowRequestStatus.PENDING;
    }

    public boolean isApproved() {
        return this.status == BorrowRequestStatus.APPROVED;
    }

    public boolean isFinalState() {
        return this.status == BorrowRequestStatus.REJECTED
                || this.status == BorrowRequestStatus.CANCELLED
                || this.status == BorrowRequestStatus.FULFILLED;
    }

}