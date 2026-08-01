import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [CommonModule],
  template: `
    <footer>
      <div class="footer-content">
        <div class="footer-section">
          <h4>About Us</h4>
          <p>We are a modern eCommerce platform powered by microservices</p>
        </div>
        <div class="footer-section">
          <h4>Quick Links</h4>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/products">Products</a></li>
            <li><a href="/cart">Cart</a></li>
          </ul>
        </div>
        <div class="footer-section">
          <h4>API Information</h4>
          <p><strong>API Gateway:</strong> http://localhost:8080/api</p>
          <p><strong>Service Registry:</strong> http://localhost:8761</p>
        </div>
        <div class="footer-section">
          <h4>Support</h4>
          <p>Email: support@ecommerce.com</p>
          <p>Phone: 1-800-ECOMMERCE</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2026 eCommerce Platform. All rights reserved.</p>
      </div>
    </footer>
  `,
  styles: [`
    footer {
      background-color: #2c3e50;
      color: white;
      margin-top: 4rem;
      padding: 2rem;
    }

    .footer-content {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 2rem;
      max-width: 1200px;
      margin: 0 auto 2rem;
    }

    .footer-section h4 {
      margin-bottom: 1rem;
      color: #3498db;
    }

    .footer-section p {
      margin: 0.5rem 0;
      font-size: 0.9rem;
    }

    .footer-section ul {
      list-style: none;
      padding: 0;
    }

    .footer-section ul li {
      margin: 0.5rem 0;
    }

    .footer-section a {
      color: #ecf0f1;
      text-decoration: none;
      transition: color 0.3s;
    }

    .footer-section a:hover {
      color: #3498db;
    }

    .footer-bottom {
      text-align: center;
      padding-top: 2rem;
      border-top: 1px solid #34495e;
      font-size: 0.9rem;
    }

    @media (max-width: 768px) {
      .footer-content {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class FooterComponent {}

