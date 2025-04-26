package com.paymedia.kyc_application_new_approch.controller;

import com.paymedia.kyc_application_new_approch.dto.DocumentDTO;
import com.paymedia.kyc_application_new_approch.service.DocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/documents")
@RequiredArgsConstructor
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping("/{applicationId}")
    public ResponseEntity<DocumentDTO> uploadDocument(
            @PathVariable Long applicationId,
            @RequestParam("file") MultipartFile file,
            @RequestParam String documentType,
            @RequestParam(required = false) String specialNote) throws IOException {
        return ResponseEntity.ok(documentService.uploadDocument(applicationId, file, documentType, specialNote));
    }

    @GetMapping("/application/{applicationId}")
    public ResponseEntity<List<DocumentDTO>> getDocumentsByApplication(@PathVariable Long applicationId) {
        return ResponseEntity.ok(documentService.getDocumentsByApplication(applicationId));
    }
}
