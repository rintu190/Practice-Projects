# Angular UI for eCommerce Microservices

This is an Angular 17 application that communicates with the eCommerce microservices via the API Gateway.

## Features

- 🛍️ Product browsing and management
- 🛒 Shopping cart functionality
- 📦 Order tracking
- ⭐ Product reviews
- 👤 User management
- 📊 Integration with all microservices

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Angular CLI (installed via npm)

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Ensure the API Gateway is running:**
   The app expects the API Gateway to be running on `http://localhost:8080/api`
   
   Start it from the root project:
   ```bash
   # In the root eComMicro folder
   Run Configuration: "All Services" → Click Run
   ```

## Development Server

Run the development server:

```bash
npm start
```

Navigate to `http://localhost:4200/`. The application will automatically reload when you modify any source files.

## Build for Production

```bash
npm run build
```

The build artifacts will be stored in the `dist/` directory.

## Project Structure

```
ui/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── header/           # Navigation header
│   │   │   ├── footer/           # Footer component
│   │   │   ├── home/             # Home page
│   │   │   ├── products/         # Products listing
│   │   │   ├── orders/           # Orders page
│   │   │   └── cart/             # Shopping cart
│   │   ├── services/
│   │   │   └── api.service.ts    # API communication service
│   │   ├── app.component.ts      # Root component
│   │   ├── app.routes.ts         # Route definitions
│   ├── environments/             # Environment configuration
│   ├── styles.scss               # Global styles
│   └── main.ts                   # Application entry point
├── angular.json                  # Angular CLI configuration
├── tsconfig.json                 # TypeScript configuration
└── package.json                  # Dependencies
```

## API Service

The `api.service.ts` provides methods to communicate with all microservices:

### Products
```typescript
apiService.getProducts()                    // Get all products
apiService.getProduct(id)                   // Get product by ID
apiService.searchProducts(query)            // Search products
```

### Users
```typescript
apiService.getUsers()                       // Get all users
apiService.getUser(id)                      // Get user by ID
apiService.createUser(user)                 // Create new user
apiService.updateUser(id, user)             // Update user
apiService.deleteUser(id)                   // Delete user
```

### Orders
```typescript
apiService.getOrders()                      // Get all orders
apiService.getOrder(id)                     // Get order by ID
apiService.createOrder(order)               // Create new order
apiService.updateOrderStatus(id, status)    // Update order status
```

### Cart
```typescript
apiService.getCart()                        // Get cart from server
apiService.addToCart(productId, quantity)   // Add item to cart
apiService.removeFromCart(itemId)           // Remove item from cart
apiService.addItemToLocalCart(product, qty) // Add to local cart
apiService.removeItemFromLocalCart(id)      // Remove from local cart
apiService.clearCart()                      // Clear cart
apiService.getCartTotal()                   // Get cart total
```

### Payments
```typescript
apiService.processPayment(paymentData)      // Process payment
```

### Reviews
```typescript
apiService.getProductReviews(productId)     // Get reviews for product
apiService.createReview(review)             // Create new review
```

### Notifications
```typescript
apiService.getNotifications()               // Get all notifications
```

### Analytics
```typescript
apiService.getSalesStats()                  // Get sales statistics
apiService.getUserStats()                   // Get user statistics
```

## API Gateway Routes

The application communicates through the API Gateway on port 8080:

| Endpoint | Microservice |
|----------|--------------|
| `/api/users` | user-service (8082) |
| `/api/products` | product-service (8083) |
| `/api/orders` | order-service (8084) |
| `/api/inventory` | inventory-service (8085) |
| `/api/payments` | payment-service (8086) |
| `/api/cart` | cart-service (8087) |
| `/api/reviews` | review-service (8088) |
| `/api/search` | search-service (8089) |
| `/api/shipping` | shipping-service (8090) |
| `/api/auth` | auth-service (8091) |
| `/api/notifications` | notification-service (8092) |
| `/api/analytics` | analytics-service (8093) |

## Environment Configuration

### Development
The app is configured to use the API Gateway at `http://localhost:8080/api` for development.

Edit `src/environments/environment.ts`:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api'
};
```

### Production
For production, update `src/environments/environment.prod.ts`:
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.yourdomain.com/api'
};
```

## Features in Detail

### Home Page
- Welcome message with quick access to shopping
- Information about the microservices architecture
- Links to different sections

### Products Page
- Displays all products from the product service
- Shows product details (name, description, price, stock)
- Add to cart functionality
- Real-time updates

### Orders Page
- View all orders
- Order status tracking
- Order creation timestamp

### Shopping Cart
- View cart items
- Update quantities
- Remove items
- Calculate totals
- Persistent storage (localStorage)

## Troubleshooting

### API Connection Issues
If you get errors like "Failed to load products":
1. Ensure Eureka Server is running (port 8761)
2. Ensure API Gateway is running (port 8080)
3. Ensure product-service is running (port 8083)
4. Check browser console for detailed errors
5. Verify CORS configuration if needed

### Styling Issues
- Clear browser cache: `Ctrl+Shift+Delete`
- Rebuild styles: `npm run build`

### Port Already in Use
If port 4200 is already in use:
```bash
ng serve --port 4300
```

## Scripts

```bash
npm start       # Start development server
npm build       # Build for production
npm run watch   # Watch mode
npm test        # Run tests
npm run lint    # Run linter
```

## Technologies

- **Angular 17**: Frontend framework
- **TypeScript 5.2**: Programming language
- **RxJS 7.8**: Reactive programming
- **Bootstrap**: Responsive grid system

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues or questions:
1. Check the project README
2. Review the API service documentation
3. Check microservices logs
4. Ensure all services are running

## Architecture Diagram

```
┌─────────────────┐
│   Angular UI    │
│  (Port 4200)    │
└────────┬────────┘
         │
    HTTP Requests
         │
    ┌────▼─────────────────┐
    │  API Gateway         │
    │  (Port 8080)         │
    └────┬──────────────────┘
         │
         ├─────────────────────┬──────────────────┬──────────────────┐
         │                     │                  │                  │
    ┌────▼────┐         ┌─────▼────┐      ┌─────▼────┐      ┌─────▼────┐
    │  User   │         │ Product  │      │  Order   │      │  Payment │
    │ Service │         │ Service  │      │ Service  │      │ Service  │
    └─────────┘         └──────────┘      └──────────┘      └──────────┘
    
    + All 13 microservices available through API Gateway
```

---

**Happy Shopping!** 🛍️

