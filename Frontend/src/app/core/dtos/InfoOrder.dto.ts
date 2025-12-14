import { OrderDetailDto } from "./OrderDetail.dto";

export interface InfoOrderDto {
    id: number,
    fullname: string,
    email: string,
    phone_number: string,
    address: string,
    note: string,
    shipping_method: string,
    payment_method: string,
    order_date: Date,
    status: string,
    order_details: OrderDetailDto[],
    total_money?: number,
    voucher?: {
        code: string,
        name: string,
        discount_percentage: number
    },
    discount_amount?: number;
    tracking_number?: string;
    carrier?: string;
    tracking_info?: any;
    district_id?: number;
    ward_code?: string;
    assigned_staff?: {
        id: number;
        fullname: string;
        phone_number: string;
    };
    payment_intent_id?: string;
    vnp_txn_ref?: string;
    vnp_transaction_no?: string;
}