package com.example.Sneakers.services;

import com.example.Sneakers.dtos.CartItemDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.Cart;
import com.example.Sneakers.responses.ListCartResponse;

import java.util.List;

public interface ICartService {
    Cart createCart(CartItemDTO cartItemDTO, String token, String sessionId) throws Exception;
    ListCartResponse getCarts(String token, String sessionId) throws Exception;
    Cart updateCart(Long id, CartItemDTO cartItemDTO, String token, String sessionId) throws Exception;
    void deleteCart(Long id);
    void deleteCartByUserOrSession(String token, String sessionId) throws Exception;
    Long countCarts(Long userId, String sessionId);
    
    // Deprecated methods to maintain compatibility if needed, but prefer updating calls
    default ListCartResponse getCartsByUserId(String token) throws Exception {
        return getCarts(token, null);
    }

    default Long countCartsByUserId(Long userId) {
        return countCarts(userId, null);
    }
}