package com.paymedia.kyc_application_new_approch.service;

import com.paymedia.kyc_application_new_approch.dto.ChatMessageDTO;
import com.paymedia.kyc_application_new_approch.entity.ChatMessage;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import com.paymedia.kyc_application_new_approch.repository.ChatMessageRepository;
import com.paymedia.kyc_application_new_approch.repository.KycApplicationRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final KycApplicationRepository kycApplicationRepository;
    private final ModelMapper modelMapper;

    @Transactional
    public ChatMessageDTO addMessage(Long applicationId, String message, boolean isSystemMessage) {
        KycApplication application = kycApplicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setApplication(application);
        chatMessage.setMessage(message);
        chatMessage.setSystemMessage(isSystemMessage);

        chatMessage = chatMessageRepository.save(chatMessage);
        return modelMapper.map(chatMessage, ChatMessageDTO.class);
    }

    public List<ChatMessageDTO> getChatMessages(Long applicationId) {
        return chatMessageRepository.findByApplicationId(applicationId).stream()
                .map(msg -> modelMapper.map(msg, ChatMessageDTO.class))
                .collect(Collectors.toList());
    }
}