package com.example.demo.Interceptors;

import com.example.demo.Interceptors.ValidationInterceptor;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
@AllArgsConstructor
@Configuration
public class Config implements WebMvcConfigurer {

    ValidationInterceptor validationInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(validationInterceptor)
                .addPathPatterns("/validated/**");
        // registry.addInterceptor(cookieInterceptor)
        //       .addPathPatterns("/Onboarding/**"); // intercept all routes starting with /api/
        // .excludePathPatterns("/api/public/**"); // exclude /api/public/** routes from interception

    }
}