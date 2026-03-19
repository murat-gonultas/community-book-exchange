package com.murat.book_exchange_api.domain.book;

import com.murat.book_exchange_api.domain.community.Community;
import com.murat.book_exchange_api.domain.enums.OwnershipType;
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
public class BookOwnership {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "book_id", unique = true, nullable = false)
    private Book book;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OwnershipType ownershipType;

    @ManyToOne
    @JoinColumn(name = "owner_user_id")
    private User ownerUser;

    @ManyToOne
    @JoinColumn(name = "owner_community_id")
    private Community ownerCommunity;

    private Instant ownershipAcquiredAt;
}