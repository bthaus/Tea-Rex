package com.example.demo.Services;

import com.example.demo.Entities.JWTFields;
import com.example.demo.Entities.UserAccount;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseCookie;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.function.Function;

public class JWTService {

    @Value("${jwt.secret}")
    private String secret;
    public static final long JWT_TOKEN_VALIDITY = 5 * 60 * 60;

    //while creating the token -
    //1. Define  claims of the token, like Issuer, Expiration, Subject, and the ID
    //2. Sign the JWT using the HS512 algorithm and secret key.
    //3. According to JWS Compact Serialization(https://tools.ietf.org/html/draft-ietf-jose-json-web-signature-41#section-3.1)
    //   compaction of the JWT to a URL-safe string
    String doGenerateToken(Map<String, Object> claims, String subject, JWTFields fields) {


        return Jwts.builder().setClaims(claims).claim("fields", fields).setSubject(subject).setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000*JWT_TOKEN_VALIDITY))
                .signWith(SignatureAlgorithm.HS512, Base64.getEncoder().encodeToString(secret.getBytes())).compact();
    }

    public String generateToken(Long id, JWTFields type) {
        return generateToken(String.valueOf(id), type);
    }


    //generate token for user
    public String generateToken(String id, JWTFields claimsdto) {
        Map<String, Object> claims = new HashMap<>();
        String token = doGenerateToken(claims, id, claimsdto);
        return token;
    }

    //check if the token has expired
    public Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    //for retrieveing any information from token we will need the secret key
    Claims getAllClaimsFromToken(String token) {
        return Jwts.parser().setSigningKey(Base64.getEncoder().encodeToString(secret.getBytes())).parseClaimsJws(token).getBody();
    }

    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }

    //retrieve expiration date from jwt token
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    public JWTFields getFieldsFromToken(String token) {
        Claims claims = getAllClaimsFromToken(token);
        LinkedHashMap o = claims.get("fields", LinkedHashMap.class);
        return new JWTFields((String) o.get("type"));
    }

    //retrieve username from jwt token
    public String getUserIDFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    public Long getIDfromToken(String token) {
        return Long.valueOf(getUserIDFromToken(token));
    }

    public boolean validateToken(String token, String secondToken) {

        final String ID = getUserIDFromToken(token);
        final String ID2 = getUserIDFromToken(secondToken);

        return !isTokenExpired(token) && ID.equals(ID2);
    }

    public boolean validateToken(String token) {

        final String ID = getUserIDFromToken(token);

        return !isTokenExpired(token);
    }
    private final int AUTHENTICATION_TIME = 10 * 60;
    private final int TOOL_UPDATE_TIME = 10 * 60;
    private final int ENTRY_TIME = 60 * 60 * 24 * 7;
    public ResponseCookie getTokenCookie(String id, String type) {
        long lifetime = JWT_TOKEN_VALIDITY*1000;

        ResponseCookie cookie = ResponseCookie.from("token", generateToken(id, new JWTFields(type)))
                .maxAge(lifetime)
                .path("/")
                .build();
        return cookie;
    }





    public boolean validateCredentialsWithToken(UserAccount given, String token) throws Exception {
        return validateToken(token, given.getToken());

    }

    public boolean validateCredentials(UserAccount given, String password) {
        if (given.getPw() == null || given.getPw().equals("")) {
            return true;
        }
        return given.getPw().equals(password);
    }
}
