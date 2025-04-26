package com.paymedia.kyc_application_new_approch.dto;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class KycApplicationDTO {
    private Long id;
    private String fullName;
    private String phoneNumber;
    private LocalDate dob;
    private String address;
    private String idType;
    private String idNumber;
    private String idDocumentUrl;
    private List<DocumentDTO> supportingDocuments;
    private List<ChatMessageDTO> chatMessages;
    private KycApplication.KycStatus status;

    // Review fields
    private String reviewBy;
    private String reviewNotes;
    private LocalDateTime reviewedAt;
    private String approvedBy;
    private LocalDateTime approvedAt;
}