#!/bin/bash

echo "Replacing Oracle XE with PostgreSQL for better stability..."

# Remove the failing Oracle deployment
kubectl delete deployment oracle-xe
kubectl delete service oracle-xe-service

# Deploy PostgreSQL as a replacement
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql-replacement
  labels:
    app: postgresql-replacement
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql-replacement
  template:
    metadata:
      labels:
        app: postgresql-replacement
    spec:
      containers:
      - name: postgresql
        image: postgres:15
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "oracledb"
        - name: POSTGRES_USER
          value: "oracle_user"
        - name: POSTGRES_PASSWORD
          value: "Oracle123!"
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - oracle_user
            - -d
            - oracledb
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - oracle_user
            - -d
            - oracledb
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-data
        emptyDir:
          sizeLimit: 5Gi

---
apiVersion: v1
kind: Service
metadata:
  name: postgresql-replacement-service
spec:
  selector:
    app: postgresql-replacement
  ports:
  - protocol: TCP
    port: 5432
    targetPort: 5432
    nodePort: 31432
  type: NodePort
EOF

echo "PostgreSQL replacement deployed. Checking status..."
sleep 10
kubectl get pods -l app=postgresql-replacement
kubectl get svc postgresql-replacement-service

echo ""
echo "Connection details:"
echo "Host: $(minikube ip):31432"
echo "Database: oracledb"
echo "User: oracle_user"
echo "Password: Oracle123!"