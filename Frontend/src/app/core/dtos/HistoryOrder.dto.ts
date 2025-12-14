export interface HistoryOrderDto {
    id: number,
    status: string,
    thumbnail: string,
    total_money: number,
    total_products: number,
    product_name: string,
    order_date: Date,
    fullname: string,  // Changed from buyer_name to match backend
    phone_number: string,
    email: string,
    brand?: string,
    payment_method?: string,
    shipping_method?: string,
    address?: string,
    assigned_staff_name?: string
}