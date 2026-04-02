package com.murat.book_exchange_api.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.murat.book_exchange_api.service.LoanReminderService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@RequiredArgsConstructor
@Slf4j
public class LoanReminderScheduler {

    private final LoanReminderService loanReminderService;

    @Scheduled(cron = "0 0 8 * * *")
    public void runDailyReminders() {
        int dueSoonCount = loanReminderService.generateDueSoonReminders();
        int overdueCount = loanReminderService.generateOverdueReminders();

        log.info("Loan reminder scheduler finished. dueSoonCreated={}, overdueCreated={}",
                dueSoonCount, overdueCount);
    }
}