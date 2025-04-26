package com.paymedia.kyc_application_new_approch.repository;

import com.paymedia.kyc_application_new_approch.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DocumentRepository extends JpaRepository<Document, Long> {
    List<Document> findByApplicationId(Long applicationId);
}
