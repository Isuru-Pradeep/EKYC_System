package com.paymedia.kyc_application_new_approch.repository;

import com.paymedia.kyc_application_new_approch.entity.KycApplication;
import org.springframework.data.jpa.repository.JpaRepository;

public interface KycApplicationRepository extends JpaRepository<KycApplication, Long> {
}
