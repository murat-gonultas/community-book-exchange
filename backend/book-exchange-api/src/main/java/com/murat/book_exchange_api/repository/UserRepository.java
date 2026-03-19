package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
}