package com.paymedia.kyc_application_new_approch.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "documents")
@Data
@Setter
@Getter
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "application_id", nullable = false)
    private KycApplication application;

    @Column(nullable = false)
    private String documentUrl;

    private String documentType;

    private String specialNote;

    private LocalDateTime createdAt = LocalDateTime.now();
}