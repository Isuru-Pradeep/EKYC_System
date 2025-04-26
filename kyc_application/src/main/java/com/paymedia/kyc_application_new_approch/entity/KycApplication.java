package com.paymedia.kyc_application_new_approch.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "kyc_applications")
@Data
public class KycApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @Enumerated(EnumType.STRING)
    private KycStatus status = KycStatus.SUBMITTED;

    private String fullName;
    private String phoneNumber;
    private LocalDate dob;
    private String address;
    private String idType;
    private String idNumber;
    private String idDocumentUrl;

    @OneToMany(mappedBy = "application", cascade = CascadeType.ALL)
    private List<Document> supportingDocuments = new ArrayList<>();

    @OneToMany(mappedBy = "application", cascade = CascadeType.ALL)
    private List<ChatMessage> chatMessages = new ArrayList<>();

    private String reviewBy;

    private String reviewNotes;

    private LocalDateTime reviewedAt;

    private String approvedBy;

    private LocalDateTime approvedAt;

    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime updatedAt = LocalDateTime.now();

    public enum KycStatus {
        SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED
    }
}