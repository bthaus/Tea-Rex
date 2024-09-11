package com.example.demo.Entities;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import lombok.extern.jackson.Jacksonized;

@Getter
@Setter
@AllArgsConstructor
@SuperBuilder
@Jacksonized

public class JWTFields {
    public JWTFields(String who){

    }

}