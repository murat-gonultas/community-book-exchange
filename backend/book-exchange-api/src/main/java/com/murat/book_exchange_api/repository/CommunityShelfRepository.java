package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.community.CommunityShelf;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommunityShelfRepository extends JpaRepository<CommunityShelf, Long> {
}