export interface OrderDto {
  user_id?: number;
  fullname: string;
  email: string;
  phone_number: string;
  address: string;
  note: string;
  shipping_method: string;
  payment_method: string;
  cart_items: {
    product_id: number;
    quantity: number;
    size: number;
  }[];
  sub_total: number;
  total_money: number;
  voucher_code?: string;
  district_id?: number;
  ward_code?: string;
}
