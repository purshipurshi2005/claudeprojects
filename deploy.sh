#!/bin/bash

echo "Starting deployment to Minikube..."

# Start Minikube if not running
echo "Checking Minikube status..."
minikube status || minikube start

# Build the Spring Boot application
echo "Building Spring Boot application..."
mvn clean package -DskipTests

# Build Docker image in Minikube's Docker environment
echo "Building Docker image..."
eval $(minikube docker-env)
docker build -t kafka-consumer-app:latest .

# Deploy PostgreSQL
echo "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres.yaml

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres

# Deploy Kafka and Zookeeper
echo "Deploying Kafka and Zookeeper..."
kubectl apply -f k8s/kafka.yaml

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka
kubectl wait --for=condition=available --timeout=300s deployment/zookeeper

# Deploy Spring Boot application
echo "Deploying Spring Boot application..."
kubectl apply -f k8s/spring-boot-app.yaml

# Wait for Spring Boot app to be ready
echo "Waiting for Spring Boot application to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka-consumer-app

echo "Deployment completed!"
echo ""
echo "To access the application:"
echo "1. Get Minikube IP: minikube ip"
echo "2. Access the app at: http://$(minikube ip):30080/api/messages/health"
echo ""
echo "To view logs:"
echo "kubectl logs -f deployment/kafka-consumer-app"
echo ""
echo "To test Kafka producer:"
echo "kubectl exec -it deployment/kafka -- kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic"