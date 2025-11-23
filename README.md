# 🚀 CI/CD Deployment to AWS EKS (Flask + GitHub Actions + ECR)

This project deploys a Python **Flask** application to **Amazon EKS** using a complete **CI/CD pipeline** powered by **GitHub Actions**.  
The pipeline automatically builds a Docker image, pushes it to **Amazon ECR**, and deploys it to **EKS** with `kubectl`.

---

## 🏗 Architecture Diagram (Mermaid)

```mermaid
flowchart LR

    subgraph DEV["GitHub Repository"]
        A[Source Code\nFlask App + Dockerfile]
    end

    A --> B["GitHub Actions\nCI/CD Pipeline"]

    B --> C["Amazon ECR\nDocker Registry"]
    B --> D["Amazon EKS\nCluster Control Plane"]

    subgraph WORKERS["EKS Worker Nodes (t3.small)"]
        direction TB
        subgraph NS["default Namespace"]
            P1[Pod 1\nFlask Container]
            P2[Pod 2\nFlask Container]
        end
    end

    D --> WORKERS
    WORKERS --> LB["AWS LoadBalancer\n(Service: LoadBalancer)"]
    LB --> USER["End User\n(Web Browser)"]
🛠 Tech Stack
Component	Technology
Language	Python + Flask
Container	Docker
Registry	Amazon ECR
Orchestration	Amazon EKS (Kubernetes)
CI/CD	GitHub Actions
Networking	LoadBalancer (AWS ELB)
IAM	AWS IAM User (github-eks-ci)

📂 Project Structure
markdown
Copy code
eks-flask-demo/
├── app/
│   ├── app.py
│   └── requirements.txt
├── Dockerfile
├── Kubernetes/
│   ├── deployment.yaml
│   └── service.yaml
└── .github/
    └── workflows/
        └── build-and-push.yml
└── README.md

💻 **Flask Application**
python
Copy code
from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    hostname = socket.gethostname()
    return f"Hello from EKS! Served by pod: {hostname}\n"

@app.route("/health")
def health():
    return "OK\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

🐳** Dockerfile**
dockerfile
Copy code
FROM python:3.11-slim
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
EXPOSE 5000
CMD ["python", "app.py"]

☸ **Kubernetes Deployment.yaml
**
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
        - name: flask-app
          image: <YOUR_ECR_IMAGE_URI>
          imagePullPolicy: Always
          ports:
            - containerPort: 5000

🌐 **Kubernetes Service.yaml**
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  type: LoadBalancer
  selector:
    app: flask-app
  ports:
    - port: 80
      targetPort: 5000

⚙ **GitHub Actions Workflow.yaml**

name: Build, Push, and Deploy

on:
  push:
    branches: [ "main" ]
  workflow_dispatch: {}

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    env:
      AWS_REGION: ${{ secrets.AWS_REGION }}
      ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}

    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build, tag, and push image to Amazon ECR
        env:
          REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $REGISTRY/$ECR_REPOSITORY:latest
          docker push $REGISTRY/$ECR_REPOSITORY:latest

  deploy:
    runs-on: ubuntu-latest
    needs: build-and-push

    env:
      AWS_REGION: ${{ secrets.AWS_REGION }}
      CLUSTER_NAME: "eks-flask-demo"

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Update kubeconfig for EKS cluster
        run: |
          aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

      - name: Apply Kubernetes manifests
        run: |
          kubectl apply -f Kubernetes/deployment.yaml
          kubectl apply -f Kubernetes/service.yaml

🔐 **Secrets Needed in GitHub**
Secret Name	Value
AWS_ACCESS_KEY_ID	IAM Access Key
AWS_SECRET_ACCESS_KEY	IAM Secret
AWS_REGION	ap-south-1
ECR_REPOSITORY	eks-flask-demo

👤 Author
Developed by: Rasika Deshmukh
