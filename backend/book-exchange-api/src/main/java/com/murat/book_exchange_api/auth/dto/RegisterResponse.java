package com.murat.book_exchange_api.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RegisterResponse {

    private Long userId;
    private String email;
    private boolean emailVerified;
    private String verificationToken;
}