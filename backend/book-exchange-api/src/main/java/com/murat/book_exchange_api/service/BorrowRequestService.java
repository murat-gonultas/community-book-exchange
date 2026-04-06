package com.murat.book_exchange_api.service;

import java.time.LocalDateTime;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.murat.book_exchange_api.auth.model.SystemRole;
import com.murat.book_exchange_api.controller.request.ApproveBorrowRequest;
import com.murat.book_exchange_api.controller.request.CreateBorrowRequest;
import com.murat.book_exchange_api.controller.request.FulfillBorrowRequest;
import com.murat.book_exchange_api.controller.request.LoanBookRequest;
import com.murat.book_exchange_api.controller.request.RejectBorrowRequest;
import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import com.murat.book_exchange_api.domain.book.BookOwnership;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.enums.BorrowRequestStatus;
import com.murat.book_exchange_api.domain.request.BorrowRequest;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.domain.user.UserRepository;
import com.murat.book_exchange_api.repository.BookHoldingRepository;
import com.murat.book_exchange_api.repository.BookOwnershipRepository;
import com.murat.book_exchange_api.repository.BookRepository;
import com.murat.book_exchange_api.repository.BorrowRequestRepository;

/**
 * Service responsible for the borrow request workflow.
 *
 * <p>
 * This service handles:
 * <ul>
 * <li>creating borrow requests</li>
 * <li>listing a user's own requests</li>
 * <li>listing incoming requests for books the user may decide on</li>
 * <li>approving requests</li>
 * <li>rejecting requests</li>
 * <li>cancelling requests</li>
 * <li>fulfilling approved requests into real loans</li>
 * </ul>
 */
@Service
@Transactional
public class BorrowRequestService {

    private static final Set<BorrowRequestStatus> ACTIVE_REQUEST_STATUSES = EnumSet.of(BorrowRequestStatus.PENDING,
            BorrowRequestStatus.APPROVED);

    private final BorrowRequestRepository borrowRequestRepository;
    private final BookRepository bookRepository;
    private final BookOwnershipRepository bookOwnershipRepository;
    private final BookHoldingRepository bookHoldingRepository;
    private final UserRepository userRepository;
    private final BookService bookService;

    public BorrowRequestService(
            BorrowRequestRepository borrowRequestRepository,
            BookRepository bookRepository,
            BookOwnershipRepository bookOwnershipRepository,
            BookHoldingRepository bookHoldingRepository,
            UserRepository userRepository,
            BookService bookService) {
        this.borrowRequestRepository = borrowRequestRepository;
        this.bookRepository = bookRepository;
        this.bookOwnershipRepository = bookOwnershipRepository;
        this.bookHoldingRepository = bookHoldingRepository;
        this.userRepository = userRepository;
        this.bookService = bookService;
    }

    /**
     * Creates a new borrow request for a book.
     *
     * <p>
     * Rules:
     * <ul>
     * <li>the requester must exist</li>
     * <li>the book must exist</li>
     * <li>the requester cannot request their own user-owned book</li>
     * <li>the book must currently be AVAILABLE</li>
     * <li>the requester cannot already have an active request for the same
     * book</li>
     * </ul>
     */
    public BorrowRequest createBorrowRequest(Long requesterUserId, Long bookId, CreateBorrowRequest request) {
        User requester = findUserOrThrow(requesterUserId);
        Book book = findBookOrThrow(bookId);

        validateBorrowRequestCreation(requester, book);

        boolean duplicateActiveRequest = borrowRequestRepository.existsByBookIdAndRequesterIdAndStatusIn(
                bookId,
                requesterUserId,
                ACTIVE_REQUEST_STATUSES);

        if (duplicateActiveRequest) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You already have an active borrow request for this book");
        }

        BorrowRequest borrowRequest = new BorrowRequest();
        borrowRequest.setBook(book);
        borrowRequest.setRequester(requester);
        borrowRequest.setStatus(BorrowRequestStatus.PENDING);
        borrowRequest.setMessage(normalize(request != null ? request.getMessage() : null));

        return borrowRequestRepository.save(borrowRequest);
    }

    /**
     * Returns all requests created by the given user, newest first.
     */
    @Transactional(readOnly = true)
    public List<BorrowRequest> getMyRequests(Long requesterUserId) {
        findUserOrThrow(requesterUserId);
        return borrowRequestRepository.findByRequesterIdOrderByCreatedAtDesc(requesterUserId);
    }

    /**
     * Returns all incoming requests the current user is allowed to decide on.
     *
     * <p>
     * Current decision rule:
     * <ul>
     * <li>the owner of a user-owned book may decide</li>
     * <li>an ADMIN may decide any request</li>
     * </ul>
     */
    @Transactional(readOnly = true)
    public List<BorrowRequest> getIncomingRequests(Long actorUserId) {
        User actor = findUserOrThrow(actorUserId);

        return borrowRequestRepository.findAll()
                .stream()
                .filter(request -> canActorDecideRequest(actor, request))
                .sorted((left, right) -> right.getCreatedAt().compareTo(left.getCreatedAt()))
                .toList();
    }

    /**
     * Approves a pending borrow request.
     */
    public BorrowRequest approveBorrowRequest(Long actorUserId, Long borrowRequestId, ApproveBorrowRequest request) {
        User actor = findUserOrThrow(actorUserId);
        BorrowRequest borrowRequest = findBorrowRequestOrThrow(borrowRequestId);

        ensurePending(borrowRequest);
        ensureActorCanDecide(actor, borrowRequest);
        ensureBookIsCurrentlyAvailable(borrowRequest.getBook().getId());
        ensureNoOtherApprovedRequestExists(borrowRequest);

        LocalDateTime now = LocalDateTime.now();

        borrowRequest.setStatus(BorrowRequestStatus.APPROVED);
        borrowRequest.setDecisionNote(normalize(request != null ? request.getDecisionNote() : null));
        borrowRequest.setRejectionReason(null);
        borrowRequest.setDecidedBy(actor);
        borrowRequest.setDecidedAt(now);
        borrowRequest.setUpdatedAt(now);

        return borrowRequestRepository.save(borrowRequest);
    }

    /**
     * Rejects a pending borrow request.
     */
    public BorrowRequest rejectBorrowRequest(Long actorUserId, Long borrowRequestId, RejectBorrowRequest request) {
        User actor = findUserOrThrow(actorUserId);
        BorrowRequest borrowRequest = findBorrowRequestOrThrow(borrowRequestId);

        ensurePending(borrowRequest);
        ensureActorCanDecide(actor, borrowRequest);

        String rejectionReason = normalize(request != null ? request.getRejectionReason() : null);
        if (rejectionReason == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Rejection reason is required");
        }

        LocalDateTime now = LocalDateTime.now();

        borrowRequest.setStatus(BorrowRequestStatus.REJECTED);
        borrowRequest.setRejectionReason(rejectionReason);
        borrowRequest.setDecisionNote(normalize(request != null ? request.getDecisionNote() : null));
        borrowRequest.setDecidedBy(actor);
        borrowRequest.setDecidedAt(now);
        borrowRequest.setUpdatedAt(now);

        return borrowRequestRepository.save(borrowRequest);
    }

    /**
     * Cancels a pending borrow request.
     *
     * <p>
     * For now only the requester may cancel it,
     * and only while it is still PENDING.
     */
    public BorrowRequest cancelBorrowRequest(Long actorUserId, Long borrowRequestId) {
        User actor = findUserOrThrow(actorUserId);
        BorrowRequest borrowRequest = findBorrowRequestOrThrow(borrowRequestId);

        ensurePending(borrowRequest);

        if (!borrowRequest.getRequester().getId().equals(actor.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You are not allowed to cancel this borrow request");
        }

        borrowRequest.setStatus(BorrowRequestStatus.CANCELLED);
        borrowRequest.setUpdatedAt(LocalDateTime.now());

        return borrowRequestRepository.save(borrowRequest);
    }

    /**
     * Fulfills an already approved borrow request by converting it
     * into a real loan using the existing BookService.loanBook(...) flow.
     *
     * <p>
     * Rules:
     * <ul>
     * <li>only APPROVED requests may be fulfilled</li>
     * <li>only the owner/admin may fulfill</li>
     * <li>the book must still be AVAILABLE right before the loan starts</li>
     * </ul>
     */
    public BorrowRequest fulfillBorrowRequest(Long actorUserId, Long borrowRequestId, FulfillBorrowRequest request) {
        User actor = findUserOrThrow(actorUserId);
        BorrowRequest borrowRequest = findBorrowRequestOrThrow(borrowRequestId);

        ensureApproved(borrowRequest);
        ensureActorCanDecide(actor, borrowRequest);
        ensureBookIsCurrentlyAvailable(borrowRequest.getBook().getId());

        LoanBookRequest loanBookRequest = new LoanBookRequest();
        loanBookRequest.setLoanedToUserId(borrowRequest.getRequester().getId());
        loanBookRequest.setNote(normalize(request != null ? request.getNote() : null));

        bookService.loanBook(borrowRequest.getBook().getId(), loanBookRequest);

        LocalDateTime now = LocalDateTime.now();

        borrowRequest.setStatus(BorrowRequestStatus.FULFILLED);
        borrowRequest.setDecisionNote(normalize(request != null ? request.getNote() : null));
        borrowRequest.setDecidedBy(actor);
        borrowRequest.setDecidedAt(now);
        borrowRequest.setUpdatedAt(now);

        return borrowRequestRepository.save(borrowRequest);
    }

    private void validateBorrowRequestCreation(User requester, Book book) {
        BookOwnership ownership = findOwnershipByBookId(book.getId());

        if (ownership != null
                && ownership.getOwnerUser() != null
                && requester.getId().equals(ownership.getOwnerUser().getId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "You cannot create a borrow request for your own book");
        }

        ensureBookIsCurrentlyAvailable(book.getId());
    }

    private void ensurePending(BorrowRequest borrowRequest) {
        if (!borrowRequest.isPending()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Only pending borrow requests can be changed");
        }
    }

    private void ensureApproved(BorrowRequest borrowRequest) {
        if (!borrowRequest.isApproved()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Only approved borrow requests can be fulfilled");
        }
    }

    private void ensureActorCanDecide(User actor, BorrowRequest borrowRequest) {
        if (!canActorDecideRequest(actor, borrowRequest)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You are not allowed to decide this borrow request");
        }
    }

    private boolean canActorDecideRequest(User actor, BorrowRequest borrowRequest) {
        if (actor.getSystemRole() == SystemRole.ADMIN) {
            return true;
        }

        BookOwnership ownership = findOwnershipByBookId(borrowRequest.getBook().getId());

        if (ownership == null) {
            return false;
        }

        if (ownership.getOwnerUser() == null) {
            return false;
        }

        return actor.getId().equals(ownership.getOwnerUser().getId());
    }

    private void ensureBookIsCurrentlyAvailable(Long bookId) {
        BookHolding holding = findHoldingByBookId(bookId);

        if (holding == null) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Book holding information is missing for this book");
        }

        if (holding.getStatus() != BookStatus.AVAILABLE) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This book is currently not available for borrow requests");
        }
    }

    private void ensureNoOtherApprovedRequestExists(BorrowRequest currentRequest) {
        List<BorrowRequest> approvedRequests = borrowRequestRepository.findByBookIdAndStatusOrderByCreatedAtDesc(
                currentRequest.getBook().getId(),
                BorrowRequestStatus.APPROVED);

        boolean anotherApprovedExists = approvedRequests.stream()
                .anyMatch(request -> !request.getId().equals(currentRequest.getId()));

        if (anotherApprovedExists) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This book already has another approved borrow request");
        }
    }

    private BookOwnership findOwnershipByBookId(Long bookId) {
        return bookOwnershipRepository.findAll()
                .stream()
                .filter(ownership -> ownership.getBook() != null)
                .filter(ownership -> ownership.getBook().getId() != null)
                .filter(ownership -> ownership.getBook().getId().equals(bookId))
                .findFirst()
                .orElse(null);
    }

    private BookHolding findHoldingByBookId(Long bookId) {
        return bookHoldingRepository.findAll()
                .stream()
                .filter(holding -> holding.getBook() != null)
                .filter(holding -> holding.getBook().getId() != null)
                .filter(holding -> holding.getBook().getId().equals(bookId))
                .findFirst()
                .orElse(null);
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "User not found: " + userId));
    }

    private Book findBookOrThrow(Long bookId) {
        return bookRepository.findById(bookId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Book not found: " + bookId));
    }

    private BorrowRequest findBorrowRequestOrThrow(Long borrowRequestId) {
        return borrowRequestRepository.findById(borrowRequestId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Borrow request not found: " + borrowRequestId));
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}