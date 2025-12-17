/**
 * Order Status Constants
 * Định nghĩa thống nhất các trạng thái đơn hàng cho toàn bộ ứng dụng
 */

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  PAID = 'paid',
  PAYMENT_FAILED = 'payment_failed'
}

export interface OrderStatusOption {
  label: string;
  value: string;
}

/**
 * Danh sách đầy đủ các trạng thái đơn hàng với nhãn tiếng Việt
 * Sử dụng cho dropdown filter và hiển thị
 */
export const ORDER_STATUS_OPTIONS: OrderStatusOption[] = [
  { label: 'Tất cả', value: '' },
  { label: 'Đang chờ', value: OrderStatus.PENDING },
  { label: 'Đang xử lý', value: OrderStatus.PROCESSING },
  { label: 'Đang được giao', value: OrderStatus.SHIPPED },
  { label: 'Đã được giao', value: OrderStatus.DELIVERED },
  { label: 'Đã hủy', value: OrderStatus.CANCELLED },
  { label: 'Thanh toán thành công', value: OrderStatus.PAID },
  { label: 'Thanh toán thất bại', value: OrderStatus.PAYMENT_FAILED }
];

/**
 * Danh sách trạng thái đơn hàng (không bao gồm "Tất cả")
 * Sử dụng cho dropdown cập nhật trạng thái
 */
export const ORDER_STATUS_UPDATE_OPTIONS: OrderStatusOption[] = [
  { label: 'Đang chờ', value: OrderStatus.PENDING },
  { label: 'Đang xử lý', value: OrderStatus.PROCESSING },
  { label: 'Đang được giao', value: OrderStatus.SHIPPED },
  { label: 'Đã được giao', value: OrderStatus.DELIVERED },
  { label: 'Đã hủy', value: OrderStatus.CANCELLED },
  { label: 'Thanh toán thành công', value: OrderStatus.PAID },
  { label: 'Thanh toán thất bại', value: OrderStatus.PAYMENT_FAILED }
];

/**
 * Map trạng thái sang nhãn tiếng Việt
 */
export const ORDER_STATUS_LABELS: { [key: string]: string } = {
  [OrderStatus.PENDING]: 'Đang chờ',
  [OrderStatus.PROCESSING]: 'Đang xử lý',
  [OrderStatus.SHIPPED]: 'Đang được giao',
  [OrderStatus.DELIVERED]: 'Đã được giao',
  [OrderStatus.CANCELLED]: 'Đã hủy',
  [OrderStatus.PAID]: 'Thanh toán thành công',
  [OrderStatus.PAYMENT_FAILED]: 'Thanh toán thất bại'
};

/**
 * Map trạng thái sang severity cho PrimeNG Tag component
 */
export const ORDER_STATUS_SEVERITY: { [key: string]: 'info' | 'warning' | 'success' | 'danger' | 'primary' } = {
  [OrderStatus.PENDING]: 'warning',
  [OrderStatus.PROCESSING]: 'info',
  [OrderStatus.SHIPPED]: 'primary',
  [OrderStatus.DELIVERED]: 'success',
  [OrderStatus.PAID]: 'success',
  [OrderStatus.CANCELLED]: 'danger',
  [OrderStatus.PAYMENT_FAILED]: 'danger'
};

/**
 * Lấy nhãn tiếng Việt của trạng thái đơn hàng
 */
export function getOrderStatusLabel(status: string): string {
  return ORDER_STATUS_LABELS[status] || 'Không xác định';
}

/**
 * Lấy severity của trạng thái đơn hàng
 */
export function getOrderStatusSeverity(status: string): 'info' | 'warning' | 'success' | 'danger' | 'primary' {
  return ORDER_STATUS_SEVERITY[status] || 'info';
}








