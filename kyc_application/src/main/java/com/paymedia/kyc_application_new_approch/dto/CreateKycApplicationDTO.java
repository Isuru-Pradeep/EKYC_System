package com.paymedia.kyc_application_new_approch.dto;
import lombok.Data;

import java.time.LocalDate;

@Data
public class CreateKycApplicationDTO {
    private String fullName;
    private String phoneNumber;
    private LocalDate dob;
    private String address;
    private String idType;
    private String idNumber;
}
