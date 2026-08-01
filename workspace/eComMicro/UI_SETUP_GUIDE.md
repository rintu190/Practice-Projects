# Angular UI Setup & Running Guide

## Quick Start (3 Steps)

### Step 1: Install Dependencies
```bash
cd ui
npm install
```

### Step 2: Start the Backend Services
In the root project directory, use IntelliJ run configuration:
```
Run Configuration: "All Services" → Click Run
```

This starts:
- ✅ Eureka Server (8761)
- ✅ Config Server (8888)
- ✅ API Gateway (8080)
- ✅ All 13 microservices

**Wait 30-60 seconds for services to fully start**

### Step 3: Start the Angular UI
```bash
cd ui
npm start
```

Application will automatically open at: **http://localhost:4200**

## Full Project Structure

```
eComMicro/
├── infrastructure/
│   ├── eureka-server/       (Port 8761) - Service Registry
│   ├── config-server/       (Port 8888) - Configuration
│   └── api-gateway/         (Port 8080) - API Gateway ← UI talks to this
│
├── microservices/           (Ports 8082-8093)
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   ├── ... (9 more services)
│
└── ui/                      (Port 4200) ← You are here
    ├── src/
    │   ├── app/
    │   │   ├── components/
    │   │   ├── services/
    │   │   └── ...
    └── package.json
```

## Architecture

```
┌─────────────────────────────────────┐
│  Angular UI - Port 4200             │
│  http://localhost:4200              │
└────────────────┬────────────────────┘
                 │
          HTTP Requests (JSON)
                 │
    ┌────────────▼──────────────┐
    │  API Gateway - Port 8080  │
    │  http://localhost:8080/api│
    └────────────┬──────────────┘
                 │
   ┌─────────────┼─────────────┬──────────────┐
   │             │             │              │
┌──▼──┐    ┌────▼──┐    ┌────▼──┐    ┌────▼──┐
│User │    │Product│    │ Order │    │ Cart  │
│Svc  │    │ Svc   │    │ Svc   │    │ Svc   │
└─────┘    └───────┘    └───────┘    └───────┘
(+ All 13 microservices available)
```

## What the UI Does

### 🏠 Home Page
- Welcome message
- Feature showcase
- API integration status
- Links to shopping sections

### 🛍️ Products Page
- Fetches from Product Service via API Gateway
- Displays product listing
- Shows prices and descriptions
- Add to cart functionality

### 🛒 Shopping Cart
- Local storage for cart items
- Add/remove items
- Calculate totals
- Persist data in browser

### 📦 Orders Page
- Fetches from Order Service via API Gateway
- Shows order history
- Displays order status
- Order creation dates

### 🎯 Navigation
- Header with navigation links
- Real-time cart item count
- Active page highlighting
- Responsive footer

## API Communication Flow

### When you click "Add to Cart" on Products page:
```
1. Angular UI → Click button
2. UI calls → apiService.addItemToCart(product, 1)
3. Service sends → POST to http://localhost:8080/api/cart/items
4. API Gateway → Routes to cart-service:8087
5. Cart Service → Processes request
6. Response → Back through gateway to UI
7. UI → Updates cart display
```

### When you view Products:
```
1. Angular UI → Visits /products page
2. Component loads → ApiService.getProducts()
3. Service sends → GET to http://localhost:8080/api/products
4. API Gateway → Discovers product-service via Eureka
5. API Gateway → Forwards to product-service:8083
6. Product Service → Queries database
7. Response → JSON list of products
8. UI → Renders product cards
```

## Environment Configuration

### Development (Default)
File: `ui/src/environments/environment.ts`
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api'
};
```

### Production
File: `ui/src/environments/environment.prod.ts`
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.yourdomain.com/api'
};
```

To build for production:
```bash
npm run build
```

## Available Services

The UI can communicate with these microservices through the API Gateway:

| Service | Port | API Path | Status |
|---------|------|----------|--------|
| User Service | 8082 | `/api/users` | ✅ |
| Product Service | 8083 | `/api/products` | ✅ |
| Order Service | 8084 | `/api/orders` | ✅ |
| Inventory Service | 8085 | `/api/inventory` | ✅ |
| Payment Service | 8086 | `/api/payments` | ✅ |
| Cart Service | 8087 | `/api/cart` | ✅ |
| Review Service | 8088 | `/api/reviews` | ✅ |
| Search Service | 8089 | `/api/search` | ✅ |
| Shipping Service | 8090 | `/api/shipping` | ✅ |
| Auth Service | 8091 | `/api/auth` | ✅ |
| Notification Service | 8092 | `/api/notifications` | ✅ |
| Analytics Service | 8093 | `/api/analytics` | ✅ |

## Development Commands

```bash
# Install dependencies
npm install

# Start development server (http://localhost:4200)
npm start

# Build for production
npm run build

# Build in watch mode
npm run watch

# Run tests
npm test

# Run linter
npm run lint
```

## Troubleshooting

### "Failed to load products" Error
**Issue**: Can't connect to services
**Solution**:
1. ✅ Check Eureka Server is running: http://localhost:8761
2. ✅ Check API Gateway is running: http://localhost:8080/actuator
3. ✅ Check Product Service is running on port 8083
4. ✅ Open browser DevTools (F12) → Network tab to see actual error
5. ✅ Check services are registered in Eureka

### Port 4200 Already in Use
**Solution**:
```bash
ng serve --port 4300
# Access at: http://localhost:4300
```

### Module Not Found Errors
**Solution**:
```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install
```

### Browser Cache Issues
**Solution**:
- Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
- Open DevTools: F12
- Right-click refresh button → Empty cache and hard refresh

## Browser Support

- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)

## API Usage Examples

### In your components:

```typescript
import { ApiService } from '../../services/api.service';

export class MyComponent {
  constructor(private apiService: ApiService) {}

  // Get all products
  loadProducts() {
    this.apiService.getProducts().subscribe(
      (data) => {
        console.log('Products:', data);
      },
      (error) => {
        console.error('Error:', error);
      }
    );
  }

  // Search products
  searchProducts(query: string) {
    this.apiService.searchProducts(query).subscribe(
      (results) => console.log('Search results:', results)
    );
  }

  // Create order
  createOrder() {
    const order = {
      userId: 1,
      items: [
        { productId: 5, quantity: 2 }
      ]
    };
    this.apiService.createOrder(order).subscribe(
      (response) => console.log('Order created:', response)
    );
  }
}
```

## File Structure

```
ui/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── header/           # Navigation header
│   │   │   ├── footer/           # Footer with links
│   │   │   ├── home/             # Home/landing page
│   │   │   ├── products/         # Product listing
│   │   │   ├── orders/           # Orders page
│   │   │   └── cart/             # Shopping cart
│   │   ├── services/
│   │   │   └── api.service.ts    # API integration
│   │   ├── app.component.ts      # Root component
│   │   └── app.routes.ts         # Route definitions
│   ├── environments/
│   │   ├── environment.ts        # Dev config
│   │   └── environment.prod.ts   # Prod config
│   ├── styles.scss               # Global styles
│   ├── main.ts                   # Entry point
│   └── index.html                # HTML template
├── angular.json                  # Angular config
├── tsconfig.json                 # TypeScript config
├── package.json                  # Dependencies
└── README.md                      # Full documentation
```

## Performance Tips

1. **Lazy Load Routes**: Components load only when accessed
2. **OnPush Detection**: Use ChangeDetectionStrategy.OnPush for performance
3. **Unsubscribe**: Always unsubscribe from observables
4. **Async Pipe**: Use `| async` in templates to auto-unsubscribe

## Next Steps

1. ✅ Install dependencies: `npm install`
2. ✅ Start backend services: Run "All Services" configuration
3. ✅ Start UI: `npm start`
4. ✅ Open browser: http://localhost:4200
5. ✅ Navigate through pages
6. ✅ Check browser console (F12) for any errors
7. ✅ Monitor API calls in Network tab

## Support Resources

- [Angular Documentation](https://angular.io/docs)
- [RxJS Documentation](https://rxjs.dev/)
- [Angular HTTP Client](https://angular.io/guide/http)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

**Ready to start?** 🚀

```bash
cd ui
npm install
npm start
```

Access your UI at: **http://localhost:4200**

