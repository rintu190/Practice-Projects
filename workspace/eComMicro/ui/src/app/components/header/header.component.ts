import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <header>
      <nav>
        <h1>🛍️ eCommerce</h1>
        <div class="nav-links">
          <a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact: true}">Home</a>
          <a routerLink="/products" routerLinkActive="active">Products</a>
          <a routerLink="/orders" routerLinkActive="active">Orders</a>
          <a routerLink="/cart" routerLinkActive="active">
            Cart <span class="cart-badge" *ngIf="(cartItems$ | async) as items">{{ items.length }}</span>
          </a>
        </div>
      </nav>
    </header>
  `,
  styles: [`
    header {
      background-color: #2c3e50;
      color: white;
      padding: 1rem 2rem;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    nav {
      display: flex;
      justify-content: space-between;
      align-items: center;
      max-width: 1200px;
      margin: 0 auto;
    }

    h1 {
      font-size: 1.8rem;
      font-weight: 700;
      margin: 0;
    }

    .nav-links {
      display: flex;
      gap: 2rem;
    }

    a {
      color: white;
      text-decoration: none;
      transition: color 0.3s;
      position: relative;
    }

    a:hover {
      color: #3498db;
    }

    a.active {
      color: #3498db;
      font-weight: 600;
    }

    a.active::after {
      content: '';
      position: absolute;
      bottom: -5px;
      left: 0;
      right: 0;
      height: 2px;
      background-color: #3498db;
    }

    .cart-badge {
      background-color: #e74c3c;
      color: white;
      border-radius: 50%;
      padding: 0.2rem 0.5rem;
      font-size: 0.8rem;
      margin-left: 0.5rem;
    }
  `]
})
export class HeaderComponent implements OnInit {
  cartItems$ = this.apiService.cartItems$;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {}
}

