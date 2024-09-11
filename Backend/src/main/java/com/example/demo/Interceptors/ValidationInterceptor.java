package com.example.demo.Interceptors;


import com.example.demo.Services.DBService;
import com.example.demo.Services.JWTService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
@AllArgsConstructor
@Component
public class ValidationInterceptor implements HandlerInterceptor {

    DBService userDatabaseService;
    JWTService jwtService;
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Code to be executed before the request is handled
        System.out.println("starting cookie validation");
        //letting preflight requests pass
        if(request.getMethod().equals("OPTIONS")){
            System.out.println("Preflight requests are passed, contains option methodname.");
            return true;
        }
        if(request.getCookies()==null){
            System.out.println("no cookies found");
            return false;
        }

        for (Cookie cookie:request.getCookies()
        ) {
            System.out.println(cookie.getName());
            if(cookie.getName().equals("token")){
                if(!jwtService.validateToken(cookie.getValue())){
                    System.out.println("invalid token");
                    return false;
                };
            }
        }
        System.out.println("passing validation");
        return true; // true allows the request to proceed to the controller, false blocks the request
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        // Code to be executed after the request is handled but before the view is rendered
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // Code to be executed after the view is rendered
    }
}