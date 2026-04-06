package com.murat.book_exchange_api.controller;

import static org.springframework.http.HttpStatus.UNAUTHORIZED;

import java.security.Principal;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.murat.book_exchange_api.controller.request.ApproveBorrowRequest;
import com.murat.book_exchange_api.controller.request.CreateBorrowRequest;
import com.murat.book_exchange_api.controller.request.FulfillBorrowRequest;
import com.murat.book_exchange_api.controller.request.RejectBorrowRequest;
import com.murat.book_exchange_api.controller.response.BorrowRequestResponse;
import com.murat.book_exchange_api.domain.request.BorrowRequest;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.domain.user.UserRepository;
import com.murat.book_exchange_api.service.BorrowRequestService;

import jakarta.validation.Valid;

/**
 * REST controller for the borrow request workflow.
 *
 * <p>
 * All endpoints in this controller expect an authenticated user.
 * The authenticated user's email is taken from the security principal
 * and resolved to the internal User entity.
 */
@RestController
@Transactional(readOnly = true)
public class BorrowRequestController {

    private final BorrowRequestService borrowRequestService;
    private final UserRepository userRepository;

    public BorrowRequestController(
            BorrowRequestService borrowRequestService,
            UserRepository userRepository) {
        this.borrowRequestService = borrowRequestService;
        this.userRepository = userRepository;
    }

    @PostMapping("/api/books/{bookId}/borrow-requests")
    @Transactional
    public ResponseEntity<BorrowRequestResponse> createBorrowRequest(
            @PathVariable Long bookId,
            @Valid @RequestBody(required = false) CreateBorrowRequest request,
            Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        BorrowRequest created = borrowRequestService.createBorrowRequest(
                currentUser.getId(),
                bookId,
                request);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(BorrowRequestResponse.from(created));
    }

    @GetMapping("/api/borrow-requests/me")
    public List<BorrowRequestResponse> getMyBorrowRequests(Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        return borrowRequestService.getMyRequests(currentUser.getId())
                .stream()
                .map(BorrowRequestResponse::from)
                .toList();
    }

    @GetMapping("/api/borrow-requests/incoming")
    public List<BorrowRequestResponse> getIncomingBorrowRequests(Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        return borrowRequestService.getIncomingRequests(currentUser.getId())
                .stream()
                .map(BorrowRequestResponse::from)
                .toList();
    }

    @PostMapping("/api/borrow-requests/{borrowRequestId}/approve")
    @Transactional
    public BorrowRequestResponse approveBorrowRequest(
            @PathVariable Long borrowRequestId,
            @Valid @RequestBody(required = false) ApproveBorrowRequest request,
            Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        BorrowRequest updated = borrowRequestService.approveBorrowRequest(
                currentUser.getId(),
                borrowRequestId,
                request);

        return BorrowRequestResponse.from(updated);
    }

    @PostMapping("/api/borrow-requests/{borrowRequestId}/reject")
    @Transactional
    public BorrowRequestResponse rejectBorrowRequest(
            @PathVariable Long borrowRequestId,
            @Valid @RequestBody RejectBorrowRequest request,
            Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        BorrowRequest updated = borrowRequestService.rejectBorrowRequest(
                currentUser.getId(),
                borrowRequestId,
                request);

        return BorrowRequestResponse.from(updated);
    }

    @PostMapping("/api/borrow-requests/{borrowRequestId}/cancel")
    @Transactional
    public BorrowRequestResponse cancelBorrowRequest(
            @PathVariable Long borrowRequestId,
            Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        BorrowRequest updated = borrowRequestService.cancelBorrowRequest(
                currentUser.getId(),
                borrowRequestId);

        return BorrowRequestResponse.from(updated);
    }

    @PostMapping("/api/borrow-requests/{borrowRequestId}/fulfill")
    @Transactional
    public BorrowRequestResponse fulfillBorrowRequest(
            @PathVariable Long borrowRequestId,
            @Valid @RequestBody(required = false) FulfillBorrowRequest request,
            Principal principal) {
        User currentUser = resolveCurrentUser(principal);

        BorrowRequest updated = borrowRequestService.fulfillBorrowRequest(
                currentUser.getId(),
                borrowRequestId,
                request);

        return BorrowRequestResponse.from(updated);
    }

    private User resolveCurrentUser(Principal principal) {
        if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
            throw new ResponseStatusException(UNAUTHORIZED, "Authentication is required");
        }

        return userRepository.findByEmailIgnoreCase(principal.getName())
                .orElseThrow(() -> new ResponseStatusException(
                        UNAUTHORIZED,
                        "Authenticated user could not be resolved"));
    }
}