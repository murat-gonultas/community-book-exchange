package com.murat.book_exchange_api.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.Optional;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.server.ResponseStatusException;

import com.murat.book_exchange_api.auth.dto.CurrentUserResponse;
import com.murat.book_exchange_api.auth.dto.LoginRequest;
import com.murat.book_exchange_api.auth.dto.LoginResponse;
import com.murat.book_exchange_api.auth.dto.MessageResponse;
import com.murat.book_exchange_api.auth.dto.RegisterRequest;
import com.murat.book_exchange_api.auth.dto.RegisterResponse;
import com.murat.book_exchange_api.auth.dto.VerifyEmailRequest;
import com.murat.book_exchange_api.auth.model.EmailVerificationToken;
import com.murat.book_exchange_api.auth.model.SystemRole;
import com.murat.book_exchange_api.auth.repository.EmailVerificationTokenRepository;
import com.murat.book_exchange_api.auth.security.JwtService;
import com.murat.book_exchange_api.domain.user.User;
import com.murat.book_exchange_api.domain.user.UserRepository;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationTokenRepository emailVerificationTokenRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthService authService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(authService, "jwtExpirationMs", 3600000L);
        ReflectionTestUtils.setField(authService, "exposeVerificationToken", true);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void register_shouldCreateUserAndToken() {
        RegisterRequest request = new RegisterRequest();
        request.setName("Murat");
        request.setEmail("murat@example.com");
        request.setPassword("Secret123!");

        when(userRepository.existsByEmailIgnoreCase("murat@example.com")).thenReturn(false);
        when(passwordEncoder.encode("Secret123!")).thenReturn("hashed-password");

        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(1L);
            return user;
        });

        when(emailVerificationTokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> {
            EmailVerificationToken token = invocation.getArgument(0);
            token.setToken("verify-token-123");
            return token;
        });

        RegisterResponse response = authService.register(request);

        assertNotNull(response);
        assertEquals(1L, response.getUserId());
        assertEquals("murat@example.com", response.getEmail());
        assertFalse(response.isEmailVerified());
        assertEquals("verify-token-123", response.getVerificationToken());

        verify(userRepository).save(any(User.class));
        verify(emailVerificationTokenRepository).save(any(EmailVerificationToken.class));
    }

    @Test
    void register_shouldFailWhenEmailAlreadyExists() {
        RegisterRequest request = new RegisterRequest();
        request.setName("Murat");
        request.setEmail("murat@example.com");
        request.setPassword("Secret123!");

        when(userRepository.existsByEmailIgnoreCase("murat@example.com")).thenReturn(true);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> authService.register(request));

        assertEquals(HttpStatus.CONFLICT.value(), ex.getStatusCode().value());
        assertEquals("Email is already in use", ex.getReason());
    }

    @Test
    void verifyEmail_shouldMarkUserVerified() {
        User user = buildUser(1L, "Murat", "murat@example.com", false, true);
        EmailVerificationToken token = EmailVerificationToken.builder()
                .id(1L)
                .user(user)
                .token("verify-token-123")
                .expiresAt(LocalDateTime.now().plusHours(12))
                .build();

        VerifyEmailRequest request = new VerifyEmailRequest();
        request.setToken("verify-token-123");

        when(emailVerificationTokenRepository.findByToken("verify-token-123")).thenReturn(Optional.of(token));

        MessageResponse response = authService.verifyEmail(request);

        assertEquals("Email verified successfully", response.getMessage());
        assertTrue(user.isEmailVerified());
        assertNotNull(token.getUsedAt());

        verify(userRepository).save(user);
        verify(emailVerificationTokenRepository).save(token);
    }

    @Test
    void login_shouldFailWhenEmailNotVerified() {
        User user = buildUser(1L, "Ayse", "ayse@example.com", false, true);
        user.setPasswordHash("hashed-password");

        LoginRequest request = new LoginRequest();
        request.setEmail("ayse@example.com");
        request.setPassword("Secret123!");

        when(userRepository.findByEmailIgnoreCase("ayse@example.com")).thenReturn(Optional.of(user));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> authService.login(request));

        assertEquals(HttpStatus.FORBIDDEN.value(), ex.getStatusCode().value());
        assertEquals("Email address is not verified", ex.getReason());
    }

    @Test
    void login_shouldReturnJwtWhenCredentialsAreValid() {
        User user = buildUser(1L, "Murat", "murat@example.com", true, true);
        user.setPasswordHash("hashed-password");

        LoginRequest request = new LoginRequest();
        request.setEmail("murat@example.com");
        request.setPassword("Secret123!");

        when(userRepository.findByEmailIgnoreCase("murat@example.com")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("Secret123!", "hashed-password")).thenReturn(true);
        when(jwtService.generateToken(user)).thenReturn("jwt-token");

        LoginResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("jwt-token", response.getAccessToken());
        assertEquals("Bearer", response.getTokenType());
        assertEquals(3600L, response.getExpiresIn());
        assertEquals("murat@example.com", response.getUser().getEmail());
        assertEquals(SystemRole.USER, response.getUser().getSystemRole());

        verify(userRepository).save(user);
    }

    @Test
    void getCurrentUser_shouldReturnAuthenticatedUser() {
        User user = buildUser(1L, "Murat", "murat@example.com", true, true);

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken("murat@example.com", null));

        when(userRepository.findByEmailIgnoreCase("murat@example.com")).thenReturn(Optional.of(user));

        CurrentUserResponse response = authService.getCurrentUser();

        assertNotNull(response);
        assertEquals(1L, response.getId());
        assertEquals("Murat", response.getName());
        assertEquals("murat@example.com", response.getEmail());
        assertTrue(response.isEmailVerified());
        assertTrue(response.isActive());
        assertEquals(SystemRole.USER, response.getSystemRole());
    }

    @Test
    void getCurrentUser_shouldFailWhenNoAuthenticationExists() {
        SecurityContextHolder.clearContext();

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> authService.getCurrentUser());

        assertEquals(HttpStatus.UNAUTHORIZED.value(), ex.getStatusCode().value());
        assertEquals("No authenticated user found", ex.getReason());
    }

    private User buildUser(Long id, String name, String email, boolean verified, boolean active) {
        return User.builder()
                .id(id)
                .name(name)
                .email(email)
                .passwordHash("hashed-password")
                .emailVerified(verified)
                .active(active)
                .systemRole(SystemRole.USER)
                .build();
    }
}