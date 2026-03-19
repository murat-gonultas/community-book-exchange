package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.book.Book;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<Book, Long> {
}