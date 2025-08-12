# Kafka Consumer Spring Boot Application

This project demonstrates a Spring Boot application that consumes messages from Kafka and stores them in PostgreSQL, all running in a Minikube cluster.

## Architecture

- **Spring Boot Application**: Kafka consumer with REST API
- **PostgreSQL**: Database for storing consumed messages
- **Apache Kafka**: Message broker
- **Zookeeper**: Kafka coordination service
- **Minikube**: Local Kubernetes cluster

## Prerequisites

- Java 17+
- Maven 3.6+
- Docker
- Minikube
- kubectl

## Quick Start

1. **Make scripts executable:**
   ```bash
   chmod +x deploy.sh test-kafka.sh
   ```

2. **Deploy the entire stack:**
   ```bash
   ./deploy.sh
   ```

3. **Test Kafka messaging:**
   ```bash
   ./test-kafka.sh
   ```

## Manual Deployment Steps

If you prefer to deploy manually:

1. **Start Minikube:**
   ```bash
   minikube start
   ```

2. **Build the application:**
   ```bash
   mvn clean package -DskipTests
   ```

3. **Build Docker image:**
   ```bash
   eval $(minikube docker-env)
   docker build -t kafka-consumer-app:latest .
   ```

4. **Deploy PostgreSQL:**
   ```bash
   kubectl apply -f k8s/postgres.yaml
   ```

5. **Deploy Kafka and Zookeeper:**
   ```bash
   kubectl apply -f k8s/kafka.yaml
   ```

6. **Deploy Spring Boot application:**
   ```bash
   kubectl apply -f k8s/spring-boot-app.yaml
   ```

## Testing

### Health Check
```bash
curl http://$(minikube ip):30080/api/messages/health
```

### View All Messages
```bash
curl http://$(minikube ip):30080/api/messages
```

### View Messages by Topic
```bash
curl http://$(minikube ip):30080/api/messages/topic/test-topic
```

### Send Test Messages
```bash
kubectl exec -it deployment/kafka -- kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic
```

## Monitoring

### Application Logs
```bash
kubectl logs -f deployment/kafka-consumer-app
```

### Kafka Logs
```bash
kubectl logs -f deployment/kafka
```

### PostgreSQL Logs
```bash
kubectl logs -f deployment/postgres
```

### Check Pod Status
```bash
kubectl get pods
```

### Check Services
```bash
kubectl get services
```

## Configuration

The application is configured via `src/main/resources/application.yml`:

- **Kafka Bootstrap Servers**: `kafka-service:9092`
- **PostgreSQL URL**: `jdbc:postgresql://postgres-service:5432/kafkadb`
- **Consumer Group**: `consumer-group-1`
- **Topic**: `test-topic`

## Cleanup

To remove all deployed resources:
```bash
kubectl delete -f k8s/
```

To stop Minikube:
```bash
minikube stop
```

## Troubleshooting

1. **Pods not starting**: Check resource constraints and increase Minikube memory if needed:
   ```bash
   minikube start --memory=4096 --cpus=2
   ```

2. **Can't connect to services**: Ensure all pods are running:
   ```bash
   kubectl get pods
   ```

3. **Database connection issues**: Check PostgreSQL pod logs and ensure the service is accessible.

4. **Kafka connection issues**: Verify Kafka and Zookeeper are running and accessible.