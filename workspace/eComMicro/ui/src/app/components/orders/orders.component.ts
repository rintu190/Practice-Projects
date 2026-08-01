import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-orders',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <h1>Orders</h1>

      <div *ngIf="loading" class="loading">
        <div class="spinner"></div>
        Loading orders...
      </div>

      <div *ngIf="error" class="alert alert-danger">
        {{ error }}
      </div>

      <table *ngIf="!loading && orders.length">
        <thead>
          <tr>
            <th>Order ID</th>
            <th>Status</th>
            <th>Created At</th>
            <th>Total Items</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let order of orders">
            <td>#{{ order.id }}</td>
            <td><span [ngClass]="'status-' + order.status">{{ order.status }}</span></td>
            <td>{{ order.createdAt | date: 'short' }}</td>
            <td>{{ order.items?.length || 0 }}</td>
          </tr>
        </tbody>
      </table>

      <div *ngIf="!loading && !orders.length" class="alert alert-info">
        No orders found.
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
    .status-completed {
      background-color: #d4edda;
      padding: 0.5rem;
      border-radius: 4px;
      color: #155724;
    }
    .status-pending {
      background-color: #fff3cd;
      padding: 0.5rem;
      border-radius: 4px;
      color: #856404;
    }
  `]
})
export class OrdersComponent implements OnInit {
  orders: any[] = [];
  loading = false;
  error: string | null = null;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadOrders();
  }

  loadOrders(): void {
    this.loading = true;
    this.error = null;
    this.apiService.getOrders().subscribe(
      (data) => {
        this.orders = data;
        this.loading = false;
      },
      (error) => {
        this.error = 'Failed to load orders. Make sure the API Gateway is running.';
        this.loading = false;
        console.error('Error loading orders:', error);
      }
    );
  }
}

