eComMicro - Microservices practice scaffold

This repository provides a multi-module Maven skeleton and infrastructure to practice integrating the following technologies:

Services included (skeletons):
- API Gateway (Spring Cloud Gateway)
- Config Server
- Auth Service (Keycloak in Docker Compose)
- User Service
- Product Service
- Inventory Service
- Cart Service
- Order Service
- Payment Service
- Notification Service
- Shipping Service
- Review Service
- Search Service (Elasticsearch)
- Analytics Service (Kafka consumers)

Supporting infrastructure (Docker Compose):
- PostgreSQL
- MongoDB
- Redis
- Kafka + Zookeeper
- Elasticsearch + Kibana
- Keycloak
- Prometheus + Grafana
- Jaeger

What to try
1. Start infrastructure:

```bash
# from repository root
docker compose up -d
```

2. Build the project:

```bash
mvn -T 1C -B clean package -DskipTests
```

3. Run a single service locally (example: user-service):

```bash
cd user-service
mvn spring-boot:run
```

4. Explore adding:
- Flyway migrations under each service
- Testcontainers-based integration tests
- OpenTelemetry auto-instrumentation (JAVA_TOOL_OPTIONS) and Jaeger
- Kibana to inspect Elasticsearch indices
- Helm charts for deployment
- GitHub Actions to build/publish images and deploy to a k8s cluster

Notes
- This scaffold aims to give you a realistic playground. Fill in service implementations, domain models, and CI/CD as you go.

