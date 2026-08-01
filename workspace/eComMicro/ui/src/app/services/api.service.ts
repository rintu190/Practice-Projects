import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  stock?: number;
}

export interface User {
  id: number;
  name: string;
  email: string;
}

export interface Order {
  id: number;
  userId: number;
  items: any[];
  status: string;
  createdAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  // Observable for cart items
  private cartItems = new BehaviorSubject<any[]>([]);
  public cartItems$ = this.cartItems.asObservable();

  constructor(private http: HttpClient) {
    this.loadCart();
  }

  // ==================== PRODUCTS ====================
  getProducts(): Observable<Product[]> {
    return this.http.get<Product[]>(`${this.apiUrl}/products`);
  }

  getProduct(id: number): Observable<Product> {
    return this.http.get<Product>(`${this.apiUrl}/products/${id}`);
  }

  searchProducts(query: string): Observable<Product[]> {
    return this.http.get<Product[]>(`${this.apiUrl}/search/products?q=${query}`);
  }

  // ==================== USERS ====================
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}/users`);
  }

  getUser(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/users/${id}`);
  }

  createUser(user: User): Observable<User> {
    return this.http.post<User>(`${this.apiUrl}/users`, user);
  }

  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/users/${id}`, user);
  }

  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/users/${id}`);
  }

  // ==================== ORDERS ====================
  getOrders(): Observable<Order[]> {
    return this.http.get<Order[]>(`${this.apiUrl}/orders`);
  }

  getOrder(id: number): Observable<Order> {
    return this.http.get<Order>(`${this.apiUrl}/orders/${id}`);
  }

  createOrder(order: Order): Observable<Order> {
    return this.http.post<Order>(`${this.apiUrl}/orders`, order);
  }

  updateOrderStatus(id: number, status: string): Observable<Order> {
    return this.http.put<Order>(`${this.apiUrl}/orders/${id}/status/${status}`, {});
  }

  // ==================== CART ====================
  getCart(): Observable<any> {
    return this.http.get(`${this.apiUrl}/cart`);
  }

  addToCart(productId: number, quantity: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/cart/items`, { productId, quantity });
  }

  removeFromCart(itemId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/cart/items/${itemId}`);
  }

  // Local cart management
  private loadCart(): void {
    const cart = localStorage.getItem('cart');
    if (cart) {
      this.cartItems.next(JSON.parse(cart));
    }
  }

  addItemToLocalCart(product: Product, quantity: number): void {
    const currentCart = this.cartItems.value;
    const existingItem = currentCart.find((item: any) => item.id === product.id);

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      currentCart.push({ ...product, quantity });
    }

    this.cartItems.next([...currentCart]);
    localStorage.setItem('cart', JSON.stringify(currentCart));
  }

  removeItemFromLocalCart(productId: number): void {
    const currentCart = this.cartItems.value.filter((item: any) => item.id !== productId);
    this.cartItems.next(currentCart);
    localStorage.setItem('cart', JSON.stringify(currentCart));
  }

  clearCart(): void {
    this.cartItems.next([]);
    localStorage.removeItem('cart');
  }

  getCartTotal(): number {
    return this.cartItems.value.reduce((total: number, item: any) => total + (item.price * item.quantity), 0);
  }

  // ==================== PAYMENTS ====================
  processPayment(paymentData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/payments`, paymentData);
  }

  // ==================== REVIEWS ====================
  getProductReviews(productId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/reviews?productId=${productId}`);
  }

  createReview(review: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/reviews`, review);
  }

  // ==================== NOTIFICATIONS ====================
  getNotifications(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/notifications`);
  }

  // ==================== ANALYTICS ====================
  getSalesStats(): Observable<any> {
    return this.http.get(`${this.apiUrl}/analytics/sales`);
  }

  getUserStats(): Observable<any> {
    return this.http.get(`${this.apiUrl}/analytics/users`);
  }
}

