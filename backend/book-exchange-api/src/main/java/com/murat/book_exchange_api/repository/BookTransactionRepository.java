package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.book.Book;
import com.murat.book_exchange_api.domain.book.BookTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookTransactionRepository extends JpaRepository<BookTransaction, Long> {
    List<BookTransaction> findByBookOrderByIdDesc(Book book);
}