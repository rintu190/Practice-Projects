# Service Discovery & API Gateway Architecture

## Overview

This eCommerce microservices project implements **Eureka Service Discovery** and **Spring Cloud Gateway** for centralized routing. The UI communicates exclusively with the API Gateway, which routes requests to the appropriate microservices.

## Architecture Components

### 1. Eureka Server (Service Registry)
- **Port**: 8761
- **Role**: Central registry where all microservices register themselves
- **Main Class**: `EurekaServerApplication`
- **URL**: http://localhost:8761

### 2. Config Server
- **Port**: 8888
- **Role**: Centralized configuration management for all services
- **Main Class**: `ConfigServerApplication`

### 3. API Gateway (Spring Cloud Gateway)
- **Port**: 8080
- **Role**: Single entry point for all UI requests
- **Main Class**: `ApiGatewayApplication`
- **Features**: 
  - Service discovery integration
  - Request routing with load balancing
  - Request/response filtering
  - Rate limiting (can be configured)

## Running the Application

### Option 1: Run All Services at Once

1. Click the run configuration dropdown in IntelliJ (top-right)
2. Select **"All Services"**
3. Click the green Run button (▶)

This will start:
- Eureka Server (first)
- Config Server
- API Gateway
- All 13 microservices

### Option 2: Run Services Individually

1. Click the run configuration dropdown
2. Select the specific service (e.g., "UserServiceApplication")
3. Click Run

**Important**: Always start Eureka Server first, then API Gateway, then other services.

## Service Startup Order (Recommended)

1. **EurekaServerApplication** - Service registry
2. **ConfigServerApplication** - Configuration server
3. **ApiGatewayApplication** - API gateway
4. All other microservices (order doesn't matter)

## Microservices Port Mapping

| Service | Port | API Path |
|---------|------|----------|
| Eureka Server | 8761 | /eureka |
| Config Server | 8888 | / |
| API Gateway | 8080 | /api/* |
| User Service | 8082 | /api/users/* |
| Product Service | 8083 | /api/products/* |
| Order Service | 8084 | /api/orders/* |
| Inventory Service | 8085 | /api/inventory/* |
| Payment Service | 8086 | /api/payments/* |
| Cart Service | 8087 | /api/cart/* |
| Review Service | 8088 | /api/reviews/* |
| Search Service | 8089 | /api/search/* |
| Shipping Service | 8090 | /api/shipping/* |
| Auth Service | 8091 | /api/auth/* |
| Notification Service | 8092 | /api/notifications/* |
| Analytics Service | 8093 | /api/analytics/* |

## API Gateway Routes

The API Gateway routes all requests to appropriate microservices using load balancing:

```yaml
/api/users/**     → user-service:8082
/api/products/**  → product-service:8083
/api/orders/**    → order-service:8084
/api/inventory/** → inventory-service:8085
/api/payments/**  → payment-service:8086
/api/cart/**      → cart-service:8087
/api/reviews/**   → review-service:8088
/api/search/**    → search-service:8089
/api/shipping/**  → shipping-service:8090
/api/auth/**      → auth-service:8091
/api/notifications/** → notification-service:8092
/api/analytics/** → analytics-service:8093
```

## How the UI Should Call the Services

### ❌ WRONG - Direct Service Calls
```javascript
// Don't do this!
fetch('http://localhost:8082/users')          // Direct to user-service
fetch('http://localhost:8083/products')       // Direct to product-service
```

### ✅ RIGHT - Through API Gateway
```javascript
// Do this instead!
fetch('http://localhost:8080/api/users')      // Through API Gateway
fetch('http://localhost:8080/api/products')   // Through API Gateway
fetch('http://localhost:8080/api/orders')     // Through API Gateway
```

## Service Discovery Features

### Benefits of Eureka Service Discovery

1. **Automatic Service Registration**: Services auto-register when they start
2. **Load Balancing**: Gateway automatically load-balances requests
3. **Health Checks**: Eureka monitors service health
4. **Failure Handling**: Automatically removes unhealthy services from routing
5. **Dynamic Scaling**: Easy to add new instances of services

### How Services Register

Each microservice includes:
```yaml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
  instance:
    preferIpAddress: true
```

## Checking Service Status

### Eureka Dashboard
Open browser: http://localhost:8761

Shows:
- All registered services
- Service instances and their status
- Last heartbeat times
- Service availability

### API Gateway Actuator
Open browser: http://localhost:8080/actuator

Shows:
- Gateway routes
- Health status
- Metrics

### Individual Service Actuator
Example: http://localhost:8082/actuator (User Service)

Shows:
- Service health
- Metrics
- Configuration properties

## Configuration Files

### Eureka Server Configuration
File: `eureka-server/src/main/resources/application.yml`

### API Gateway Configuration
File: `api-gateway/src/main/resources/application.yml`
- Defines all routes
- Discovery client settings
- Logging levels

### Individual Service Configuration
Example: `user-service/src/main/resources/application.yml`
- Application name
- Port
- Eureka registration settings
- Database configuration

## Dependencies Added

Each microservice now includes:
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    <version>4.0.3</version>
</dependency>
```

API Gateway and Config Server include:
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    <version>4.0.3</version>
</dependency>
```

## Troubleshooting

### Services not appearing in Eureka
1. Check if Eureka Server is running (port 8761)
2. Check service's application.yml has correct eureka.defaultZone
3. Wait 30 seconds for service to register (default heartbeat interval)
4. Check logs for "Registering with Eureka Server"

### API Gateway returning 503 Service Unavailable
1. Ensure the microservice is running
2. Check if service is registered in Eureka (http://localhost:8761)
3. Verify service name matches route definition (case-sensitive!)
4. Check logs in API Gateway for routing errors

### Service not responding through gateway
1. Verify the route path in api-gateway/application.yml
2. Check the service is actually running on the configured port
3. Test direct connection: http://localhost:8082/your-endpoint
4. Check API Gateway logs for "No instances available"

## Future Enhancements

- [ ] Add service-to-service communication with Feign Client
- [ ] Implement distributed tracing (Sleuth + Zipkin)
- [ ] Add circuit breaker pattern (Hystrix/Resilience4j)
- [ ] Implement API rate limiting
- [ ] Add authentication/authorization at gateway level
- [ ] Implement API versioning strategy
- [ ] Add service mesh (Istio) for advanced networking

## Useful Commands

### Build all services
```bash
mvn clean install -DskipTests
```

### Build specific service
```bash
mvn clean compile -pl user-service
```

### Run all services
```bash
./scripts/run-all.sh
```

### Run specific service
```bash
cd user-service && mvn spring-boot:run
```

## Notes

- Eureka Server should always be started first
- API Gateway needs to be running for UI to communicate with services
- Services will automatically load-balance across multiple instances if deployed
- Configuration can be centralized in Config Server for production use

