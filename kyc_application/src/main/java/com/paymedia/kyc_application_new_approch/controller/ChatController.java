package com.paymedia.kyc_application_new_approch.controller;

import com.paymedia.kyc_application_new_approch.dto.ChatMessageDTO;
import com.paymedia.kyc_application_new_approch.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/{applicationId}")
    public ResponseEntity<ChatMessageDTO> addMessage(
            @PathVariable Long applicationId,
            @RequestParam String message,
            @RequestParam(defaultValue = "false") boolean isSystemMessage) {
        return ResponseEntity.ok(chatService.addMessage(applicationId, message, isSystemMessage));
    }

    @GetMapping("/{applicationId}")
    public ResponseEntity<List<ChatMessageDTO>> getMessages(@PathVariable Long applicationId) {
        return ResponseEntity.ok(chatService.getChatMessages(applicationId));
    }
}
