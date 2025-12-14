package com.example.Sneakers.services;


import com.example.Sneakers.components.JwtTokenUtils;
import com.example.Sneakers.components.LocalizationUtils;
import com.example.Sneakers.dtos.UpdateUserDTO;
import com.example.Sneakers.dtos.UserDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.exceptions.PermissionDenyException;
import com.example.Sneakers.models.Role;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.RoleRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.UserResponse;
import com.example.Sneakers.utils.Email;
import com.example.Sneakers.utils.MessageKeys;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Service
public class UserService implements IUserService{
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtils jwtTokenUtil;
    private final AuthenticationManager authenticationManager;
    private final LocalizationUtils localizationUtils;
    private final Email email;

    @Override
    public User createUser(UserDTO userDTO) throws Exception {
        //register user
        String phoneNumber = userDTO.getPhoneNumber();
        // Kiểm tra xem số điện thoại đã tồn tại hay chưa
        if(userRepository.existsByPhoneNumber(phoneNumber)) {
            throw new DataIntegrityViolationException("Phone number already exists");
        }

        if(userDTO.getRoleId() == null){
            userDTO.setRoleId(1L);
        }

        Role role =roleRepository.findById(userDTO.getRoleId())
                .orElseThrow(() -> new DataNotFoundException(
                        localizationUtils.getLocalizedMessage(MessageKeys.ROLE_DOES_NOT_EXISTS)));;

        if(role.getName().toUpperCase().equals(Role.ADMIN)) {
            throw new PermissionDenyException("You cannot register an admin account");
        }

        // Check if email already exists - if registering from Google, email will match
        // Backend will handle linking by email in loginWithGoogleResponse
        // Here we just create the user normally

        //convert from userDTO => user
        User newUser = User.builder()
                .fullName(userDTO.getFullName())
                .phoneNumber(userDTO.getPhoneNumber())
                .password(userDTO.getPassword())
                .address(userDTO.getAddress())
                .email(userDTO.getEmail())
                .dateOfBirth(userDTO.getDateOfBirth())
                .facebookAccountId(userDTO.getFacebookAccountId())
                .googleAccountId(userDTO.getGoogleAccountId())
                .active(true)
                .build();

        newUser.setRole(role);
        // Kiểm tra nếu có accountId, không yêu cầu password
        if (userDTO.getFacebookAccountId() == 0 && userDTO.getGoogleAccountId() == 0) {
            String password = userDTO.getPassword();
            String encodedPassword = passwordEncoder.encode(password);
            newUser.setPassword(encodedPassword);
        } else {
            // For Google/Facebook users, set empty password
            newUser.setPassword("");
        }
        return userRepository.save(newUser);
    }

    @Override
    public String login(String phoneNumber, String password, Long roleId) throws Exception {
        Optional<User> optionalUser = userRepository.findByPhoneNumber(phoneNumber);
        if(optionalUser.isEmpty()) {
            throw new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.WRONG_PHONE_PASSWORD));
        }
        User existingUser = optionalUser.get();

        if (!Boolean.TRUE.equals(existingUser.isActive())) {
            throw new BadCredentialsException(localizationUtils.getLocalizedMessage(MessageKeys.USER_IS_LOCKED));
        }
        //check password
        if (existingUser.getFacebookAccountId() == 0
                && existingUser.getGoogleAccountId() == 0) {
            if(!passwordEncoder.matches(password, existingUser.getPassword())) {
                throw new BadCredentialsException(localizationUtils.getLocalizedMessage(MessageKeys.WRONG_PHONE_PASSWORD));
            }
        }
        // Only check role if roleId is provided and not null
        if (roleId != null && existingUser.getRole().getId() != roleId) {
            throw new BadCredentialsException("Role does not match");
        }
        //Thông tin xác thực
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                phoneNumber, password,
                existingUser.getAuthorities()
        );

        //authenticate with Java Spring security
        authenticationManager.authenticate(authenticationToken);
        return jwtTokenUtil.generateToken(existingUser);
    }

    @Override
    public User getUserDetailsFromToken(String token) throws Exception {
        if(jwtTokenUtil.isTokenExpired(token)) {
            throw new Exception("Token is expired");
        }
        String phoneNumber = jwtTokenUtil.extractPhoneNumber(token);
        Optional<User> user = userRepository.findByPhoneNumber(phoneNumber);

        if (user.isPresent()) {
            return user.get();
        } else {
            throw new Exception("User not found");
        }
    }

    @Transactional
    @Override
    public User updateUser(Long userId, UpdateUserDTO updatedUserDTO) throws Exception {
        // Find the existing user by userId
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        // Check if the phone number is being changed and if it already exists for another user
        String newPhoneNumber = updatedUserDTO.getPhoneNumber();
        if (!existingUser.getPhoneNumber().equals(newPhoneNumber) &&
                userRepository.existsByPhoneNumber(newPhoneNumber)) {
            throw new DataIntegrityViolationException("Phone number already exists");
        }

        // Update user information based on the DTO
        if (updatedUserDTO.getFullName() != null) {
            existingUser.setFullName(updatedUserDTO.getFullName());
        }
        if (newPhoneNumber != null) {
            existingUser.setPhoneNumber(newPhoneNumber);
        }
        if (updatedUserDTO.getAddress() != null) {
            existingUser.setAddress(updatedUserDTO.getAddress());
        }
        if (updatedUserDTO.getEmail() != null) {
            existingUser.setEmail(updatedUserDTO.getEmail());
        }
        if (updatedUserDTO.getDateOfBirth() != null) {
            existingUser.setDateOfBirth(updatedUserDTO.getDateOfBirth());
        }
        if (updatedUserDTO.getFacebookAccountId() > 0) {
            existingUser.setFacebookAccountId(updatedUserDTO.getFacebookAccountId());
        }
        if (updatedUserDTO.getGoogleAccountId() > 0) {
            existingUser.setGoogleAccountId(updatedUserDTO.getGoogleAccountId());
        }

        // Update the password if it is provided in the DTO
        if (updatedUserDTO.getPassword() != null
                && !updatedUserDTO.getPassword().isEmpty()) {
            String newPassword = updatedUserDTO.getPassword();
            String encodedPassword = passwordEncoder.encode(newPassword);
            existingUser.setPassword(encodedPassword);
        }
        //existingUser.setRole(updatedRole);
        // Save the updated user
        return userRepository.save(existingUser);
    }

    @Override
    public Optional<User> updateActiveUserById(Long id, boolean activeUser) {
        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setActive(activeUser);
            userRepository.save(user);
            return Optional.of(user);
        }
        return Optional.empty();
    }


    @Override
    public List<UserResponse> getAllUser() {
        List<User> ls = this.userRepository.findAll();
        return userRepository.findAll()
                .stream()
                .map(UserResponse::fromUser)
                .collect(Collectors.toList());
    }


    @Override
    public User changeRoleUser(Long roleId, Long userId) throws Exception {
        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new Exception("Cannot find role with id = " + roleId));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new Exception("Cannot find user with id = " + userId));
        user.setRole(role);
        return userRepository.save(user);
    }

    @Override
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    @Override
    public void forgotPassword(String userEmail) throws Exception {
        Optional<User> userOptional = userRepository.findByEmail(userEmail);
        if (userOptional.isEmpty()) {
            throw new DataNotFoundException("User not found");
        }
        User user = userOptional.get();

        String token = UUID.randomUUID().toString();
        user.setResetPasswordToken(token);
        user.setResetPasswordTokenExpiry(LocalDateTime.now().plusMinutes(15)); // Token expires in 15 minutes
        userRepository.save(user);

        String resetLink = "http://localhost:4200/reset-password?token=" + token;
        String subject = "Yêu cầu đặt lại mật khẩu - Locker Korea";
        String content = "<html><body style='font-family: Arial, sans-serif;'>"
                + "<h1 style='color: #673AB7;'>Yêu cầu đặt lại mật khẩu</h1>"
                + "<p>Xin chào <strong>" + user.getFullName() + "</strong>,</p>"
                + "<p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản của mình tại Locker Korea.</p>"
                + "<p>Vui lòng nhấp vào liên kết bên dưới để đặt lại mật khẩu:</p>"
                + "<p style='margin: 20px 0;'><a href=\"" + resetLink + "\" style='background-color: #673AB7; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;'>Đặt lại mật khẩu</a></p>"
                + "<p><strong>Lưu ý:</strong> Liên kết này sẽ hết hạn sau <strong>15 phút</strong>.</p>"
                + "<p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này. Tài khoản của bạn vẫn an toàn.</p>"
                + "<hr style='margin: 30px 0; border: none; border-top: 1px solid #eee;'/>"
                + "<p style='color: #666; font-size: 12px;'>Trân trọng,<br/>Đội ngũ Locker Korea</p>"
                + "</body></html>";

        email.sendEmail(userEmail, subject, content);
    }

    @Override
    public void resetPassword(String token, String newPassword) throws Exception {
        Optional<User> userOptional = userRepository.findByResetPasswordToken(token);
        if (userOptional.isEmpty()) {
            throw new DataNotFoundException("Invalid or expired password reset token.");
        }
        User user = userOptional.get();

        if (user.getResetPasswordTokenExpiry().isBefore(LocalDateTime.now())) {
            throw new Exception("Password reset token has expired.");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setResetPasswordToken(null);
        user.setResetPasswordTokenExpiry(null);
        userRepository.save(user);
    }

    @Override
    public void changePassword(String token, String currentPassword, String newPassword) throws Exception {
        User user = getUserDetailsFromToken(token);
        
        // Verify current password
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new BadCredentialsException("Current password is incorrect.");
        }
        
        // Check if new password is different from current password
        if (passwordEncoder.matches(newPassword, user.getPassword())) {
            throw new Exception("New password must be different from current password.");
        }
        
        // Update password
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    @Override
    public String loginWithGoogle(String idToken) throws Exception {
        try {
            // Verify Google ID token using HTTP request to Google's tokeninfo endpoint
            // This is a simpler approach that doesn't require complex library setup
            java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
            java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create("https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken))
                    .GET()
                    .build();
            
            java.net.http.HttpResponse<String> response = client.send(request, 
                    java.net.http.HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() != 200) {
                throw new BadCredentialsException("Invalid Google token");
            }
            
            // Parse JSON response
            com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode jsonNode = objectMapper.readTree(response.body());
            
            // Extract user information
            String email = jsonNode.has("email") ? jsonNode.get("email").asText() : null;
            String name = jsonNode.has("name") ? jsonNode.get("name").asText() : null;
            String googleId = jsonNode.has("sub") ? jsonNode.get("sub").asText() : null;
            
            if (googleId == null) {
                throw new BadCredentialsException("Invalid Google token: missing user ID");
            }
            
            // Convert Google ID to integer (use hash if too long)
            int googleAccountId;
            try {
                // Try to parse as long first, then convert to int
                long googleIdLong = Long.parseLong(googleId);
                googleAccountId = (int) (googleIdLong % Integer.MAX_VALUE);
            } catch (NumberFormatException e) {
                // If not numeric, use hash code
                googleAccountId = Math.abs(googleId.hashCode());
            }
            
            // Check if user exists with this Google account ID
            Optional<User> existingUserOpt = userRepository.findByGoogleAccountId(googleAccountId);
            
            User user;
            if (existingUserOpt.isPresent()) {
                // User exists, login
                user = existingUserOpt.get();
                if (!Boolean.TRUE.equals(user.isActive())) {
                    throw new BadCredentialsException(localizationUtils.getLocalizedMessage(MessageKeys.USER_IS_LOCKED));
                }
            } else {
                // New user, create account
                // Check if email already exists
                if (email != null && !email.isEmpty()) {
                    Optional<User> userByEmail = userRepository.findByEmail(email);
                    if (userByEmail.isPresent()) {
                        // Link Google account to existing user
                        user = userByEmail.get();
                        user.setGoogleAccountId(googleAccountId);
                        if (user.getFullName() == null || user.getFullName().isEmpty()) {
                            user.setFullName(name != null ? name : "Google User");
                        }
                        userRepository.save(user);
                    } else {
                        // Create new user with email
                        user = createGoogleUser(email, name, googleAccountId);
                    }
                } else {
                    // Create new user without email
                    user = createGoogleUser(null, name, googleAccountId);
                }
            }
            
            // Generate JWT token
            return jwtTokenUtil.generateToken(user);
        } catch (Exception e) {
            throw new BadCredentialsException("Invalid Google token: " + e.getMessage());
        }
    }

    @Override
    public com.example.Sneakers.responses.LoginResponse loginWithGoogleResponse(String idToken) throws Exception {
        try {
            // Verify Google ID token
            java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
            java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create("https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken))
                    .GET()
                    .build();
            
            java.net.http.HttpResponse<String> response = client.send(request, 
                    java.net.http.HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() != 200) {
                throw new BadCredentialsException("Invalid Google token");
            }
            
            // Parse JSON response
            com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode jsonNode = objectMapper.readTree(response.body());
            
            // Extract user information
            String email = jsonNode.has("email") ? jsonNode.get("email").asText() : null;
            String name = jsonNode.has("name") ? jsonNode.get("name").asText() : null;
            String googleId = jsonNode.has("sub") ? jsonNode.get("sub").asText() : null;
            
            if (googleId == null) {
                throw new BadCredentialsException("Invalid Google token: missing user ID");
            }
            
            // Convert Google ID to integer
            int googleAccountId;
            try {
                long googleIdLong = Long.parseLong(googleId);
                googleAccountId = (int) (googleIdLong % Integer.MAX_VALUE);
            } catch (NumberFormatException e) {
                googleAccountId = Math.abs(googleId.hashCode());
            }
            
            // Check if user exists with this Google account ID
            Optional<User> existingUserOpt = userRepository.findByGoogleAccountId(googleAccountId);
            
            boolean isNewUser = false;
            User user;
            
            if (existingUserOpt.isPresent()) {
                // User exists, login
                user = existingUserOpt.get();
                if (!Boolean.TRUE.equals(user.isActive())) {
                    throw new BadCredentialsException(localizationUtils.getLocalizedMessage(MessageKeys.USER_IS_LOCKED));
                }
            } else {
                // Check if email already exists
                if (email != null && !email.isEmpty()) {
                    Optional<User> userByEmail = userRepository.findByEmail(email);
                    if (userByEmail.isPresent()) {
                        // Link Google account to existing user
                        user = userByEmail.get();
                        user.setGoogleAccountId(googleAccountId);
                        if (user.getFullName() == null || user.getFullName().isEmpty()) {
                            user.setFullName(name != null ? name : "Google User");
                        }
                        userRepository.save(user);
                    } else {
                        // New user with email - return info for registration
                        isNewUser = true;
                        String token = null;
                        return com.example.Sneakers.responses.LoginResponse.builder()
                                .message("Vui lòng hoàn tất đăng ký với thông tin Google")
                                .token(token)
                                .isNewUser(true)
                                .googleEmail(email)
                                .googleName(name)
                                .build();
                    }
                } else {
                    // New user without email - return info for registration
                    isNewUser = true;
                    String token = null;
                    return com.example.Sneakers.responses.LoginResponse.builder()
                            .message("Vui lòng hoàn tất đăng ký với thông tin Google")
                            .token(token)
                            .isNewUser(true)
                            .googleEmail(null)
                            .googleName(name)
                            .build();
                }
            }
            
            // Generate JWT token for existing user
            String token = jwtTokenUtil.generateToken(user);
            return com.example.Sneakers.responses.LoginResponse.builder()
                    .message(localizationUtils.getLocalizedMessage(MessageKeys.LOGIN_SUCCESSFULLY))
                    .token(token)
                    .isNewUser(false)
                    .googleEmail(email)
                    .googleName(name)
                    .build();
        } catch (Exception e) {
            throw new BadCredentialsException("Invalid Google token: " + e.getMessage());
        }
    }
    
    private User createGoogleUser(String email, String name, int googleAccountId) throws Exception {
        Role defaultRole = roleRepository.findById(1L)
                .orElseThrow(() -> new DataNotFoundException(
                        localizationUtils.getLocalizedMessage(MessageKeys.ROLE_DOES_NOT_EXISTS)));
        
        // Generate a unique phone number for Google users (they might not have one)
        String phoneNumber = "GOOGLE_" + googleAccountId;
        int counter = 0;
        while (userRepository.existsByPhoneNumber(phoneNumber)) {
            phoneNumber = "GOOGLE_" + googleAccountId + "_" + counter++;
        }
        
        User user = User.builder()
                .fullName(name != null ? name : "Google User")
                .phoneNumber(phoneNumber)
                .email(email != null ? email : "")
                .googleAccountId(googleAccountId)
                .password("") // No password for Google users
                .active(true)
                .role(defaultRole)
                .build();
        return userRepository.save(user);
    }
}