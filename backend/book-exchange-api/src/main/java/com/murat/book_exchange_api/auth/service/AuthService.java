package com.murat.book_exchange_api.auth.service;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.murat.book_exchange_api.auth.dto.CurrentUserResponse;
import com.murat.book_exchange_api.auth.dto.LoginRequest;
import com.murat.book_exchange_api.auth.dto.LoginResponse;
import com.murat.book_exchange_api.auth.dto.MessageResponse;
import com.murat.book_exchange_api.auth.dto.RegisterRequest;
import com.murat.book_exchange_api.auth.dto.RegisterResponse;
import com.murat.book_exchange_api.auth.dto.UserSummaryResponse;
import com.murat.book_exchange_api.auth.dto.VerifyEmailRequest;
import com.murat.book_exchange_api.auth.model.EmailVerificationToken;
import com.murat.book_exchange_api.auth.repository.EmailVerificationTokenRepository;
import com.murat.book_exchange_api.auth.security.JwtService;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.domain.user.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository emailVerificationTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Value("${app.jwt.expiration-ms}")
    private long jwtExpirationMs;

    @Value("${app.auth.expose-verification-token:true}")
    private boolean exposeVerificationToken;

    public RegisterResponse register(RegisterRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());

        if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already in use");
        }

        User user = User.builder()
                .name(request.getName().trim())
                .email(normalizedEmail)
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .build();

        User savedUser = userRepository.save(user);

        EmailVerificationToken verificationToken = EmailVerificationToken.builder()
                .user(savedUser)
                .expiresAt(LocalDateTime.now().plusDays(1))
                .build();

        EmailVerificationToken savedToken = emailVerificationTokenRepository.save(verificationToken);

        return new RegisterResponse(
                savedUser.getId(),
                savedUser.getEmail(),
                savedUser.isEmailVerified(),
                exposeVerificationToken ? savedToken.getToken() : null);
    }

    public MessageResponse verifyEmail(VerifyEmailRequest request) {
        EmailVerificationToken verificationToken = emailVerificationTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid verification token"));

        if (verificationToken.isUsed()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verification token has already been used");
        }

        if (verificationToken.isExpired()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verification token has expired");
        }

        User user = verificationToken.getUser();
        user.setEmailVerified(true);
        verificationToken.markUsed();

        userRepository.save(user);
        emailVerificationTokenRepository.save(verificationToken);

        return new MessageResponse("Email verified successfully");
    }

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());

        User user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        if (!user.isActive()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User account is inactive");
        }

        if (!user.isEmailVerified()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Email address is not verified");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String accessToken = jwtService.generateToken(user);

        return new LoginResponse(
                accessToken,
                "Bearer",
                jwtExpirationMs / 1000,
                new UserSummaryResponse(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getSystemRole()));
    }

    @Transactional(readOnly = true)
    public CurrentUserResponse getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "No authenticated user found");
        }

        User user = userRepository.findByEmailIgnoreCase(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Authenticated user not found"));

        return new CurrentUserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.isEmailVerified(),
                user.isActive(),
                user.getSystemRole());
    }

    private String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }
}