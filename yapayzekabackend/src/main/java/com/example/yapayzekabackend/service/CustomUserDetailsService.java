package com.example.yapayzekabackend.service;

import com.example.yapayzekabackend.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserService userService;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Optional<User> user = userService.findByEmail(email);
        if (user.isEmpty()) {
            throw new UsernameNotFoundException("Kullanıcı bulunamadı: " + email);
        }

        System.out.println("CustomUserDetailsService: " + email + " için kullanıcı bulundu");

        return new org.springframework.security.core.userdetails.User(
                user.get().getEmail(),
                user.get().getPassword(),
                new ArrayList<>()
        );
    }
}