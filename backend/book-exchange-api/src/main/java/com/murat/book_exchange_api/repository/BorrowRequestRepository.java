package com.murat.book_exchange_api.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.murat.book_exchange_api.domain.enums.BorrowRequestStatus;
import com.murat.book_exchange_api.domain.request.BorrowRequest;

public interface BorrowRequestRepository extends JpaRepository<BorrowRequest, Long> {

    /**
     * Returns all requests created by a specific user, newest first.
     */
    List<BorrowRequest> findByRequesterIdOrderByCreatedAtDesc(Long requesterId);

    /**
     * Returns all requests for a specific book, newest first.
     */
    List<BorrowRequest> findByBookIdOrderByCreatedAtDesc(Long bookId);

    /**
     * Returns all requests with a given status, newest first.
     */
    List<BorrowRequest> findByStatusOrderByCreatedAtDesc(BorrowRequestStatus status);

    /**
     * Checks whether the same requester already has an active request
     * for the same book.
     *
     * <p>
     * Typical active statuses:
     * PENDING, APPROVED
     */
    boolean existsByBookIdAndRequesterIdAndStatusIn(
            Long bookId,
            Long requesterId,
            Collection<BorrowRequestStatus> statuses);

    /**
     * Returns all requests for one specific book filtered by status.
     */
    List<BorrowRequest> findByBookIdAndStatusOrderByCreatedAtDesc(
            Long bookId,
            BorrowRequestStatus status);
}