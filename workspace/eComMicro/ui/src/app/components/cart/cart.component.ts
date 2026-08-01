import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <h1>Shopping Cart</h1>

      <div *ngIf="(cartItems$ | async) as items">
        <div *ngIf="items.length === 0" class="alert alert-info">
          Your cart is empty. <a href="/products">Continue shopping</a>
        </div>

        <table *ngIf="items.length" class="cart-table">
          <thead>
            <tr>
              <th>Product</th>
              <th>Price</th>
              <th>Quantity</th>
              <th>Subtotal</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let item of items; let i = index">
              <td>{{ item.name }}</td>
              <td>${{ item.price }}</td>
              <td>{{ item.quantity }}</td>
              <td>${{ (item.price * item.quantity) | number: '1.2-2' }}</td>
              <td>
                <button (click)="removeFromCart(item.id)" class="danger">Remove</button>
              </td>
            </tr>
          </tbody>
        </table>

        <div *ngIf="items.length" class="cart-summary">
          <h3>Order Summary</h3>
          <p><strong>Total:</strong> ${{ getTotal() | number: '1.2-2' }}</p>
          <button class="success" style="width: 100%; padding: 1rem;">Proceed to Checkout</button>
          <button (click)="clearCart()">Clear Cart</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .container {
      padding: 2rem;
    }
    h1 {
      margin-bottom: 2rem;
      color: #2c3e50;
    }
    .cart-table {
      width: 100%;
      margin: 2rem 0;
    }
    .cart-summary {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      max-width: 400px;
      margin-left: auto;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    .cart-summary h3 {
      margin-bottom: 1rem;
    }
    .cart-summary p {
      margin: 1rem 0;
      font-size: 1.2rem;
    }
    .cart-summary button {
      width: 100%;
      margin: 0.5rem 0;
    }
  `]
})
export class CartComponent implements OnInit {
  cartItems$ = this.apiService.cartItems$;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {}

  removeFromCart(productId: number): void {
    this.apiService.removeItemFromLocalCart(productId);
  }

  clearCart(): void {
    if (confirm('Are you sure you want to clear your cart?')) {
      this.apiService.clearCart();
    }
  }

  getTotal(): number {
    return this.apiService.getCartTotal();
  }
}

