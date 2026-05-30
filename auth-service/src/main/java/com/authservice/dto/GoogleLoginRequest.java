package com.authservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class GoogleLoginRequest {

    @NotBlank(message = "ID token Google obbligatorio")
    private String idToken;
}
