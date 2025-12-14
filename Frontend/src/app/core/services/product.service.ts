import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment.development';
import { ProductDto } from '../dtos/product.dto';
import { AllProductDto } from '../dtos/AllProduct.dto';
import { ProductToCartDto } from '../dtos/productToCart.dto';
import { ProductFromCartDto } from '../dtos/ProductFromCart.dto';
import { Observable, Subject } from 'rxjs';
import { ProductUploadReq } from '../requestType/UploadProducts';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private apiUrl: string = environment.apiUrl;
  public isOrder = new Subject<boolean>();

  constructor(
    private httpClient: HttpClient
  ) {}

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    let headers = new HttpHeaders({
      'Content-Type': 'application/json'
    });

    if (token) {
      headers = headers.set('Authorization', `Bearer ${token}`);
    } else {
      let sessionId = localStorage.getItem('guest_session_id');
      if (!sessionId) {
        sessionId = this.generateSessionId();
        localStorage.setItem('guest_session_id', sessionId);
      }
      headers = headers.set('x-guest-session-id', sessionId);
    }
    return headers;
  }

  private generateSessionId(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  private getFileUploadHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getAllProduct(page: number = 0, limit: number = 12, sort: string = 'id,desc', keyword: string = '', categoryId: number = 0, minPrice: number = 0, maxPrice: number = 50000000) {
    let url = `${this.apiUrl}/products/all?page=${page}&limit=${limit}&sort=${sort}`;
    if (keyword) url += `&keyword=${keyword}`;
    if (categoryId > 0) url += `&category_id=${categoryId}`;
    if (minPrice > 0 || maxPrice < 50000000) url += `&min_price=${minPrice}&max_price=${maxPrice}`;
    return this.httpClient.get<AllProductDto>(url);
  }

  getProductById(id: string) {
    return this.httpClient.get<ProductDto>(`${this.apiUrl}/products/${id}`);
  }

  getProductViaPrice(minPrice: number, maxPrice: number) {
    return this.httpClient.get<AllProductDto>(`${this.apiUrl}/products/price?min_price=${minPrice}&max_price=${maxPrice}`);
  }

  addProductToCart(product: ProductToCartDto) {
    return this.httpClient.post(`${this.apiUrl}/carts`, product, {
      headers: this.getAuthHeaders()
    });
  }

  removeProductFromCart(id: number){
    return this.httpClient.post(`${this.apiUrl}/carts/${id}`, {
      headers: this.getAuthHeaders()
    });
  }

  searchProduct(content: string){
    return this.httpClient.get<AllProductDto>(`${this.apiUrl}/products/search?keyword=${content}`);
  }

  getProductFromCart(){
    return this.httpClient.get<ProductFromCartDto>(`${this.apiUrl}/carts`, {
      headers: this.getAuthHeaders()
    });
  }

  updateProductFromCart(idCart: number, product: ProductToCartDto){
    return this.httpClient.put(`${this.apiUrl}/carts/${idCart}`, product, {
      headers: this.getAuthHeaders()
    });
  }

  deleteProductFromCart(id: number){
    return this.httpClient.delete(`${this.apiUrl}/carts/${id}`, {
      headers: this.getAuthHeaders()
    });
  }

  deleteAllProductsFromCart(){
    return this.httpClient.delete(`${this.apiUrl}/carts`, {
      headers: this.getAuthHeaders()
    });
  }

  getRelatedProduct(id: string){
    return this.httpClient.get<AllProductDto>(`${this.apiUrl}/products/related/${id}`)
  }
  
  deleteProduct(id: string){
    return this.httpClient.delete(`${this.apiUrl}/products/${id}`, {
      headers: this.getAuthHeaders(),
      responseType: 'text'
    })
  }

  uploadProduct(product: ProductUploadReq){
    return this.httpClient.post<{productId: number, message: string}>(`${this.apiUrl}/products`, product, {
      headers: this.getAuthHeaders()
    })
  }

  uploadImageProduct(files : FormData, id: number){
    const token = localStorage.getItem('token');
    // Do NOT set Content-Type header manually for FormData.
    // The browser will do it automatically with the correct boundary.
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    return this.httpClient.post<{message: string}>(`${this.apiUrl}/products/uploads/${id}`, files, { headers: headers });
  }
  
  updateProduct(product: ProductUploadReq, id: number){
    return this.httpClient.put<{message: string}>(`${this.apiUrl}/products/${id}`, product, {
      headers: this.getAuthHeaders()
    })
  }

  deleteProductImage(id: number): Observable<any> {
    return this.httpClient.delete(`${this.apiUrl}/products/images/${id}`, {
      headers: this.getAuthHeaders(),
      responseType: 'text' // Expect a text response ("...deleted successfully")
    });
  }

  updateProductThumbnail(productId: number, thumbnailUrl: string): Observable<any> {
    // Use updateProduct endpoint with thumbnail field
    const productData: ProductUploadReq = {
      name: '', // These fields are required but won't be updated
      price: 0,
      category_id: 0,
      description: '',
      discount: 0,
      quantity: 0,
      thumbnail: thumbnailUrl
    };
    return this.httpClient.put(`${this.apiUrl}/products/${productId}`, productData, {
      headers: this.getAuthHeaders()
    });
  }
}
