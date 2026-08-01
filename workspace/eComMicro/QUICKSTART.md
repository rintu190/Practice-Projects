# Quick Start Guide: Service Discovery & API Gateway

## 🚀 Get Started in 3 Steps

### Step 1: Start All Services
1. Open IntelliJ
2. Click run configuration dropdown (top-right)
3. Select **"All Services"**
4. Click Green Run button (▶️)

**Wait 30-60 seconds** for all services to start up.

### Step 2: Verify Everything is Running

#### Check Eureka Dashboard:
Open browser: **http://localhost:8761**

You should see all services listed with status UP ✅

#### Check API Gateway:
Open browser: **http://localhost:8080/actuator**

Should return a JSON response with actuator endpoints.

### Step 3: Test an API Call

#### From Terminal (curl):
```bash
# Get all users through API Gateway
curl http://localhost:8080/api/users

# Get all products through API Gateway  
curl http://localhost:8080/api/products

# Get all orders through API Gateway
curl http://localhost:8080/api/orders
```

#### From Browser:
```
http://localhost:8080/api/products
http://localhost:8080/api/users
http://localhost:8080/api/orders
```

#### From JavaScript/React:
```javascript
// All requests go through the API Gateway!
fetch('http://localhost:8080/api/users')
  .then(response => response.json())
  .then(data => console.log(data))
```

## 📋 Available Endpoints

All API calls should go to **http://localhost:8080/api/***

| Resource | Endpoint |
|----------|----------|
| **Users** | `http://localhost:8080/api/users` |
| **Products** | `http://localhost:8080/api/products` |
| **Orders** | `http://localhost:8080/api/orders` |
| **Inventory** | `http://localhost:8080/api/inventory` |
| **Payments** | `http://localhost:8080/api/payments` |
| **Cart** | `http://localhost:8080/api/cart` |
| **Reviews** | `http://localhost:8080/api/reviews` |
| **Search** | `http://localhost:8080/api/search` |
| **Shipping** | `http://localhost:8080/api/shipping` |
| **Auth** | `http://localhost:8080/api/auth` |
| **Notifications** | `http://localhost:8080/api/notifications` |
| **Analytics** | `http://localhost:8080/api/analytics` |

## 🔍 Monitoring & Debugging

### View All Running Services
```
http://localhost:8761
```
Eureka Dashboard shows:
- Service name
- Instance status (UP/DOWN)
- Last heartbeat
- Number of instances

### View API Gateway Routes
```
http://localhost:8080/actuator/gateway/routes
```
Shows all configured routes and their targets.

### View Individual Service Health
```
http://localhost:8082/actuator/health     # User Service
http://localhost:8083/actuator/health     # Product Service
http://localhost:8084/actuator/health     # Order Service
```

## ⚠️ Troubleshooting

### Services not showing in Eureka?
- ✅ Check Eureka Server is running (port 8761)
- ✅ Wait 30 seconds for services to register
- ✅ Check service logs for errors

### Getting "Service Unavailable" from API Gateway?
- ✅ Verify service is running (check Eureka dashboard)
- ✅ Check correct API path is being used
- ✅ Verify service is actually running (check individual port)

### Can't connect to API Gateway?
- ✅ Ensure API Gateway is running (port 8080)
- ✅ Check http://localhost:8080/actuator responds
- ✅ Check gateway logs for errors

## 🛑 Stopping Services

In IntelliJ: Click the **Stop** button (⏹️) to stop all services.

Services will gracefully shut down and deregister from Eureka.

## 📊 Service Ports Reference

| Service | Port |
|---------|------|
| API Gateway (UI Entry Point) | **8080** ⭐ |
| Eureka Server | 8761 |
| Config Server | 8888 |
| User Service | 8082 |
| Product Service | 8083 |
| Order Service | 8084 |
| Inventory Service | 8085 |
| Payment Service | 8086 |
| Cart Service | 8087 |
| Review Service | 8088 |
| Search Service | 8089 |
| Shipping Service | 8090 |
| Auth Service | 8091 |
| Notification Service | 8092 |
| Analytics Service | 8093 |

## ✅ Key Points

1. **UI uses ONLY port 8080** (API Gateway)
2. **All requests routed automatically** to correct service
3. **Services auto-discovered** via Eureka
4. **Load balancing built-in**
5. **Can scale services** without UI changes

## 📚 Documentation

- Full architecture: `SERVICE_DISCOVERY.md`
- Implementation details: `IMPLEMENTATION_SUMMARY.md`
- Frontend integration: `frontend-api-client.js`

## 🎯 Example Requests

### Get all products
```bash
curl -X GET http://localhost:8080/api/products
```

### Create a new user
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'
```

### Create an order
```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"items":[{"productId":5,"quantity":2}]}'
```

### Check order status
```bash
curl -X GET http://localhost:8080/api/orders/123
```

## 🔐 For Frontend Developers

Use the provided `frontend-api-client.js` as a base for your API integration:

```javascript
// Import the API client
import { apiClient, API_ENDPOINTS } from './frontend-api-client.js';

// Get all products
const products = await apiClient.get(API_ENDPOINTS.products.getAll);

// Create order
const order = await apiClient.post(API_ENDPOINTS.orders.create, {
  userId: 1,
  items: [...]
});

// Login
await apiClient.post(API_ENDPOINTS.auth.login, {
  email: 'user@example.com',
  password: 'password123'
});
```

---

**That's it!** 🎉 Your microservices are now running with complete service discovery and API gateway routing.

For more details, see `SERVICE_DISCOVERY.md`

