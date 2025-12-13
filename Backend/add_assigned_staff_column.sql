ALTER TABLE orders ADD COLUMN assigned_staff_id INT;
ALTER TABLE orders ADD CONSTRAINT fk_orders_assigned_staff FOREIGN KEY (assigned_staff_id) REFERENCES users(id);
