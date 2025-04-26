package com.paymedia.kyc_application_new_approch.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessageDTO {
    private Long id;
    private String message;
    private boolean systemMessage;
    private LocalDateTime createdAt;
}