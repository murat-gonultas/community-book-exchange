package com.murat.book_exchange_api.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.murat.book_exchange_api.controller.response.LoanReminderResponse;
import com.murat.book_exchange_api.service.LoanReminderService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/reminders")
@RequiredArgsConstructor
public class LoanReminderController {

    private final LoanReminderService loanReminderService;

    @PostMapping("/run")
    public ResponseEntity<Map<String, Integer>> runReminderGeneration() {
        int dueSoonCount = loanReminderService.generateDueSoonReminders();
        int overdueCount = loanReminderService.generateOverdueReminders();

        return ResponseEntity.ok(Map.of(
                "dueSoonCreated", dueSoonCount,
                "overdueCreated", overdueCount));
    }

    @GetMapping("/users/{userId}")
    public ResponseEntity<List<LoanReminderResponse>> getUserReminders(@PathVariable Long userId) {
        return ResponseEntity.ok(loanReminderService.getRemindersForUser(userId));
    }
}