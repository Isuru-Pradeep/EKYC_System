package com.paymedia.kyc_application_new_approch.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
@Data
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "application_id", nullable = false)
    private KycApplication application;

    @Column(nullable = false)
    private String message;

    private boolean isSystemMessage = false;

    private LocalDateTime createdAt = LocalDateTime.now();
}