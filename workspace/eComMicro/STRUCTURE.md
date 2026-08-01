# Project Structure

## 📁 Directory Organization

```
eComMicro/
├── common/                          # Shared utilities and libraries
│
├── infrastructure/                  # Core infrastructure services
│   ├── pom.xml                     # Infrastructure modules parent
│   ├── eureka-server/              # Service Registry (Port 8761)
│   ├── config-server/              # Configuration Server (Port 8888)
│   └── api-gateway/                # API Gateway (Port 8080)
│
├── microservices/                   # Business logic microservices
│   ├── pom.xml                     # Microservices modules parent
│   ├── auth-service/               # Authentication (Port 8091)
│   ├── user-service/               # User Management (Port 8082)
│   ├── product-service/            # Product Catalog (Port 8083)
│   ├── order-service/              # Order Processing (Port 8084)
│   ├── inventory-service/          # Stock Management (Port 8085)
│   ├── payment-service/            # Payment Processing (Port 8086)
│   ├── cart-service/               # Shopping Cart (Port 8087)
│   ├── review-service/             # Product Reviews (Port 8088)
│   ├── search-service/             # Product Search (Port 8089)
│   ├── shipping-service/           # Shipping Management (Port 8090)
│   ├── notification-service/       # Notifications (Port 8092)
│   └── analytics-service/          # Analytics (Port 8093)
│
├── scripts/                         # Helper scripts
├── dockerfiles/                     # Docker configurations
├── helm/                            # Kubernetes Helm charts
├── infrastructure/                  # Prometheus & monitoring
├── pom.xml                         # Root parent POM
├── docker-compose.yml              # Docker compose configuration
├── QUICKSTART.md                   # Quick start guide
├── SERVICE_DISCOVERY.md            # Architecture documentation
├── IMPLEMENTATION_SUMMARY.md       # Technical details
├── frontend-api-client.js          # Frontend API integration
└── README.md                        # Main documentation
```

## 🎯 Project Organization Rationale

### Infrastructure (`/infrastructure`)
Contains the backbone services required for the microservices architecture:
- **Eureka Server**: Service registry and discovery
- **Config Server**: Centralized configuration management
- **API Gateway**: Single entry point for all requests

### Microservices (`/microservices`)
Contains all business logic microservices organized by domain:
- Each service is independently deployable
- Each service has its own database (database per service pattern)
- Services communicate through the API Gateway

### Common (`/common`)
Shared code, utilities, and dependencies used across services.

## 🔨 Building the Project

### Build Everything
```bash
mvn clean install -DskipTests
```

### Build Infrastructure Services Only
```bash
mvn clean install -DskipTests -pl infrastructure/eureka-server,infrastructure/config-server,infrastructure/api-gateway
```

### Build Specific Microservice
```bash
mvn clean compile -pl microservices/user-service
```

### Build All Microservices
```bash
mvn clean install -DskipTests -pl microservices/*
```

## 🚀 Running Services

### Run All Services
1. Click run configuration dropdown in IntelliJ
2. Select **"All Services"**
3. Click Run

### Run Infrastructure Only
```bash
# Terminal 1: Eureka Server
mvn spring-boot:run -pl infrastructure/eureka-server

# Terminal 2: Config Server
mvn spring-boot:run -pl infrastructure/config-server

# Terminal 3: API Gateway
mvn spring-boot:run -pl infrastructure/api-gateway
```

### Run Specific Microservice
```bash
mvn spring-boot:run -pl microservices/user-service
```

## 📊 Service Ports

| Service | Port | Module Path |
|---------|------|-------------|
| API Gateway | 8080 | `infrastructure/api-gateway` |
| Eureka Server | 8761 | `infrastructure/eureka-server` |
| Config Server | 8888 | `infrastructure/config-server` |
| User Service | 8082 | `microservices/user-service` |
| Product Service | 8083 | `microservices/product-service` |
| Order Service | 8084 | `microservices/order-service` |
| Inventory Service | 8085 | `microservices/inventory-service` |
| Payment Service | 8086 | `microservices/payment-service` |
| Cart Service | 8087 | `microservices/cart-service` |
| Review Service | 8088 | `microservices/review-service` |
| Search Service | 8089 | `microservices/search-service` |
| Shipping Service | 8090 | `microservices/shipping-service` |
| Auth Service | 8091 | `microservices/auth-service` |
| Notification Service | 8092 | `microservices/notification-service` |
| Analytics Service | 8093 | `microservices/analytics-service` |

## 🔧 Development Workflow

### Adding a New Microservice
1. Create a new directory under `microservices/my-service/`
2. Create standard Maven structure:
   ```
   my-service/
   ├── pom.xml
   ├── src/
   │   ├── main/
   │   │   ├── java/org/example/myservice/
   │   │   └── resources/
   │   └── test/
   ```
3. Update `microservices/pom.xml` to include the new module
4. Update root `pom.xml` module list

### Adding a New Infrastructure Service
Same process but create under `infrastructure/` instead.

## 📚 Documentation Files

- **QUICKSTART.md**: Fast setup guide (start here!)
- **SERVICE_DISCOVERY.md**: Complete architecture documentation
- **IMPLEMENTATION_SUMMARY.md**: Technical implementation details
- **STRUCTURE.md**: This file - project organization
- **frontend-api-client.js**: Frontend integration examples

## 🎯 Key Points

- All UI requests go through **Port 8080** (API Gateway)
- Eureka Server (**Port 8761**) maintains service registry
- Each service has unique port for local testing
- Services auto-register with Eureka on startup
- API Gateway handles routing and load balancing
- Services are organized by business domain

## 🔄 Maven Module References

When using Maven commands, reference modules with their new paths:

```bash
# ✅ Correct - with path
mvn clean compile -pl infrastructure/eureka-server
mvn clean compile -pl microservices/user-service

# ✅ Also correct - by artifact ID
mvn clean compile -pl eureka-server
mvn clean compile -pl user-service

# ✅ Build multiple services
mvn clean compile -pl infrastructure/eureka-server,microservices/user-service,microservices/product-service
```

## 🐳 Docker & Kubernetes

- **dockerfiles/**: Contains Dockerfile for services
- **docker-compose.yml**: Local development setup
- **helm/**: Kubernetes Helm charts for production deployment

See respective folders for deployment configurations.

