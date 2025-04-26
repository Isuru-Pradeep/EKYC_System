package com.paymedia.kyc_application_new_approch.dto;

import lombok.Data;

@Data
public class DocumentDTO {
    private Long id;
    private String documentUrl;
    private String documentType;
    private String specialNote;
}
