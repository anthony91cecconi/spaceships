package com.authservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ValidateResponse {
    private boolean valid;
    private Long userId;
    private String username;
    private String email;
    private String provider;
    private String message;
}
