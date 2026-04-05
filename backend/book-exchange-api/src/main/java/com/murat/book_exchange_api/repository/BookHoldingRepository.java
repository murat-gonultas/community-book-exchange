package com.murat.book_exchange_api.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookHolding;

public interface BookHoldingRepository extends JpaRepository<BookHolding, Long> {
    Optional<BookHolding> findByBook(Book book);

    Optional<BookHolding> findByBook_Id(Long bookId);
}
