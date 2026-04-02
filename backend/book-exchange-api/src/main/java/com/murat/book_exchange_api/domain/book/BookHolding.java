package com.murat.book_exchange_api.domain.book;

import java.time.Instant;

import com.murat.book_exchange_api.domain.community.CommunityShelf;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookHolding {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "book_id", unique = true, nullable = false)
    private Book book;

    @ManyToOne
    @JoinColumn(name = "current_holder_user_id")
    private User currentHolderUser;

    @ManyToOne
    @JoinColumn(name = "current_shelf_id")
    private CommunityShelf currentShelf;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookStatus status;

    private Instant loanStartAt;

    private Instant dueAt;

    @Column(nullable = false)
    private Integer loanExtendedCount = 0;

    private Instant lastExtendedAt;
}