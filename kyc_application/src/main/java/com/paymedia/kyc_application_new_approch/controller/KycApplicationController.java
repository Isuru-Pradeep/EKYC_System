package com.paymedia.kyc_application_new_approch.controller;

import com.paymedia.kyc_application_new_approch.dto.CreateKycApplicationDTO;
import com.paymedia.kyc_application_new_approch.dto.KycApplicationDTO;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import com.paymedia.kyc_application_new_approch.service.KycApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/kyc-applications")
@RequiredArgsConstructor
public class KycApplicationController {

    private final KycApplicationService kycApplicationService;

    @PostMapping
    public ResponseEntity<KycApplicationDTO> createApplication(@RequestBody CreateKycApplicationDTO dto) {
        return ResponseEntity.ok(kycApplicationService.createKycApplication(dto));
    }

    @GetMapping
    public ResponseEntity<List<KycApplicationDTO>> getAllApplications() {
        return ResponseEntity.ok(kycApplicationService.getAllApplications());
    }

    @GetMapping("/{id}")
    public ResponseEntity<KycApplicationDTO> getApplication(@PathVariable Long id) {
        return ResponseEntity.ok(kycApplicationService.getApplicationById(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<KycApplicationDTO> updateStatus(
            @PathVariable Long id,
            @RequestParam KycApplication.KycStatus status) {
        return ResponseEntity.ok(kycApplicationService.updateApplicationStatus(id, status));
    }
}
