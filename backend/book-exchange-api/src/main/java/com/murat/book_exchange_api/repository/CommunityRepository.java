package com.murat.book_exchange_api.repository;

import com.murat.book_exchange_api.domain.community.Community;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommunityRepository extends JpaRepository<Community, Long> {
}