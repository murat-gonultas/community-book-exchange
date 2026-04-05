package com.murat.book_exchange_api.auth.dto;

import com.murat.book_exchange_api.auth.model.SystemRole;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CurrentUserResponse {

    private Long id;
    private String name;
    private String email;
    private boolean emailVerified;
    private boolean active;
    private SystemRole systemRole;
}