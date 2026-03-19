package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BookHoldingRepository extends JpaRepository<BookHolding, Long> {
    Optional<BookHolding> findByBook(Book book);
}