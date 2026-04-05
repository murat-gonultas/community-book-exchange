package com.murat.book_exchange_api.controller.request;

public class LoanBookRequest {

    private Long loanedToUserId;
    private String note;

    public Long getLoanedToUserId() {
        return loanedToUserId;
    }

    public void setLoanedToUserId(Long loanedToUserId) {
        this.loanedToUserId = loanedToUserId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}