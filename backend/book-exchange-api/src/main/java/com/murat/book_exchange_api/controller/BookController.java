package com.murat.book_exchange_api.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.request.DonateBookRequest;
import com.murat.book_exchange_api.controller.request.GiftBookRequest;
import com.murat.book_exchange_api.controller.request.LoanBookRequest;
import com.murat.book_exchange_api.controller.request.ReserveBookRequest;
import com.murat.book_exchange_api.controller.request.ReturnBookRequest;
import com.murat.book_exchange_api.controller.response.BookDetailResponse;
import com.murat.book_exchange_api.controller.response.BookResponse;
import com.murat.book_exchange_api.service.BookService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService;

    @PostMapping
    public BookResponse createBook(@Valid @RequestBody CreateBookRequest request) {
        return bookService.createBook(request);
    }

    @PostMapping("/{id}/reserve")
    public BookDetailResponse reserveBook(@PathVariable Long id, @Valid @RequestBody ReserveBookRequest request) {
        return bookService.reserveBook(id, request);
    }

    @PostMapping("/{id}/loan")
    public BookDetailResponse loanBook(@PathVariable Long id, @Valid @RequestBody LoanBookRequest request) {
        return bookService.loanBook(id, request);
    }

    @PostMapping("/{id}/return")
    public BookDetailResponse returnBook(@PathVariable Long id, @Valid @RequestBody ReturnBookRequest request) {
        return bookService.returnBook(id, request);
    }

    @PostMapping("/{id}/gift")
    public BookDetailResponse giftBook(@PathVariable Long id, @Valid @RequestBody GiftBookRequest request) {
        return bookService.giftBook(id, request);
    }

    @PostMapping("/{id}/donate")
    public BookDetailResponse donateBook(@PathVariable Long id, @Valid @RequestBody DonateBookRequest request) {
        return bookService.donateBook(id, request);
    }

    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBooks();
    }

    @GetMapping("/{id}")
    public BookDetailResponse getBookById(@PathVariable Long id) {
        return bookService.getBookById(id);
    }
}