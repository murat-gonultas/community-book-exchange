package com.murat.book_exchange_api.controller;

import com.murat.book_exchange_api.domain.community.Community;
import com.murat.book_exchange_api.repository.CommunityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/communities")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityRepository communityRepository;

    @PostMapping
    public Community create(@RequestBody Community community) {
        return communityRepository.save(community);
    }

    @GetMapping
    public List<Community> getAll() {
        return communityRepository.findAll();
    }
}