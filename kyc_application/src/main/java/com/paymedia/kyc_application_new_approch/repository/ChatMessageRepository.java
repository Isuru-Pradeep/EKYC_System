package com.paymedia.kyc_application_new_approch.repository;

import com.paymedia.kyc_application_new_approch.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByApplicationId(Long applicationId);
}
