import { Injectable } from '@angular/core';
import { InfoOrderDto } from '../dtos/InfoOrder.dto';
import { OrderDetailDto } from '../dtos/OrderDetail.dto';

@Injectable({
  providedIn: 'root'
})
export class InvoicePdfService {

  async generateInvoicePDF(
    orderInfo: InfoOrderDto,
    orderDetails: OrderDetailDto[],
    totalMoney: number,
    shipCost: number,
    discountAmount: number,
    finalTotal: number,
    voucherInfo: { code: string, name: string, percentage: number } | null,
    apiImage: string
  ): Promise<void> {
    try {
      // Dynamic import of jsPDF and html2canvas
      const [{ default: jsPDF }, { default: html2canvas }] = await Promise.all([
        import('jspdf'),
        import('html2canvas')
      ]);

      // Create a temporary container for the invoice
      const invoiceHTML = this.buildInvoiceHTML(
        orderInfo,
        orderDetails,
        totalMoney,
        shipCost,
        discountAmount,
        finalTotal,
        voucherInfo,
        apiImage
      );

      // Create a temporary div to render the invoice
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = invoiceHTML;
      tempDiv.style.position = 'absolute';
      tempDiv.style.left = '-9999px';
      tempDiv.style.width = '210mm'; // A4 width
      tempDiv.style.padding = '20mm';
      tempDiv.style.backgroundColor = '#ffffff';
      tempDiv.style.fontFamily = 'Arial, sans-serif';
      document.body.appendChild(tempDiv);

      // Wait for images to load
      await this.waitForImages(tempDiv);

      // Generate canvas from HTML
      const canvas = await html2canvas(tempDiv, {
        scale: 2,
        useCORS: true,
        logging: false,
        backgroundColor: '#ffffff',
        width: tempDiv.scrollWidth,
        height: tempDiv.scrollHeight
      });

      // Remove temporary div
      document.body.removeChild(tempDiv);

      // Create PDF
      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF('p', 'mm', 'a4');
      
      const imgWidth = 210; // A4 width in mm
      const pageHeight = 297; // A4 height in mm
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;
      let position = 0;

      // Add first page
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      // Add additional pages if needed
      while (heightLeft > 0) {
        position = heightLeft - imgHeight;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      // Save PDF
      const fileName = `HoaDon_${orderInfo.id}_${new Date().getTime()}.pdf`;
      pdf.save(fileName);
    } catch (error) {
      console.error('Error generating PDF:', error);
      throw new Error('Không thể tạo file PDF. Vui lòng thử lại.');
    }
  }

  private buildInvoiceHTML(
    orderInfo: InfoOrderDto,
    orderDetails: OrderDetailDto[],
    totalMoney: number,
    shipCost: number,
    discountAmount: number,
    finalTotal: number,
    voucherInfo: { code: string, name: string, percentage: number } | null,
    apiImage: string
  ): string {
    const orderDate = new Date(orderInfo.order_date).toLocaleDateString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    let productsHTML = '';
    orderDetails.forEach(item => {
      productsHTML += `
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">
            <div style="display: flex; align-items: center; gap: 10px;">
              <img src="${apiImage + item.product?.thumbnail}" 
                   alt="${item.product?.name}" 
                   style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
              <div>
                <div style="font-weight: 500;">${item.product?.name || ''}</div>
                ${item.product?.brand ? `<div style="font-size: 12px; color: #666;">Thương hiệu: ${item.product.brand}</div>` : ''}
              </div>
            </div>
          </td>
          <td style="padding: 8px; text-align: right; border-bottom: 1px solid #ddd;">${this.formatCurrency(item.price)}</td>
          <td style="padding: 8px; text-align: center; border-bottom: 1px solid #ddd;">${item.number_of_products}</td>
          <td style="padding: 8px; text-align: right; font-weight: 600; border-bottom: 1px solid #ddd;">${this.formatCurrency(item.total_money)}</td>
        </tr>
      `;
    });

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20mm;
            color: #333;
          }
          .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #673AB7;
            padding-bottom: 20px;
            margin-bottom: 30px;
          }
          .invoice-branding {
            flex: 1;
          }
          .invoice-logo {
            max-height: 80px;
            margin-bottom: 10px;
          }
          .store-name {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            margin: 5px 0;
          }
          .store-tagline {
            font-size: 14px;
            color: #6c757d;
            font-style: italic;
          }
          .invoice-info {
            text-align: right;
          }
          .invoice-title {
            font-size: 28px;
            font-weight: 700;
            color: #673AB7;
            margin-bottom: 10px;
          }
          .customer-order-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
          }
          .info-section {
            flex: 1;
            padding: 0 15px;
          }
          .info-section:first-child {
            padding-left: 0;
          }
          .info-section:last-child {
            padding-right: 0;
          }
          .section-title {
            font-size: 16px;
            font-weight: 600;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 8px;
            margin-bottom: 15px;
            color: #673AB7;
          }
          .info-section p {
            margin: 8px 0;
            font-size: 14px;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
          }
          thead th {
            background-color: #673AB7;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
          }
          thead th:last-child {
            text-align: right;
          }
          tbody td {
            padding: 12px;
          }
          .order-summary {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 30px;
          }
          .summary-details {
            width: 100%;
            max-width: 400px;
          }
          .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e9ecef;
            font-size: 14px;
          }
          .summary-item.total {
            font-size: 18px;
            font-weight: 700;
            padding-top: 15px;
            margin-top: 10px;
            border-top: 2px solid #673AB7;
            border-bottom: none;
            color: #673AB7;
          }
          .invoice-footer {
            text-align: center;
            padding-top: 30px;
            border-top: 2px solid #e9ecef;
            color: #6c757d;
            font-size: 14px;
          }
          .thank-you-message {
            margin-top: 20px;
          }
          .thank-you-message p:first-child {
            font-size: 16px;
            font-weight: 600;
            color: #2c3e50;
          }
        </style>
      </head>
      <body>
        <div class="invoice-header">
          <div class="invoice-branding">
            <div class="store-name">Korea Lock Store</div>
            <div class="store-tagline">Chuyên cung cấp khóa vân tay cao cấp</div>
          </div>
          <div class="invoice-info">
            <div class="invoice-title">HÓA ĐƠN BÁN HÀNG</div>
            <div style="font-size: 14px; color: #666;">Mã đơn: #${orderInfo.id}</div>
          </div>
        </div>

        <div class="customer-order-info">
          <div class="info-section">
            <h5 class="section-title">Thông tin khách hàng</h5>
            <p><strong>Họ tên:</strong> ${orderInfo.fullname}</p>
            <p><strong>Số điện thoại:</strong> ${orderInfo.phone_number}</p>
            <p><strong>Email:</strong> ${orderInfo.email}</p>
            <p><strong>Địa chỉ:</strong> ${orderInfo.address}</p>
          </div>
          <div class="info-section">
            <h5 class="section-title">Chi tiết hóa đơn</h5>
            <p><strong>Mã hóa đơn:</strong> #${orderInfo.id}</p>
            <p><strong>Ngày đặt:</strong> ${orderDate}</p>
            <p><strong>Phương thức thanh toán:</strong> ${orderInfo.payment_method}</p>
            <p><strong>Phương thức vận chuyển:</strong> ${orderInfo.shipping_method || 'N/A'}</p>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th>Sản phẩm</th>
              <th style="text-align: right;">Đơn giá</th>
              <th style="text-align: center;">Số lượng</th>
              <th style="text-align: right;">Tổng cộng</th>
            </tr>
          </thead>
          <tbody>
            ${productsHTML}
          </tbody>
        </table>

        <div class="order-summary">
          <div class="summary-details">
            <div class="summary-item">
              <span>Tạm tính:</span>
              <span>${this.formatCurrency(totalMoney)}</span>
            </div>
            ${voucherInfo ? `
            <div class="summary-item">
              <span>Giảm giá (${voucherInfo.code} - ${voucherInfo.percentage}%):</span>
              <span style="color: #dc3545;">-${this.formatCurrency(discountAmount)}</span>
            </div>
            ` : ''}
            <div class="summary-item">
              <span>Phí vận chuyển:</span>
              <span>${this.formatCurrency(shipCost)}</span>
            </div>
            <div class="summary-item total">
              <span>Tổng thanh toán:</span>
              <span>${this.formatCurrency(finalTotal)}</span>
            </div>
          </div>
        </div>

        ${orderInfo.note ? `
        <div style="margin-bottom: 30px; padding: 15px; background-color: #f8f9fa; border-radius: 8px;">
          <strong>Ghi chú:</strong> ${orderInfo.note}
        </div>
        ` : ''}

        <div class="invoice-footer">
          <div class="thank-you-message">
            <p>Cảm ơn bạn đã tin tưởng và lựa chọn Korea Lock Store!</p>
            <p>Chúng tôi đã gửi thông tin xác nhận đến email của bạn.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private formatCurrency(amount: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  }

  private waitForImages(element: HTMLElement): Promise<void> {
    const images = element.querySelectorAll('img');
    const imagePromises: Promise<void>[] = [];

    images.forEach((img: HTMLImageElement) => {
      if (!img.complete) {
        const promise = new Promise<void>((resolve) => {
          img.onload = () => resolve();
          img.onerror = () => resolve(); // Continue even if image fails
        });
        imagePromises.push(promise);
      }
    });

    return Promise.all(imagePromises).then(() => {});
  }
}

