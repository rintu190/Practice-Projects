import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-products',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="container">
      <h1>Products</h1>

      <div *ngIf="loading" class="loading">
        <div class="spinner"></div>
        Loading products...
      </div>

      <div *ngIf="error" class="alert alert-danger">
        {{ error }}
      </div>

      <div class="grid" *ngIf="!loading && products.length">
        <div class="card" *ngFor="let product of products">
          <h2>{{ product.name }}</h2>
          <p>{{ product.description }}</p>
          <p><strong>Price:</strong> ${{ product.price }}</p>
          <p *ngIf="product.stock"><strong>Stock:</strong> {{ product.stock }}</p>
          <button (click)="addToCart(product)" class="success">Add to Cart</button>
        </div>
      </div>

      <div *ngIf="!loading && !products.length" class="alert alert-info">
        No products found.
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
  `]
})
export class ProductsComponent implements OnInit {
  products: any[] = [];
  loading = false;
  error: string | null = null;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadProducts();
  }

  loadProducts(): void {
    this.loading = true;
    this.error = null;
    this.apiService.getProducts().subscribe(
      (data) => {
        this.products = data;
        this.loading = false;
      },
      (error) => {
        this.error = 'Failed to load products. Make sure the API Gateway is running on http://localhost:8080';
        this.loading = false;
        console.error('Error loading products:', error);
      }
    );
  }

  addToCart(product: any): void {
    this.apiService.addItemToLocalCart(product, 1);
    alert(`${product.name} added to cart!`);
  }
}

