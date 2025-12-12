package com.example.Sneakers.services;

import com.example.Sneakers.dtos.CartItemDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.Cart;
import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.CartRepository;
import com.example.Sneakers.repositories.ProductRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.CartResponse;
import com.example.Sneakers.responses.ListCartResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CartService implements ICartService{
    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final UserService userService;
    @Override
    @Transactional
    public Cart createCart(CartItemDTO cartItemDTO, String token, String sessionId) throws Exception {
        Product product = productRepository.findById(cartItemDTO.getProductId())
                .orElseThrow(() -> new DataNotFoundException(
                        "Cannot find product with id = " + cartItemDTO.getProductId()
                ));
        
        User user = null;
        if (token != null && !token.isEmpty() && token.startsWith("Bearer ")) {
            String extractedToken = token.substring(7);
            user = userService.getUserDetailsFromToken(extractedToken);
        }

        if (user == null && (sessionId == null || sessionId.isEmpty())) {
            throw new Exception("Either User Token or Session ID is required");
        }

        Optional<Cart> existingCartOptional;
        if (user != null) {
            existingCartOptional = cartRepository.findByUserAndProductAndSize(user, product, cartItemDTO.getSize());
        } else {
            existingCartOptional = cartRepository.findBySessionIdAndProductAndSize(sessionId, product, cartItemDTO.getSize());
        }

        if (existingCartOptional.isPresent()) {
            Cart existingCart = existingCartOptional.get();
            existingCart.setQuantity(existingCart.getQuantity() + cartItemDTO.getQuantity());
            return cartRepository.save(existingCart);
        }

        Cart cart = Cart.builder()
                .product(product)
                .quantity(cartItemDTO.getQuantity())
                .size(cartItemDTO.getSize())
                .user(user)
                .sessionId(user == null ? sessionId : null)
                .build();
        return cartRepository.save(cart);
    }

    @Override
    public ListCartResponse getCarts(String token, String sessionId) throws Exception {
        User user = null;
        if (token != null && !token.isEmpty() && token.startsWith("Bearer ")) {
            String extractedToken = token.substring(7);
            user = userService.getUserDetailsFromToken(extractedToken);
        }

        List<CartResponse> cartResponses = new ArrayList<>();
        List<Cart> carts;
        Long totalItems;

        if (user != null) {
            carts = cartRepository.findByUserId(user.getId());
            totalItems = cartRepository.countByUserId(user.getId());
        } else if (sessionId != null && !sessionId.isEmpty()) {
            carts = cartRepository.findBySessionId(sessionId);
            totalItems = cartRepository.countBySessionId(sessionId);
        } else {
            return ListCartResponse.builder().carts(new ArrayList<>()).totalCartItems(0L).build();
        }

        for (Cart cart : carts) {
            cartResponses.add(CartResponse.fromCart(cart));
        }
        return ListCartResponse.builder()
                .carts(cartResponses)
                .totalCartItems(totalItems)
                .build();
    }

    @Override
    @Transactional
    public Cart updateCart(Long id, CartItemDTO cartItemDTO, String token, String sessionId) throws Exception {
        User user = null;
        if (token != null && !token.isEmpty() && token.startsWith("Bearer ")) {
            String extractedToken = token.substring(7);
            user = userService.getUserDetailsFromToken(extractedToken);
        }

        Cart cart = cartRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        // Validate ownership
        if (user != null) {
            if (cart.getUser() == null || !Objects.equals(cart.getUser().getId(), user.getId())) {
                throw new Exception("Unauthorized access to cart item");
            }
        } else {
            if (cart.getSessionId() == null || !Objects.equals(cart.getSessionId(), sessionId)) {
                throw new Exception("Unauthorized access to cart item");
            }
        }

        Product product = productRepository.findById(cartItemDTO.getProductId())
                .orElseThrow(() -> new DataNotFoundException(
                        "Cannot find product with id = " + cartItemDTO.getProductId()
                ));
        if (!Objects.equals(cart.getProduct().getId(), product.getId())) {
            throw new DataNotFoundException("Product's id is not valid");
        }
        
        Optional<Cart> existingCartOptional;
        if (user != null) {
            existingCartOptional = cartRepository.findByUserAndProductAndSize(user, product, cartItemDTO.getSize());
        } else {
            existingCartOptional = cartRepository.findBySessionIdAndProductAndSize(sessionId, product, cartItemDTO.getSize());
        }

        if (existingCartOptional.isPresent()) {
            Cart existingCart = existingCartOptional.get();
            if (!existingCart.getId().equals(id)) {
                existingCart.setQuantity(existingCart.getQuantity() + cartItemDTO.getQuantity());
                cartRepository.deleteById(id);
                return cartRepository.save(existingCart);
            }
        }
        cart.setProduct(product);
        cart.setQuantity(cartItemDTO.getQuantity());
        cart.setSize(cartItemDTO.getSize());
        return cartRepository.save(cart);
    }

    @Override
    @Transactional
    public void deleteCart(Long id) {
        cartRepository.deleteById(id);
    }

    @Override
    @Transactional
    public void deleteCartByUserOrSession(String token, String sessionId) throws Exception {
        User user = null;
        if (token != null && !token.isEmpty() && token.startsWith("Bearer ")) {
            String extractedToken = token.substring(7);
            user = userService.getUserDetailsFromToken(extractedToken);
        }

        if (user != null) {
            cartRepository.deleteByUserId(user.getId());
        } else if (sessionId != null) {
            cartRepository.deleteBySessionId(sessionId);
        }
    }

    @Override
    public Long countCarts(Long userId, String sessionId) {
        if (userId != null) {
            return cartRepository.countByUserId(userId);
        } else if (sessionId != null) {
            return cartRepository.countBySessionId(sessionId);
        }
        return 0L;
    }

    @Override
    public Long countCartsByUserId(Long userId) {
        return countCarts(userId, null);
    }
    
    // Implement deprecated methods to satisfy interface if needed, but the interface default methods handle it.
    // However, since I implemented the class, I should likely override or just let interface default if compatible.
    // Wait, I updated interface with `default`. But `CartService` implemented `ICartService`. 
    // I replaced the methods in CartService with new signatures.
    // I need to ensure I don't leave the old @Override methods if they clash or are duplicate.
    // The replace block below replaces the WHOLE class body content effectively.



}