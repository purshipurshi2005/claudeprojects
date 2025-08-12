#!/bin/bash

echo "=== Spring Boot Kafka Consumer Service Access ==="
echo ""

# Kill any existing port forwards
pkill -f "kubectl port-forward"

echo "1. Starting port forward to access the service..."
kubectl port-forward service/kafka-consumer-app-service 8080:8080 &
PORT_FORWARD_PID=$!

# Wait for port forward to be ready
sleep 3

echo "2. Testing service health..."
curl -s http://localhost:8080/api/messages/health
echo ""

echo "3. Fetching all Kafka messages from database..."
echo "Messages consumed from Kafka:"
curl -s http://localhost:8080/api/messages | jq '.'

echo ""
echo "=== Service Access Information ==="
echo "Local URL: http://localhost:8080"
echo "Health Check: http://localhost:8080/api/messages/health"
echo "All Messages: http://localhost:8080/api/messages"
echo "Messages by Topic: http://localhost:8080/api/messages/topic/test-topic"
echo ""
echo "To stop port forwarding: kill $PORT_FORWARD_PID"
echo "Or run: pkill -f 'kubectl port-forward'"