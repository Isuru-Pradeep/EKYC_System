package com.paymedia.kyc_application_new_approch.service;

import com.paymedia.kyc_application_new_approch.dto.DocumentDTO;
import com.paymedia.kyc_application_new_approch.entity.Document;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import com.paymedia.kyc_application_new_approch.repository.DocumentRepository;
import com.paymedia.kyc_application_new_approch.repository.KycApplicationRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final KycApplicationRepository kycApplicationRepository;
    private final ModelMapper modelMapper;
    private final Path rootLocation = Paths.get("uploads");

    @Transactional
    public DocumentDTO uploadDocument(Long applicationId, MultipartFile file, String documentType, String specialNote) throws IOException {
        // ======== Validations ========
        if (applicationId == null) {
            throw new IllegalArgumentException("Application ID must not be null.");
        }

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Uploaded file must not be empty.");
        }

        if (file.getSize() > 10 * 1024 * 1024) { // 10MB limit
            throw new IllegalArgumentException("File size must not exceed 10MB.");
        }

        String contentType = file.getContentType();
        if (contentType == null ||
                !(
//                        contentType.equals("application/pdf") ||
                        contentType.equals("image/jpeg") ||
                        contentType.equals("image/jpg") ||
                        contentType.equals("image/png"))) {
            throw new IllegalArgumentException("Only JPG, JPEG, or PNG files are allowed.");
        }

        if (documentType == null || documentType.trim().isEmpty()) {
            throw new IllegalArgumentException("Document type must not be blank.");
        }
        // =====================================

        if (!Files.exists(rootLocation)) {
            Files.createDirectories(rootLocation);
        }

        String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Files.copy(file.getInputStream(), rootLocation.resolve(filename));

        KycApplication application = kycApplicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        Document document = new Document();
        document.setApplication(application);
        document.setDocumentUrl(filename);
        document.setDocumentType(documentType);
        document.setSpecialNote(specialNote);

        document = documentRepository.save(document);
        return modelMapper.map(document, DocumentDTO.class);
    }

    public List<DocumentDTO> getDocumentsByApplication(Long applicationId) {
        return documentRepository.findByApplicationId(applicationId).stream()
                .map(doc -> modelMapper.map(doc, DocumentDTO.class))
                .collect(Collectors.toList());
    }
}
