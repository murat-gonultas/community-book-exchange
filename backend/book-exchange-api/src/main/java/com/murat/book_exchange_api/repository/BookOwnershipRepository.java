package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookOwnership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BookOwnershipRepository extends JpaRepository<BookOwnership, Long> {
    Optional<BookOwnership> findByBook(Book book);
}