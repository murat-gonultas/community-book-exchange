package com.murat.book_exchange_api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.lang.reflect.Field;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

import com.murat.book_exchange_api.auth.model.SystemRole;
import com.murat.book_exchange_api.controller.request.ApproveBorrowRequest;
import com.murat.book_exchange_api.controller.request.CreateBorrowRequest;
import com.murat.book_exchange_api.controller.request.FulfillBorrowRequest;
import com.murat.book_exchange_api.controller.request.RejectBorrowRequest;
import com.murat.book_exchange_api.controller.response.BookDetailResponse;
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

@ExtendWith(MockitoExtension.class)
class BorrowRequestServiceTest {

    @Mock
    private BorrowRequestRepository borrowRequestRepository;

    @Mock
    private BookRepository bookRepository;

    @Mock
    private BookOwnershipRepository bookOwnershipRepository;

    @Mock
    private BookHoldingRepository bookHoldingRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private BookService bookService;

    @InjectMocks
    private BorrowRequestService borrowRequestService;

    @Test
    void createBorrowRequest_shouldSucceedForAvailableBook() {
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);
        BookHolding holding = holding(book, owner, BookStatus.AVAILABLE);

        when(userRepository.findById(3L)).thenReturn(Optional.of(requester));
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(borrowRequestRepository.existsByBookIdAndRequesterIdAndStatusIn(any(), any(), any())).thenReturn(false);
        when(borrowRequestRepository.save(any(BorrowRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CreateBorrowRequest request = new CreateBorrowRequest();
        request.setMessage("I would like to borrow this for two weeks.");

        BorrowRequest created = borrowRequestService.createBorrowRequest(3L, 1L, request);

        assertNotNull(created);
        assertEquals(BorrowRequestStatus.PENDING, created.getStatus());
        assertEquals(1L, created.getBook().getId());
        assertEquals(3L, created.getRequester().getId());
        assertEquals("I would like to borrow this for two weeks.", created.getMessage());
    }

    @Test
    void createBorrowRequest_shouldFailForOwnBook() {
        User ownerAndRequester = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, ownerAndRequester);

        when(userRepository.findById(4L)).thenReturn(Optional.of(ownerAndRequester));
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));

        ResponseStatusException ex = assertThrows(
                ResponseStatusException.class,
                () -> borrowRequestService.createBorrowRequest(4L, 1L, new CreateBorrowRequest()));

        assertEquals(400, ex.getStatusCode().value());
    }

    @Test
    void createBorrowRequest_shouldFailWhenDuplicateActiveRequestExists() {
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);
        BookHolding holding = holding(book, owner, BookStatus.AVAILABLE);

        when(userRepository.findById(3L)).thenReturn(Optional.of(requester));
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(borrowRequestRepository.existsByBookIdAndRequesterIdAndStatusIn(any(), any(), any())).thenReturn(true);

        ResponseStatusException ex = assertThrows(
                ResponseStatusException.class,
                () -> borrowRequestService.createBorrowRequest(3L, 1L, new CreateBorrowRequest()));

        assertEquals(409, ex.getStatusCode().value());
    }

    @Test
    void createBorrowRequest_shouldFailWhenBookIsNotAvailable() {
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);
        BookHolding holding = holding(book, owner, BookStatus.ON_LOAN);

        when(userRepository.findById(3L)).thenReturn(Optional.of(requester));
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));

        ResponseStatusException ex = assertThrows(
                ResponseStatusException.class,
                () -> borrowRequestService.createBorrowRequest(3L, 1L, new CreateBorrowRequest()));

        assertEquals(409, ex.getStatusCode().value());
    }

    @Test
    void getIncomingRequests_shouldReturnOnlyRequestsActorCanDecide() {
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        User anotherOwner = user(5L, "Another Owner", "another-owner@test.local", SystemRole.USER);
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);

        Book ownerBook = book(1L, "Owner Book", "Author A");
        Book otherBook = book(2L, "Other Book", "Author B");

        BookOwnership ownerBookOwnership = ownership(ownerBook, owner);
        BookOwnership otherBookOwnership = ownership(otherBook, anotherOwner);

        BorrowRequest ownerRequest = borrowRequest(11L, ownerBook, requester, BorrowRequestStatus.PENDING);
        BorrowRequest otherRequest = borrowRequest(12L, otherBook, requester, BorrowRequestStatus.PENDING);

        when(userRepository.findById(4L)).thenReturn(Optional.of(owner));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownerBookOwnership, otherBookOwnership));
        when(borrowRequestRepository.findAll()).thenReturn(List.of(ownerRequest, otherRequest));

        List<BorrowRequest> incoming = borrowRequestService.getIncomingRequests(4L);

        assertEquals(1, incoming.size());
        assertEquals(11L, incoming.get(0).getId());
    }

    @Test
    void approveBorrowRequest_shouldSucceedAndUpdateTimestamps() {
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);
        BookHolding holding = holding(book, owner, BookStatus.AVAILABLE);

        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.PENDING);
        LocalDateTime oldUpdatedAt = LocalDateTime.now().minusMinutes(10);
        borrowRequest.setUpdatedAt(oldUpdatedAt);

        when(userRepository.findById(4L)).thenReturn(Optional.of(owner));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(borrowRequestRepository.findByBookIdAndStatusOrderByCreatedAtDesc(1L, BorrowRequestStatus.APPROVED))
                .thenReturn(List.of());
        when(borrowRequestRepository.save(any(BorrowRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ApproveBorrowRequest request = new ApproveBorrowRequest();
        request.setDecisionNote("You can pick it up on Friday.");

        BorrowRequest approved = borrowRequestService.approveBorrowRequest(4L, 1L, request);

        assertEquals(BorrowRequestStatus.APPROVED, approved.getStatus());
        assertEquals("You can pick it up on Friday.", approved.getDecisionNote());
        assertEquals(4L, approved.getDecidedBy().getId());
        assertNotNull(approved.getDecidedAt());
        assertTrue(approved.getUpdatedAt().isAfter(oldUpdatedAt));
    }

    @Test
    void rejectBorrowRequest_shouldSucceed() {
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);

        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.PENDING);

        when(userRepository.findById(4L)).thenReturn(Optional.of(owner));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(borrowRequestRepository.save(any(BorrowRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        RejectBorrowRequest request = new RejectBorrowRequest();
        request.setRejectionReason("I still need this book this week.");
        request.setDecisionNote("Please ask again later.");

        BorrowRequest rejected = borrowRequestService.rejectBorrowRequest(4L, 1L, request);

        assertEquals(BorrowRequestStatus.REJECTED, rejected.getStatus());
        assertEquals("I still need this book this week.", rejected.getRejectionReason());
        assertEquals("Please ask again later.", rejected.getDecisionNote());
        assertEquals(4L, rejected.getDecidedBy().getId());
        assertNotNull(rejected.getDecidedAt());
        assertNotNull(rejected.getUpdatedAt());
    }

    @Test
    void cancelBorrowRequest_shouldSucceedForPendingRequestOwner() {
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");

        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.PENDING);
        LocalDateTime oldUpdatedAt = LocalDateTime.now().minusMinutes(10);
        borrowRequest.setUpdatedAt(oldUpdatedAt);

        when(userRepository.findById(3L)).thenReturn(Optional.of(requester));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));
        when(borrowRequestRepository.save(any(BorrowRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        BorrowRequest cancelled = borrowRequestService.cancelBorrowRequest(3L, 1L);

        assertEquals(BorrowRequestStatus.CANCELLED, cancelled.getStatus());
        assertTrue(cancelled.getUpdatedAt().isAfter(oldUpdatedAt));
    }

    @Test
    void cancelBorrowRequest_shouldFailWhenRequestAlreadyApproved() {
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");

        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.APPROVED);

        when(userRepository.findById(3L)).thenReturn(Optional.of(requester));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));

        ResponseStatusException ex = assertThrows(
                ResponseStatusException.class,
                () -> borrowRequestService.cancelBorrowRequest(3L, 1L));

        assertEquals(409, ex.getStatusCode().value());
    }

    @Test
    void fulfillBorrowRequest_shouldConvertApprovedRequestIntoLoan() {
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BookOwnership ownership = ownership(book, owner);
        BookHolding holding = holding(book, owner, BookStatus.AVAILABLE);

        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.APPROVED);
        LocalDateTime oldUpdatedAt = LocalDateTime.now().minusMinutes(10);
        borrowRequest.setUpdatedAt(oldUpdatedAt);

        when(userRepository.findById(4L)).thenReturn(Optional.of(owner));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));
        when(bookOwnershipRepository.findAll()).thenReturn(List.of(ownership));
        when(bookHoldingRepository.findAll()).thenReturn(List.of(holding));
        when(bookService.loanBook(any(), any())).thenReturn(mock(BookDetailResponse.class));
        when(borrowRequestRepository.save(any(BorrowRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        FulfillBorrowRequest request = new FulfillBorrowRequest();
        request.setNote("Physical handover completed.");

        BorrowRequest fulfilled = borrowRequestService.fulfillBorrowRequest(4L, 1L, request);

        assertEquals(BorrowRequestStatus.FULFILLED, fulfilled.getStatus());
        assertEquals("Physical handover completed.", fulfilled.getDecisionNote());
        assertEquals(4L, fulfilled.getDecidedBy().getId());
        assertNotNull(fulfilled.getDecidedAt());
        assertTrue(fulfilled.getUpdatedAt().isAfter(oldUpdatedAt));
    }

    @Test
    void fulfillBorrowRequest_shouldFailWhenRequestIsNotApproved() {
        User owner = user(4L, "Owner Test", "owner@test.local", SystemRole.USER);
        User requester = user(3L, "Requester Test", "requester@test.local", SystemRole.USER);
        Book book = book(1L, "Borrow Request Test Book", "Test Author");
        BorrowRequest borrowRequest = borrowRequest(1L, book, requester, BorrowRequestStatus.PENDING);

        when(userRepository.findById(4L)).thenReturn(Optional.of(owner));
        when(borrowRequestRepository.findById(1L)).thenReturn(Optional.of(borrowRequest));

        ResponseStatusException ex = assertThrows(
                ResponseStatusException.class,
                () -> borrowRequestService.fulfillBorrowRequest(4L, 1L, new FulfillBorrowRequest()));

        assertEquals(409, ex.getStatusCode().value());
    }

    private User user(Long id, String name, String email, SystemRole systemRole) {
        User user = new User();
        setField(user, "id", id);
        setField(user, "name", name);
        setField(user, "email", email);
        setField(user, "systemRole", systemRole);
        return user;
    }

    private Book book(Long id, String title, String author) {
        Book book = new Book();
        setField(book, "id", id);
        setField(book, "title", title);
        setField(book, "author", author);
        return book;
    }

    private BookOwnership ownership(Book book, User ownerUser) {
        BookOwnership ownership = new BookOwnership();
        setField(ownership, "id", 100L);
        setField(ownership, "book", book);
        setField(ownership, "ownerUser", ownerUser);
        setField(ownership, "ownershipAcquiredAt", Instant.now());
        return ownership;
    }

    private BookHolding holding(Book book, User currentHolderUser, BookStatus status) {
        BookHolding holding = new BookHolding();
        setField(holding, "id", 200L);
        setField(holding, "book", book);
        setField(holding, "currentHolderUser", currentHolderUser);
        setField(holding, "status", status);
        setField(holding, "loanExtendedCount", 0);
        return holding;
    }

    private BorrowRequest borrowRequest(Long id, Book book, User requester, BorrowRequestStatus status) {
        BorrowRequest borrowRequest = new BorrowRequest();
        borrowRequest.setId(id);
        borrowRequest.setBook(book);
        borrowRequest.setRequester(requester);
        borrowRequest.setStatus(status);
        borrowRequest.setCreatedAt(LocalDateTime.now().minusMinutes(20));
        borrowRequest.setUpdatedAt(LocalDateTime.now().minusMinutes(20));
        return borrowRequest;
    }

    private void setField(Object target, String fieldName, Object value) {
        try {
            Class<?> current = target.getClass();
            while (current != null) {
                try {
                    Field field = current.getDeclaredField(fieldName);
                    field.setAccessible(true);
                    field.set(target, value);
                    return;
                } catch (NoSuchFieldException ignored) {
                    current = current.getSuperclass();
                }
            }

            throw new IllegalArgumentException(
                    "Field '" + fieldName + "' not found on " + target.getClass().getName());
        } catch (IllegalAccessException e) {
            throw new RuntimeException("Failed to set field '" + fieldName + "'", e);
        }
    }
}