package com.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Username obbligatorio")
    @Size(min = 3, max = 64, message = "Username tra 3 e 64 caratteri")
    private String username;

    @NotBlank(message = "Email obbligatoria")
    @Email(message = "Email non valida")
    private String email;

    @NotBlank(message = "Password obbligatoria")
    @Size(min = 8, message = "Password minimo 8 caratteri")
    private String password;
}
