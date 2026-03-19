package com.murat.book_exchange_api.domain.book;

import com.murat.book_exchange_api.domain.community.CommunityShelf;
import com.murat.book_exchange_api.domain.enums.BookStatus;
import com.murat.book_exchange_api.domain.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

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

    private Instant reservedUntil;
}