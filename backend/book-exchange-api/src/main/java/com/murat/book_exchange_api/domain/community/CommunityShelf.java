package com.murat.book_exchange_api.domain.community;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommunityShelf {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String locationDescription;

    @ManyToOne
    @JoinColumn(name = "community_id")
    private Community community;
}