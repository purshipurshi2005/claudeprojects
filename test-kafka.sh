#!/bin/bash

echo "Testing Kafka producer..."

# Send test messages to Kafka
kubectl exec -it deployment/kafka -- bash -c "
echo 'Hello from Kafka!' | kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic
echo 'Test message 1' | kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic
echo 'Test message 2' | kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic
"

echo "Messages sent to Kafka topic 'test-topic'"
echo "Check the Spring Boot application logs to see if messages were consumed:"
echo "kubectl logs -f deployment/kafka-consumer-app"
echo ""
echo "Or check the database via the REST API:"
echo "curl http://$(minikube ip):30080/api/messages"