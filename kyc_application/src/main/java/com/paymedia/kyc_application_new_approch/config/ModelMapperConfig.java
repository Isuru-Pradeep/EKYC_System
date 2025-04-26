package com.paymedia.kyc_application_new_approch.config;

import com.paymedia.kyc_application_new_approch.dto.CreateKycApplicationDTO;
import com.paymedia.kyc_application_new_approch.dto.KycApplicationDTO;
import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ModelMapperConfig {

    @Bean
    public ModelMapper modelMapper() {
        ModelMapper modelMapper = new ModelMapper();

        modelMapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        // Mapping from KycApplicationDTO to KycApplication
        modelMapper.typeMap(KycApplicationDTO.class, KycApplication.class)
                .addMappings(mapper -> {
                    mapper.skip(KycApplication::setId); // Skip id when mapping from DTO to Entity
                    mapper.skip(KycApplication::setCreatedAt);
                    mapper.skip(KycApplication::setUpdatedAt);
                });

        // Mapping from KycApplication to KycApplicationDTO
        modelMapper.typeMap(KycApplication.class, KycApplicationDTO.class);

        return modelMapper;
    }
}