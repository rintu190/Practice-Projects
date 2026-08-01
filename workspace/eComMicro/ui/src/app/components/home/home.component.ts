import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <section class="hero">
        <h1>Welcome to eCommerce Platform</h1>
        <p>Your one-stop shop for everything you need</p>
        <a href="/products" class="btn">Shop Now</a>
      </section>

      <section class="features">
        <h2>Why Choose Us?</h2>
        <div class="grid">
          <div class="card">
            <h3>🚚 Fast Shipping</h3>
            <p>Get your orders delivered quickly and safely</p>
          </div>
          <div class="card">
            <h3>🛡️ Secure Payment</h3>
            <p>Your payment information is protected</p>
          </div>
          <div class="card">
            <h3>⭐ Quality Products</h3>
            <p>We offer only the best quality products</p>
          </div>
          <div class="card">
            <h3>💬 Customer Support</h3>
            <p>24/7 support to help you with any questions</p>
          </div>
        </div>
      </section>

      <section class="api-info">
        <h2>API Integration</h2>
        <div class="card">
          <h3>Connected to Microservices via API Gateway</h3>
          <p><strong>API Gateway URL:</strong> <code>http://localhost:8080/api</code></p>
          <p><strong>Status:</strong> <span class="status-ok">✓ Connected</span></p>
          <p>This application communicates with the following microservices:</p>
          <ul>
            <li>👤 User Service - User management</li>
            <li>📦 Product Service - Product catalog</li>
            <li>🛒 Cart Service - Shopping cart</li>
            <li>📋 Order Service - Order processing</li>
            <li>💳 Payment Service - Payment processing</li>
            <li>⭐ Review Service - Product reviews</li>
            <li>📊 Analytics Service - Sales analytics</li>
            <li>+ More services...</li>
          </ul>
        </div>
      </section>
    </div>
  `,
  styles: [`
    .container {
      padding: 2rem;
    }
    .hero {
      text-align: center;
      padding: 3rem 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 8px;
      margin-bottom: 3rem;
    }
    .hero h1 {
      font-size: 2.5rem;
      margin-bottom: 1rem;
    }
    .hero p {
      font-size: 1.2rem;
      margin-bottom: 2rem;
    }
    .features h2,
    .api-info h2 {
      text-align: center;
      margin: 2rem 0;
      color: #2c3e50;
    }
    .status-ok {
      color: #27ae60;
      font-weight: bold;
    }
    code {
      background-color: #f5f5f5;
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
      font-family: monospace;
    }
    ul {
      margin-left: 2rem;
      margin-top: 1rem;
    }
    ul li {
      margin: 0.5rem 0;
    }
  `]
})
export class HomeComponent {}

