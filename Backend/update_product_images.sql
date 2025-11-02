-- Update product thumbnails and images with new images from folders

-- GATEMAN products
-- WF20
UPDATE `products` SET `thumbnail` = 'WF20_1 3-4.jpg' WHERE `name` LIKE '%WF-20%' OR `name` LIKE '%WF20%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'WF20_1 3-4.jpg' FROM `products` WHERE (`name` LIKE '%WF-20%' OR `name` LIKE '%WF20%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'WF20_1 3-4.jpg');

-- WG-200
UPDATE `products` SET `thumbnail` = 'wg-200 3-4.jpg' WHERE `name` LIKE '%WG-200%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'wg-200 3-4.jpg' FROM `products` WHERE `name` LIKE '%WG-200%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'wg-200 3-4.jpg');

-- Z10
UPDATE `products` SET `thumbnail` = 'Z10_3 3-4.jpg' WHERE `name` LIKE '%Z10%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'Z10_3 3-4.jpg' FROM `products` WHERE `name` LIKE '%Z10%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'Z10_3 3-4.jpg');

-- F300-FH
UPDATE `products` SET `thumbnail` = 'Gateman F300-FH.jpg' WHERE `name` LIKE '%F300%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'Gateman F300-FH.jpg' FROM `products` WHERE `name` LIKE '%F300%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'Gateman F300-FH.jpg');

-- F50-FH
UPDATE `products` SET `thumbnail` = 'Gateman F50-FH.jpg' WHERE `name` LIKE '%F50%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'Gateman F50-FH.jpg' FROM `products` WHERE `name` LIKE '%F50%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'Gateman F50-FH.jpg');

-- WF200
UPDATE `products` SET `thumbnail` = 'wf-200_34.jpg' WHERE `name` LIKE '%WF200%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'wf-200_34.jpg' FROM `products` WHERE `name` LIKE '%WF200%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'wf-200_34.jpg');

-- SAMSUNG products
-- SHP-DH538
UPDATE `products` SET `thumbnail` = 'DH538_co 3-4.jpg' WHERE `name` LIKE '%DH538%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'DH538_co 3-4.jpg' FROM `products` WHERE `name` LIKE '%DH538%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'DH538_co 3-4.jpg');

-- SHS P718
UPDATE `products` SET `thumbnail` = 'SHS-P718_3-4.png' WHERE `name` LIKE '%P718%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'SHS-P718_3-4.png' FROM `products` WHERE `name` LIKE '%P718%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'SHS-P718_3-4.png');

-- SHS-2920
UPDATE `products` SET `thumbnail` = 'SHS-2920_1.jpg' WHERE `name` LIKE '%2920%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'SHS-2920_1.jpg' FROM `products` WHERE `name` LIKE '%2920%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'SHS-2920_1.jpg');

-- SHP-DS700
UPDATE `products` SET `thumbnail` = 'SHP-DS700_1.jpg' WHERE `name` LIKE '%DS700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'SHP-DS700_1.jpg' FROM `products` WHERE `name` LIKE '%DS700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'SHP-DS700_1.jpg');

-- SHS 1321
UPDATE `products` SET `thumbnail` = '1321-1-3-4.jpg' WHERE `name` LIKE '%1321%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, '1321-1-3-4.jpg' FROM `products` WHERE `name` LIKE '%1321%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = '1321-1-3-4.jpg');

-- SHP-DP930
UPDATE `products` SET `thumbnail` = 'SAMSUNG DP920.jpg' WHERE `name` LIKE '%DP930%' OR `name` LIKE '%DP920%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'SAMSUNG DP920.jpg' FROM `products` WHERE (`name` LIKE '%DP930%' OR `name` LIKE '%DP920%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'SAMSUNG DP920.jpg');

-- SHS-H700
UPDATE `products` SET `thumbnail` = '700_mat ngoaiw.png' WHERE `name` LIKE '%H700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, '700_mat ngoaiw.png' FROM `products` WHERE `name` LIKE '%H700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = '700_mat ngoaiw.png');

-- SHT-3517NT
UPDATE `products` SET `thumbnail` = 'sht-3517nt-1.jpg' WHERE `name` LIKE '%3517%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'sht-3517nt-1.jpg' FROM `products` WHERE `name` LIKE '%3517%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'sht-3517nt-1.jpg');

-- SHS G510
UPDATE `products` SET `thumbnail` = 'SAMSUNG SHS G510_5.jpg' WHERE `name` LIKE '%G510%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'SAMSUNG SHS G510_5.jpg' FROM `products` WHERE `name` LIKE '%G510%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'SAMSUNG SHS G510_5.jpg');

-- H-Gang products
-- TR812
UPDATE `products` SET `thumbnail` = 'TR812_3-4.png' WHERE `name` LIKE '%TR812%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'TR812_3-4.png' FROM `products` WHERE `name` LIKE '%TR812%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'TR812_3-4.png');

-- TG330
UPDATE `products` SET `thumbnail` = 'TG330_1.jpg' WHERE `name` LIKE '%TG330%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'TG330_1.jpg' FROM `products` WHERE `name` LIKE '%TG330%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'TG330_1.jpg');

-- TM700
UPDATE `products` SET `thumbnail` = 'TM700_3-4.png' WHERE `name` LIKE '%TM700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'TM700_3-4.png' FROM `products` WHERE `name` LIKE '%TM700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'TM700_3-4.png');

-- TR700
UPDATE `products` SET `thumbnail` = 'TR700_3-4.png' WHERE `name` LIKE '%TR700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'TR700_3-4.png' FROM `products` WHERE `name` LIKE '%TR700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'TR700_3-4.png');

-- TS700
UPDATE `products` SET `thumbnail` = 'TS700_3_4.png' WHERE `name` LIKE '%TS700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'TS700_3_4.png' FROM `products` WHERE `name` LIKE '%TS700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'TS700_3_4.png');

-- EPIC products
-- ES-F700G
UPDATE `products` SET `thumbnail` = 'ES-F700G-3-4.png' WHERE `name` LIKE '%F700G%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'ES-F700G-3-4.png' FROM `products` WHERE `name` LIKE '%F700G%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'ES-F700G-3-4.png');

-- ES F300D
UPDATE `products` SET `thumbnail` = 'ES-F300D_3-4.jpg' WHERE `name` LIKE '%F300D%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'ES-F300D_3-4.jpg' FROM `products` WHERE `name` LIKE '%F300D%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'ES-F300D_3-4.jpg');

-- ES-100D
UPDATE `products` SET `thumbnail` = 'ES-100-1_3-4.jpg' WHERE `name` LIKE '%100D%' OR `name` LIKE '%ES-100%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'ES-100-1_3-4.jpg' FROM `products` WHERE (`name` LIKE '%100D%' OR `name` LIKE '%ES-100%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'ES-100-1_3-4.jpg');

-- EF-8000L
UPDATE `products` SET `thumbnail` = 'EPIC 8000L.jpg' WHERE `name` LIKE '%8000L%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'EPIC 8000L.jpg' FROM `products` WHERE `name` LIKE '%8000L%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'EPIC 8000L.jpg');

-- ES-303
UPDATE `products` SET `thumbnail` = 'EPIC ES-303 G (2).jpg' WHERE `name` LIKE '%ES-303%' AND (`name` LIKE '%kính%' OR `name` LIKE '%GR%');
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'EPIC ES-303 G (2).jpg' FROM `products` WHERE `name` LIKE '%ES-303%' AND (`name` LIKE '%kính%' OR `name` LIKE '%GR%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'EPIC ES-303 G (2).jpg');

-- POPScan M
UPDATE `products` SET `thumbnail` = 'EPIC POPScan M.jpg' WHERE `name` LIKE '%POPScan%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'EPIC POPScan M.jpg' FROM `products` WHERE `name` LIKE '%POPScan%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'EPIC POPScan M.jpg');

-- 809 L/LR
UPDATE `products` SET `thumbnail` = 'ES-809L.jpg' WHERE `name` LIKE '%809%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'ES-809L.jpg' FROM `products` WHERE `name` LIKE '%809%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'ES-809L.jpg');

-- WELKOM products
-- WAT 310
UPDATE `products` SET `thumbnail` = 'WAT31dd_0.jpg' WHERE `name` LIKE '%WAT%' OR `name` LIKE '%310%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'WAT31dd_0.jpg' FROM `products` WHERE (`name` LIKE '%WAT%' OR `name` LIKE '%310%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'WAT31dd_0.jpg');

-- WSP-2500B
UPDATE `products` SET `thumbnail` = 'WDP-2500B_1 3-4.png' WHERE `name` LIKE '%2500%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'WDP-2500B_1 3-4.png' FROM `products` WHERE `name` LIKE '%2500%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'WDP-2500B_1 3-4.png');

-- WGT330
UPDATE `products` SET `thumbnail` = 'WGT300_1 3-4.png' WHERE `name` LIKE '%WGT%' OR `name` LIKE '%330%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'WGT300_1 3-4.png' FROM `products` WHERE (`name` LIKE '%WGT%' OR `name` LIKE '%330%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'WGT300_1 3-4.png');

-- WRT300
UPDATE `products` SET `thumbnail` = 'WRT300_1 3-4.PNG' WHERE `name` LIKE '%WRT%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'WRT300_1 3-4.PNG' FROM `products` WHERE `name` LIKE '%WRT%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'WRT300_1 3-4.PNG');

-- KAISER+ products
-- M-1190S
UPDATE `products` SET `thumbnail` = 'M-1190S_detail 3-4.png' WHERE `name` LIKE '%1190S%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'M-1190S_detail 3-4.png' FROM `products` WHERE `name` LIKE '%1190S%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'M-1190S_detail 3-4.png');

-- 7090
UPDATE `products` SET `thumbnail` = 'Kaiser 3_4.jpg' WHERE `name` LIKE '%7090%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'Kaiser 3_4.jpg' FROM `products` WHERE `name` LIKE '%7090%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'Kaiser 3_4.jpg');

-- UNICOR products
-- UN-7200B
UPDATE `products` SET `thumbnail` = '7200B_5 3-4.png' WHERE `name` LIKE '%7200%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, '7200B_5 3-4.png' FROM `products` WHERE `name` LIKE '%7200%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = '7200B_5 3-4.png');

-- ZEUS 6700sk
UPDATE `products` SET `thumbnail` = 'JM6700sk_34.jpg' WHERE `name` LIKE '%6700%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'JM6700sk_34.jpg' FROM `products` WHERE `name` LIKE '%6700%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'JM6700sk_34.jpg');

-- HiOne+ products
-- M-1100S
UPDATE `products` SET `thumbnail` = 'img_m1100s_detail 3-4.png' WHERE `name` LIKE '%M-1100S%' OR `name` LIKE '%1100S%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'img_m1100s_detail 3-4.png' FROM `products` WHERE (`name` LIKE '%M-1100S%' OR `name` LIKE '%1100S%') AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'img_m1100s_detail 3-4.png');

-- H-3400SK
UPDATE `products` SET `thumbnail` = 'H-3400SK_3-4.png' WHERE `name` LIKE '%3400%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'H-3400SK_3-4.png' FROM `products` WHERE `name` LIKE '%3400%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'H-3400SK_3-4.png');

-- H-5490SK
UPDATE `products` SET `thumbnail` = 'H-5490SK_3-4.png' WHERE `name` LIKE '%5490%';
INSERT INTO `product_images` (`product_id`, `image_url`) 
SELECT `id`, 'H-5490SK_3-4.png' FROM `products` WHERE `name` LIKE '%5490%' AND NOT EXISTS (SELECT 1 FROM `product_images` WHERE `product_id` = `products`.`id` AND `image_url` = 'H-5490SK_3-4.png');

