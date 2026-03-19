package com.murat.book_exchange_api.controller;

import com.murat.book_exchange_api.controller.request.CreateBookRequest;
import com.murat.book_exchange_api.controller.response.BookResponse;
import com.murat.book_exchange_api.service.BookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService;

    @PostMapping
    public BookResponse createBook(@Valid @RequestBody CreateBookRequest request) {
        return bookService.createBook(request);
    }
}