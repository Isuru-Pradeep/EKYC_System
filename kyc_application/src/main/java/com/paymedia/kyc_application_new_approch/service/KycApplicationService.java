package com.paymedia.kyc_application_new_approch.service;


import com.paymedia.kyc_application_new_approch.dto.CreateKycApplicationDTO;
import com.paymedia.kyc_application_new_approch.dto.KycApplicationDTO;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import com.paymedia.kyc_application_new_approch.repository.KycApplicationRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class KycApplicationService {

    private final KycApplicationRepository kycApplicationRepository;
    private final ModelMapper modelMapper;

    @Transactional
    public KycApplicationDTO createKycApplication(CreateKycApplicationDTO dto) {
        KycApplication application = modelMapper.map(dto, KycApplication.class);
        application = kycApplicationRepository.save(application);
        return modelMapper.map(application, KycApplicationDTO.class);
    }

    public List<KycApplicationDTO> getAllApplications() {
        return kycApplicationRepository.findAll().stream()
                .map(app -> modelMapper.map(app, KycApplicationDTO.class))
                .collect(Collectors.toList());
    }

    public KycApplicationDTO getApplicationById(Long id) {
        KycApplication application = kycApplicationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found"));
        return modelMapper.map(application, KycApplicationDTO.class);
    }

    @Transactional
    public KycApplicationDTO updateApplicationStatus(Long id, KycApplication.KycStatus status) {
        KycApplication application = kycApplicationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found"));
        application.setStatus(status);
        return modelMapper.map(kycApplicationRepository.save(application), KycApplicationDTO.class);
    }
}