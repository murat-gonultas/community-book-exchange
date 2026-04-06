package com.murat.book_exchange_api.domain.enums;

/**
 * Represents the lifecycle state of a borrow request.
 *
 * <p>
 * Important distinction:
 * <ul>
 * <li>PENDING: request created, waiting for decision</li>
 * <li>APPROVED: request accepted, but physical handover has not happened
 * yet</li>
 * <li>FULFILLED: request completed and the actual loan has started</li>
 * </ul>
 */
public enum BorrowRequestStatus {
    PENDING,
    APPROVED,
    REJECTED,
    CANCELLED,
    FULFILLED
}