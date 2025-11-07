-- Fix Foreign Key Constraint Errors for carts table
-- Run this BEFORE adding FK constraints in shopsneaker3.sql

-- Step 1: Check for orphan records in carts (user_id not in users)
SELECT c.id, c.user_id, 'orphan user_id' as issue
FROM carts c
LEFT JOIN users u ON c.user_id = u.id
WHERE c.user_id IS NOT NULL AND u.id IS NULL;

-- Step 2: Check for orphan records in carts (product_id not in products)
SELECT c.id, c.product_id, 'orphan product_id' as issue
FROM carts c
LEFT JOIN products p ON c.product_id = p.id
WHERE c.product_id IS NOT NULL AND p.id IS NULL;

-- Step 3: Option A - Delete orphan cart records (RECOMMENDED if they're invalid)
-- Uncomment the lines below to execute:

-- DELETE FROM carts 
-- WHERE user_id IS NOT NULL 
-- AND user_id NOT IN (SELECT id FROM users);

-- DELETE FROM carts 
-- WHERE product_id IS NOT NULL 
-- AND product_id NOT IN (SELECT id FROM products);

-- Step 4: Option B - Set orphan foreign keys to NULL (if you want to keep the records)
-- Uncomment the lines below to execute:

-- UPDATE carts 
-- SET user_id = NULL 
-- WHERE user_id IS NOT NULL 
-- AND user_id NOT IN (SELECT id FROM users);

-- UPDATE carts 
-- SET product_id = NULL 
-- WHERE product_id IS NOT NULL 
-- AND product_id NOT IN (SELECT id FROM products);

-- Step 5: Verify no orphans remain
SELECT 
    (SELECT COUNT(*) FROM carts c 
     LEFT JOIN users u ON c.user_id = u.id 
     WHERE c.user_id IS NOT NULL AND u.id IS NULL) as orphan_users,
    (SELECT COUNT(*) FROM carts c 
     LEFT JOIN products p ON c.product_id = p.id 
     WHERE c.product_id IS NOT NULL AND p.id IS NULL) as orphan_products;

-- Step 6: After cleanup, you can safely add FK constraints:
-- ALTER TABLE `carts`
--   ADD CONSTRAINT `FK__products` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
--   ADD CONSTRAINT `FK__users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
