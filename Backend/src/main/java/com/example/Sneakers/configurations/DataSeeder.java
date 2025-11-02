package com.example.Sneakers.configurations;

import com.example.Sneakers.models.Category;
import com.example.Sneakers.models.News;
import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.ProductImage;
import com.example.Sneakers.models.Role;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.CategoryRepository;
import com.example.Sneakers.repositories.NewsRepository;
import com.example.Sneakers.repositories.ProductImageRepository;
import com.example.Sneakers.repositories.ProductRepository;
import com.example.Sneakers.repositories.RoleRepository;
import com.example.Sneakers.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;
    private final NewsRepository newsRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Tạo roles nếu chưa có
        if (roleRepository.count() == 0) {
            log.info("Creating default roles...");
            
            Role adminRole = Role.builder()
                    .name("ADMIN")
                    .build();
            roleRepository.save(adminRole);
            
            Role userRole = Role.builder()
                    .name("USER")
                    .build();
            roleRepository.save(userRole);
            
            log.info("Default roles created successfully!");
        }

        // Tạo admin user nếu chưa có
        if (userRepository.count() == 0) {
            log.info("Creating default admin user...");
            
            Role adminRole = roleRepository.findByName("ADMIN")
                    .orElseThrow(() -> new RuntimeException("Admin role not found"));
            
            User adminUser = User.builder()
                    .fullName("Admin User")
                    .phoneNumber("0123456789")
                    .password(passwordEncoder.encode("123456"))
                    .email("admin@example.com")
                    .active(true)
                    .role(adminRole)
                    .build();
            
            userRepository.save(adminUser);
            
            log.info("Default admin user created successfully!");
            log.info("Phone: 0123456789, Password: 123456");
        }

        // Tạo categories nếu chưa có
        if (categoryRepository.count() == 0) {
            log.info("Creating all Korean lock categories...");
            
            Category gatemanCategory = Category.builder()
                    .name("GATEMAN")
                    .build();
            categoryRepository.save(gatemanCategory);
            
            Category samsungCategory = Category.builder()
                    .name("SAMSUNG")
                    .build();
            categoryRepository.save(samsungCategory);
            
            Category hgangCategory = Category.builder()
                    .name("H-Gang")
                    .build();
            categoryRepository.save(hgangCategory);
            
            Category epicCategory = Category.builder()
                    .name("EPIC")
                    .build();
            categoryRepository.save(epicCategory);
            
            Category welkomCategory = Category.builder()
                    .name("WELKOM")
                    .build();
            categoryRepository.save(welkomCategory);
            
            Category kaiserCategory = Category.builder()
                    .name("KAISER+")
                    .build();
            categoryRepository.save(kaiserCategory);
            
            Category unicorCategory = Category.builder()
                    .name("UNICOR")
                    .build();
            categoryRepository.save(unicorCategory);
            
            Category hioneCategory = Category.builder()
                    .name("HiOne+")
                    .build();
            categoryRepository.save(hioneCategory);
            
            Category glassLockCategory = Category.builder()
                    .name("Khóa cửa kính")
                    .build();
            categoryRepository.save(glassLockCategory);
            
            Category doorbellCategory = Category.builder()
                    .name("Chuông cửa hình")
                    .build();
            categoryRepository.save(doorbellCategory);
            
            log.info("All Korean lock categories created successfully!");
        }

        // Khởi tạo các categories
        Category gatemanCategory = categoryRepository.findByName("GATEMAN").orElse(null);
        Category samsungCategory = categoryRepository.findByName("SAMSUNG").orElse(null);
        Category hgangCategory = categoryRepository.findByName("H-Gang").orElse(null);
        Category epicCategory = categoryRepository.findByName("EPIC").orElse(null);
        Category welkomCategory = categoryRepository.findByName("WELKOM").orElse(null);
        Category kaiserCategory = categoryRepository.findByName("KAISER+").orElse(null);
        Category unicorCategory = categoryRepository.findByName("UNICOR").orElse(null);
        Category hioneCategory = categoryRepository.findByName("HiOne+").orElse(null);
        Category glassLockCategory = categoryRepository.findByName("Khóa cửa kính").orElse(null);
        Category doorbellCategory = categoryRepository.findByName("Chuông cửa hình").orElse(null);
        
        // Tạo products nếu chưa có
        if (productRepository.count() == 0) {
            log.info("Creating real Korean lock products...");
            
            // GATEMAN products
            if (gatemanCategory != null) {
                Product product1 = Product.builder()
                        .name("Khóa vân tay GATEMAN FINGUS (WF-20)")
                        .price(6500000L)
                        .thumbnail("WF20_1 3-4.jpg")
                        .description("Khóa vân tay GATEMAN WF-20 - Mở khóa bằng vân tay hoặc mật mã. Cài đặt 20 vân tay, 03 mã số.")
                        .discount(30L)
                        .quantity(50L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product1);
                
                Product product2 = Product.builder()
                        .name("Khóa điện tử GATEMAN WG-200")
                        .price(4190000L)
                        .thumbnail("wg-200 3-4.jpg")
                        .description("Khóa điện tử GATEMAN WG-200 - Mở bằng mã số và thẻ từ. Kiểu dáng thanh lịch, vật liệu siêu bền.")
                        .discount(20L)
                        .quantity(30L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product2);
                
                Product product3 = Product.builder()
                        .name("Khóa vân tay GATEMAN WF200")
                        .price(6990000L)
                        .thumbnail("wf-200_34.jpg")
                        .description("Khóa vân tay GATEMAN WF200 - Mở bằng vân tay, mật mã. Bàn phím cảm ứng chất liệu đặc biệt, bền, sang trọng.")
                        .discount(25L)
                        .quantity(25L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product3);
                
                Product product4 = Product.builder()
                        .name("Khóa vân tay GATEMAN Z10-IH")
                        .price(5600000L)
                        .thumbnail("Z10_3 3-4.jpg")
                        .description("Khóa vân tay GATEMAN Z10-IH - Công nghệ cảm biến vân tay tiên tiến, thiết kế hiện đại.")
                        .discount(15L)
                        .quantity(20L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product4);
                
                Product product5 = Product.builder()
                        .name("GATEMAN F300-FH")
                        .price(7950000L)
                        .thumbnail("Gateman F300-FH.jpg")
                        .description("GATEMAN F300-FH - Khóa vân tay cao cấp với thiết kế sang trọng.")
                        .discount(10L)
                        .quantity(15L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product5);
                
                Product product6 = Product.builder()
                        .name("Khóa vân tay GATEMAN F50-FH")
                        .price(5250000L)
                        .thumbnail("Gateman F50-FH.jpg")
                        .description("Khóa vân tay GATEMAN F50-FH - Thiết kế compact, dễ sử dụng.")
                        .discount(20L)
                        .quantity(35L)
                        .category(gatemanCategory)
                        .build();
                productRepository.save(product6);
            }
            
            // SAMSUNG products
            if (samsungCategory != null) {
                Product product7 = Product.builder()
                        .name("Khóa vân tay Samsung SHP-DH538")
                        .price(5490000L)
                        .thumbnail("DH538_co 3-4.jpg")
                        .description("Khóa vân tay Samsung SHP-DH538 - Mở bằng vân tay, mã số, chìa cơ dự phòng. Chống nước, thiết kế hiện đại.")
                        .discount(20L)
                        .quantity(30L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product7);
                
                Product product8 = Product.builder()
                        .name("Khóa vân tay SamSung SHS P718")
                        .price(8500000L)
                        .thumbnail("SHS-P718_3-4.png")
                        .description("Khóa vân tay Samsung SHS P718 - Công nghệ cảm biến vân tay tiên tiến, thiết kế hiện đại.")
                        .discount(15L)
                        .quantity(25L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product8);
                
                Product product9 = Product.builder()
                        .name("Khóa SAMSUNG SHS-2920")
                        .price(4200000L)
                        .thumbnail("SHS-2920_1.jpg")
                        .description("Khóa SAMSUNG SHS-2920 - Thiết kế đơn giản, giá cả hợp lý.")
                        .discount(10L)
                        .quantity(40L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product9);
                
                Product product10 = Product.builder()
                        .name("Khóa điện tử SAMSUNG SHP-DS700")
                        .price(3290000L)
                        .thumbnail("SHP-DS700_1.jpg")
                        .description("Khóa điện tử Samsung SHP-DS700 cao cấp, mở khóa bằng thẻ từ và mã số.")
                        .discount(25L)
                        .quantity(20L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product10);
                
                Product product11 = Product.builder()
                        .name("Khóa điện tử SAMSUNG SHS 1321")
                        .price(3480000L)
                        .thumbnail("1321-1-3-4.jpg")
                        .description("Khóa điện tử Samsung SHS 1321 với thiết kế thanh lịch, bảo mật cao.")
                        .discount(15L)
                        .quantity(35L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product11);
                
                Product product12 = Product.builder()
                        .name("Khóa vân tay SAMSUNG SHP-DP930")
                        .price(12000000L)
                        .thumbnail("SAMSUNG DP920.jpg")
                        .description("Khóa vân tay Samsung SHP-DP930 - Model cao cấp nhất với nhiều tính năng thông minh.")
                        .discount(30L)
                        .quantity(10L)
                        .category(samsungCategory)
                        .build();
                productRepository.save(product12);
            }
            
            // H-Gang products
            if (hgangCategory != null) {
                Product product13 = Product.builder()
                        .name("Khóa vân tay H-Gang TR812")
                        .price(3350000L)
                        .thumbnail("TR812_3-4.png")
                        .description("Khóa vân tay H-Gang TR812 - Thiết kế hiện đại, giá cả hợp lý.")
                        .discount(20L)
                        .quantity(45L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product13);
                
                Product product14 = Product.builder()
                        .name("Khóa điện tử H-Gang TR100")
                        .price(2150000L)
                        .thumbnail("design_3-4.jpg")
                        .description("Khóa điện tử H-Gang TR100 - Model cơ bản, dễ sử dụng.")
                        .discount(15L)
                        .quantity(50L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product14);
                
                Product product15 = Product.builder()
                        .name("Khóa vân tay H-Gang TM902-KV")
                        .price(5850000L)
                        .thumbnail("PRISMA F901-KV.jpg")
                        .description("Khóa vân tay H-Gang TM902-KV - Công nghệ vân tay tiên tiến.")
                        .discount(25L)
                        .quantity(20L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product15);
                
                Product product16 = Product.builder()
                        .name("Khóa điện tử H-Gang Sync TM700")
                        .price(3590000L)
                        .thumbnail("TM700_3-4.png")
                        .description("Khóa điện tử H-Gang Sync TM700 - Thiết kế đồng bộ hiện đại.")
                        .discount(10L)
                        .quantity(30L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product16);
                
                Product product17 = Product.builder()
                        .name("Khóa điện tử H-Gang Sync TR700")
                        .price(2890000L)
                        .thumbnail("TR700_3-4.png")
                        .description("Khóa điện tử H-Gang Sync TR700 - Model tiết kiệm chi phí.")
                        .discount(20L)
                        .quantity(40L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product17);
                
                Product product18 = Product.builder()
                        .name("Khóa vân tay H-Gang TM901")
                        .price(5500000L)
                        .thumbnail("design_03_b 3-4.png")
                        .description("Khóa vân tay H-Gang TM901 - Thiết kế cao cấp, bảo mật tuyệt đối.")
                        .discount(15L)
                        .quantity(25L)
                        .category(hgangCategory)
                        .build();
                productRepository.save(product18);
            }
            
            // EPIC products
            if (epicCategory != null) {
                Product product19 = Product.builder()
                        .name("Khóa vân tay EPIC ES-F700G")
                        .price(6250000L)
                        .thumbnail("ES-F700G-3-4.png")
                        .description("Khóa vân tay EPIC ES-F700G - Công nghệ vân tay tiên tiến, thiết kế sang trọng.")
                        .discount(20L)
                        .quantity(25L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product19);
                
                Product product20 = Product.builder()
                        .name("Khóa vân tay EPIC ES F300D")
                        .price(4650000L)
                        .thumbnail("ES-F300D_3-4.jpg")
                        .description("Khóa vân tay EPIC ES F300D - Thiết kế hiện đại, giá cả hợp lý.")
                        .discount(15L)
                        .quantity(30L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product20);
                
                Product product21 = Product.builder()
                        .name("EPIC 100D")
                        .price(2400000L)
                        .thumbnail("ES-100-1_3-4.jpg")
                        .description("EPIC 100D - Model cơ bản, dễ sử dụng.")
                        .discount(10L)
                        .quantity(40L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product21);
                
                Product product22 = Product.builder()
                        .name("Khóa vân tay EPIC EF-8000L")
                        .price(6100000L)
                        .thumbnail("EPIC 8000L.jpg")
                        .description("Khóa vân tay EPIC EF-8000L - Công nghệ cao cấp.")
                        .discount(25L)
                        .quantity(20L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product22);
                
                Product product23 = Product.builder()
                        .name("EPIC POPScan M")
                        .price(4290000L)
                        .thumbnail("EPIC POPScan M.jpg")
                        .description("EPIC POPScan M - Công nghệ quét tiên tiến.")
                        .discount(15L)
                        .quantity(25L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product23);
                
                Product product24 = Product.builder()
                        .name("Khóa điện tử EPIC N-Touch")
                        .price(2250000L)
                        .thumbnail("nth.png")
                        .description("Khóa điện tử EPIC N-Touch - Thiết kế cảm ứng hiện đại.")
                        .discount(20L)
                        .quantity(35L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product24);
                
                Product product25 = Product.builder()
                        .name("EPIC 809 L/LR")
                        .price(5200000L)
                        .thumbnail("ES-809L.jpg")
                        .description("EPIC 809 L/LR - Thiết kế cao cấp.")
                        .discount(10L)
                        .quantity(15L)
                        .category(epicCategory)
                        .build();
                productRepository.save(product25);
            }
            
            // WELKOM products
            if (welkomCategory != null) {
                Product product26 = Product.builder()
                        .name("Khóa WELKOM WAT 310")
                        .price(4200000L)
                        .thumbnail("WAT31dd_0.jpg")
                        .description("Khóa WELKOM WAT 310 - Thiết kế hiện đại, giá cả hợp lý.")
                        .discount(20L)
                        .quantity(30L)
                        .category(welkomCategory)
                        .build();
                productRepository.save(product26);
                
                Product product27 = Product.builder()
                        .name("WELKOM WSP-2500B")
                        .price(4800000L)
                        .thumbnail("WDP-2500B_1 3-4.png")
                        .description("WELKOM WSP-2500B - Công nghệ cao cấp.")
                        .discount(15L)
                        .quantity(25L)
                        .category(welkomCategory)
                        .build();
                productRepository.save(product27);
                
                Product product28 = Product.builder()
                        .name("WELKOM WGT330")
                        .price(2590000L)
                        .thumbnail("WGT300_1 3-4.png")
                        .description("WELKOM WGT330 - Model cơ bản, dễ sử dụng.")
                        .discount(10L)
                        .quantity(40L)
                        .category(welkomCategory)
                        .build();
                productRepository.save(product28);
                
                Product product29 = Product.builder()
                        .name("WELKOM WRT300")
                        .price(3800000L)
                        .thumbnail("WRT300_1 3-4.PNG")
                        .description("WELKOM WRT300 - Thiết kế hiện đại.")
                        .discount(25L)
                        .quantity(20L)
                        .category(welkomCategory)
                        .build();
                productRepository.save(product29);
            }
            
            // KAISER+ products
            if (kaiserCategory != null) {
                Product product30 = Product.builder()
                        .name("Khóa vân tay KAISER+ M-1190S")
                        .price(4150000L)
                        .thumbnail("M-1190S_detail 3-4.png")
                        .description("Khóa vân tay KAISER+ M-1190S - Công nghệ vân tay tiên tiến.")
                        .discount(20L)
                        .quantity(30L)
                        .category(kaiserCategory)
                        .build();
                productRepository.save(product30);
                
                Product product31 = Product.builder()
                        .name("Khóa vân tay KAISER+ 7090")
                        .price(7950000L)
                        .thumbnail("Kaiser 3_4.jpg")
                        .description("Khóa vân tay KAISER+ 7090 - Model cao cấp nhất.")
                        .discount(15L)
                        .quantity(15L)
                        .category(kaiserCategory)
                        .build();
                productRepository.save(product31);
                
                Product product32 = Product.builder()
                        .name("Khóa vân tay cửa kính KAISER+ HG-1390")
                        .price(3850000L)
                        .thumbnail("design_03_b 3-4 (1).png")
                        .description("Khóa vân tay cửa kính KAISER+ HG-1390 - Thiết kế cho cửa kính.")
                        .discount(10L)
                        .quantity(25L)
                        .category(kaiserCategory)
                        .build();
                productRepository.save(product32);
            }
            
            // UNICOR products
            if (unicorCategory != null) {
                Product product33 = Product.builder()
                        .name("Khóa vân tay UNICOR UN-7200B")
                        .price(4690000L)
                        .thumbnail("7200B_5 3-4.png")
                        .description("Khóa vân tay UNICOR UN-7200B - Công nghệ vân tay tiên tiến.")
                        .discount(20L)
                        .quantity(25L)
                        .category(unicorCategory)
                        .build();
                productRepository.save(product33);
                
                Product product34 = Product.builder()
                        .name("Khóa điện tử Unicor ZEUS 6700sk")
                        .price(4650000L)
                        .thumbnail("JM6700sk_34.jpg")
                        .description("Khóa điện tử Unicor ZEUS 6700sk - Thiết kế cao cấp.")
                        .discount(15L)
                        .quantity(20L)
                        .category(unicorCategory)
                        .build();
                productRepository.save(product34);
            }
            
            // HiOne+ products
            if (hioneCategory != null) {
                Product product35 = Product.builder()
                        .name("Khóa điện tử HiOne+ M-1100S")
                        .price(2450000L)
                        .thumbnail("img_m1100s_detail 3-4.png")
                        .description("Khóa điện tử HiOne+ M-1100S - Model cơ bản, giá cả hợp lý.")
                        .discount(20L)
                        .quantity(40L)
                        .category(hioneCategory)
                        .build();
                productRepository.save(product35);
                
                Product product36 = Product.builder()
                        .name("Khóa điện tử HiOne+ H-3400SK")
                        .price(3450000L)
                        .thumbnail("H-3400SK_3-4.png")
                        .description("Khóa điện tử HiOne+ H-3400SK - Thiết kế hiện đại.")
                        .discount(15L)
                        .quantity(30L)
                        .category(hioneCategory)
                        .build();
                productRepository.save(product36);
                
                Product product37 = Product.builder()
                        .name("Khóa vân tay HiOne+ H-5490SK")
                        .price(5890000L)
                        .thumbnail("H-5490SK_3-4.png")
                        .description("Khóa vân tay HiOne+ H-5490SK - Công nghệ vân tay cao cấp.")
                        .discount(25L)
                        .quantity(20L)
                        .category(hioneCategory)
                        .build();
                productRepository.save(product37);
            }
            
            // Khóa cửa kính products
            if (glassLockCategory != null) {
                Product product38 = Product.builder()
                        .name("SamSung SHS G510: Khóa cửa kính")
                        .price(3380000L)
                        .thumbnail("SAMSUNG SHS G510_5.jpg")
                        .description("SamSung SHS G510: Khóa cửa kính - Thiết kế cho cửa kính.")
                        .discount(20L)
                        .quantity(25L)
                        .category(glassLockCategory)
                        .build();
                productRepository.save(product38);
                
                Product product39 = Product.builder()
                        .name("Khóa cửa kính H-Gang Sync TG330")
                        .price(3800000L)
                        .thumbnail("TG330_1.jpg")
                        .description("Khóa cửa kính H-Gang Sync TG330 - Thiết kế đồng bộ.")
                        .discount(15L)
                        .quantity(20L)
                        .category(glassLockCategory)
                        .build();
                productRepository.save(product39);
                
                Product product40 = Product.builder()
                        .name("EPIC ES-303 GR: Khóa cửa kính")
                        .price(3450000L)
                        .thumbnail("EPIC ES-303 G (2).jpg")
                        .description("EPIC ES-303 GR: Khóa cửa kính - Công nghệ EPIC cho cửa kính.")
                        .discount(10L)
                        .quantity(30L)
                        .category(glassLockCategory)
                        .build();
                productRepository.save(product40);
                
                Product product41 = Product.builder()
                        .name("Khóa cửa kính TANK GT330")
                        .price(3290000L)
                        .thumbnail("unnamed.jpg")
                        .description("Khóa cửa kính TANK GT330 - Thiết kế chắc chắn.")
                        .discount(25L)
                        .quantity(15L)
                        .category(glassLockCategory)
                        .build();
                productRepository.save(product41);
                
                Product product42 = Product.builder()
                        .name("Khóa cửa kính Sync Auto 2-way TG310")
                        .price(3590000L)
                        .thumbnail("unnamed.jpg")
                        .description("Khóa cửa kính Sync Auto 2-way TG310 - Tự động 2 chiều.")
                        .discount(20L)
                        .quantity(20L)
                        .category(glassLockCategory)
                        .build();
                productRepository.save(product42);
            }
            
            // Chuông cửa hình products
            if (doorbellCategory != null) {
                Product product43 = Product.builder()
                        .name("Chuông cửa hình SAMSUNG SHT-3517NT")
                        .price(4200000L)
                        .thumbnail("sht-3517nt-1.jpg")
                        .description("Chuông cửa hình SAMSUNG SHT-3517NT - Chuông cửa có hình Samsung.")
                        .discount(20L)
                        .quantity(25L)
                        .category(doorbellCategory)
                        .build();
                productRepository.save(product43);
                
                Product product44 = Product.builder()
                        .name("Bộ chuông cửa có hình KOCOM KCV-434 + KC-C60")
                        .price(3890000L)
                        .thumbnail("unnamed.jpg")
                        .description("Bộ chuông cửa có hình KOCOM KCV-434 + KC-C60 - Bộ chuông cửa đầy đủ.")
                        .discount(15L)
                        .quantity(20L)
                        .category(doorbellCategory)
                        .build();
                productRepository.save(product44);
            }
            
            log.info("Real Korean lock products created successfully!");
        }
        
        // Create product images for all products
        if (productImageRepository.count() == 0) {
            log.info("Creating product images...");
            
            // Get all products and create images for each
            List<Product> allProducts = productRepository.findAll();
            for (Product product : allProducts) {
                if (product.getThumbnail() != null && !product.getThumbnail().isEmpty()) {
                    ProductImage image = ProductImage.builder()
                            .product(product)
                            .imageUrl(product.getThumbnail())
                            .build();
                    productImageRepository.save(image);
                }
            }
            
            log.info("Product images created successfully!");
        }

        // Tạo tin tức mẫu nếu chưa có
        if (newsRepository.count() == 0) {
            log.info("Creating sample news...");

            News news1 = News.builder()
                    .title("Khóa điện tử thông minh - Xu hướng bảo mật hiện đại")
                    .content("<h2>Khóa điện tử thông minh - Giải pháp an ninh tối ưu</h2>" +
                            "<p>Trong thời đại công nghệ 4.0, khóa điện tử thông minh đã trở thành lựa chọn hàng đầu cho các gia đình và doanh nghiệp hiện đại. Với khả năng mở khóa đa dạng qua vân tay, mật khẩu, thẻ từ và điện thoại thông minh, khóa điện tử mang lại sự tiện lợi và an toàn tuyệt đối.</p>" +
                            "<h3>Ưu điểm vượt trội</h3>" +
                            "<ul>" +
                            "<li>Bảo mật cao với công nghệ sinh trắc học</li>" +
                            "<li>Dễ dàng quản lý quyền truy cập</li>" +
                            "<li>Không lo mất chìa khóa</li>" +
                            "<li>Thiết kế sang trọng, hiện đại</li>" +
                            "</ul>" +
                            "<p>Hãy liên hệ với chúng tôi để được tư vấn sản phẩm phù hợp nhất!</p>")
                    .status(News.NewsStatus.ACTIVE)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            newsRepository.save(news1);

            News news2 = News.builder()
                    .title("Samsung Smart Lock - Khóa thông minh kết nối với smartphone")
                    .content("<h2>Samsung Smart Lock - Công nghệ từ Hàn Quốc</h2>" +
                            "<p>Samsung, thương hiệu điện tử hàng đầu thế giới, đã mang đến giải pháp khóa cửa thông minh với công nghệ tiên tiến nhất. Sản phẩm có thể kết nối với smartphone qua Bluetooth và WiFi, cho phép bạn kiểm soát khóa từ xa.</p>" +
                            "<h3>Tính năng nổi bật</h3>" +
                            "<ul>" +
                            "<li>Kết nối smartphone qua ứng dụng SmartThings</li>" +
                            "<li>Nhận thông báo mở/đóng cửa theo thời gian thực</li>" +
                            "<li>Cấp quyền truy cập tạm thời cho khách</li>" +
                            "<li>Pin sử dụng lên đến 12 tháng</li>" +
                            "</ul>" +
                            "<p>Trải nghiệm sự tiện lợi của ngôi nhà thông minh ngay hôm nay!</p>")
                    .status(News.NewsStatus.ACTIVE)
                    .createdAt(LocalDateTime.now().minusDays(1))
                    .updatedAt(LocalDateTime.now().minusDays(1))
                    .build();
            newsRepository.save(news2);

            News news3 = News.builder()
                    .title("Hướng dẫn lắp đặt và sử dụng khóa điện tử")
                    .content("<h2>Hướng dẫn lắp đặt khóa điện tử chi tiết</h2>" +
                            "<p>Lắp đặt khóa điện tử không quá phức tạp nếu bạn nắm được các bước cơ bản. Dưới đây là hướng dẫn từng bước để bạn có thể tự lắp đặt tại nhà.</p>" +
                            "<h3>Các bước lắp đặt</h3>" +
                            "<ol>" +
                            "<li><strong>Chuẩn bị:</strong> Kiểm tra bộ sản phẩm đầy đủ, chuẩn bị dụng cụ (tua vít, thước đo)</li>" +
                            "<li><strong>Tháo khóa cũ:</strong> Gỡ bỏ khóa cơ cũ một cách cẩn thận</li>" +
                            "<li><strong>Lắp phần trong:</strong> Gắn phần thân trong vào cửa</li>" +
                            "<li><strong>Lắp phần ngoài:</strong> Gắn phần thân ngoài và kết nối dây điện</li>" +
                            "<li><strong>Kiểm tra:</strong> Test khóa nhiều lần để đảm bảo hoạt động tốt</li>" +
                            "</ol>" +
                            "<p><em>Lưu ý: Nếu không tự tin, hãy liên hệ với đội ngũ kỹ thuật của chúng tôi để được hỗ trợ lắp đặt miễn phí!</em></p>")
                    .status(News.NewsStatus.ACTIVE)
                    .createdAt(LocalDateTime.now().minusDays(3))
                    .updatedAt(LocalDateTime.now().minusDays(3))
                    .build();
            newsRepository.save(news3);

            News news4 = News.builder()
                    .title("So sánh các dòng khóa cửa thông minh phổ biến")
                    .content("<h2>So sánh Gateman, Samsung và H-Gang</h2>" +
                            "<p>Trên thị trường hiện nay có rất nhiều thương hiệu khóa điện tử. Ba thương hiệu phổ biến nhất là Gateman, Samsung và H-Gang. Mỗi thương hiệu đều có ưu điểm riêng.</p>" +
                            "<h3>Gateman</h3>" +
                            "<p>Thương hiệu Hàn Quốc nổi tiếng với độ bền cao và thiết kế sang trọng. Giá từ 5-15 triệu đồng.</p>" +
                            "<h3>Samsung</h3>" +
                            "<p>Tích hợp công nghệ SmartThings, kết nối IoT tốt. Giá từ 7-20 triệu đồng.</p>" +
                            "<h3>H-Gang</h3>" +
                            "<p>Giá rẻ hơn nhưng vẫn đảm bảo chất lượng. Phù hợp cho mọi gia đình. Giá từ 3-8 triệu đồng.</p>" +
                            "<p>Liên hệ để được tư vấn sản phẩm phù hợp với ngân sách và nhu cầu của bạn!</p>")
                    .status(News.NewsStatus.ACTIVE)
                    .createdAt(LocalDateTime.now().minusDays(5))
                    .updatedAt(LocalDateTime.now().minusDays(5))
                    .build();
            newsRepository.save(news4);

            log.info("Sample news created successfully!");
        }
    }
}