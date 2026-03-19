package com.murat.book_exchange_api.controller;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.response.BookDetailResponse;
import com.murat.book_exchange_api.controller.response.BookResponse;
import com.murat.book_exchange_api.controller.request.ReserveBookRequest;
import com.murat.book_exchange_api.service.BookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBooks();
    }

    @GetMapping("/{id}")
    public BookDetailResponse getBookById(@PathVariable Long id) {
        return bookService.getBookById(id);
    }
}