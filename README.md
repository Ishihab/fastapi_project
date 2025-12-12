# Simple Social

A full-stack social media application built with FastAPI, Streamlit, and deployed on AWS EKS using Terraform and Kubernetes.

## 🌟 Features

- **User Authentication**: Secure user registration, login, and JWT-based authentication using FastAPI Users
- **Media Uploads**: Upload images and videos with ImageKit integration for media storage
- **Social Feed**: Browse and interact with posts from all users
- **Post Management**: Create posts with captions and delete your own posts
- **Modern UI**: Clean and responsive Streamlit frontend
- **Cloud-Native**: Containerized application deployed on Kubernetes with AWS infrastructure

## 🏗️ Architecture

### Backend (FastAPI)
- **Framework**: FastAPI with async/await support
- **Database**: MySQL with SQLAlchemy ORM (async)
- **Authentication**: FastAPI Users with JWT tokens
- **Media Storage**: ImageKit for image and video hosting
- **API Features**:
  - User registration and authentication
  - File upload endpoint
  - Feed endpoint for retrieving posts
  - Post deletion with authorization checks

### Frontend (Streamlit)
- **Framework**: Streamlit for interactive web interface
- **Features**:
  - User login and registration
  - Media upload (images and videos)
  - Social feed with post display
  - Delete functionality for user's own posts

### Infrastructure
- **Container Orchestration**: Kubernetes (EKS)
- **Cloud Provider**: AWS
- **IaC**: Terraform for infrastructure provisioning
- **Database**: AWS RDS MySQL
- **Networking**: VPC with public, private, and database subnets

## 📋 Prerequisites

- Python 3.12+
- Docker
- Kubernetes cluster (or AWS EKS)
- Terraform (for infrastructure deployment)
- AWS Account (for cloud deployment)
- ImageKit account for media storage

## 🚀 Getting Started

### Clone the Repository

```bash
git clone https://github.com/Ishihab/fastapi_project.git
cd fastapi_project
```


### Local Development

#### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Set up environment variables:
```bash
export DB_URL=localhost:3306
export DB_USER=your_db_user
export DB_PASS=your_db_password
export DB_NAME=simplesocialdb
export IMAGEKIT_PUBLIC_KEY=your_imagekit_public_key
export IMAGEKIT_PRIVATE_KEY=your_imagekit_private_key
export IMAGEKIT_URL_ENDPOINT=your_imagekit_url
```

3. Install dependencies with uv:
```bash
uv sync
```

4. Run the backend:
```bash
python main.py
```

The API will be available at `http://localhost:8000`

#### Frontend Setup

1. Navigate to the web directory:
```bash
cd web
```

2. Set up environment variables:
```bash
export API_URL=localhost:8000
```

3. Install dependencies:
```bash
uv sync
```

4. Run the frontend:
```bash
streamlit run frontend.py
```

The web interface will be available at `http://localhost:8501`

### Docker Deployment

#### Build and Run Backend
```bash
cd backend
docker build -t simple-social-api .
docker run -p 8000:8000 \
  -e DB_URL=your_db_url \
  -e DB_USER=your_db_user \
  -e DB_PASS=your_db_password \
  -e DB_NAME=simplesocialdb \
  simple-social-api
```

#### Build and Run Frontend
```bash
cd web
docker build -t simple-social-web .
docker run -p 8501:8501 \
  -e API_URL=backend:8000 \
  simple-social-web
```

## ☁️ AWS Deployment

### One-Command Deployment with Terraform

Terraform handles **everything** - from AWS infrastructure to Kubernetes resources. No manual kubectl commands needed!

1. Navigate to the terraform directory:
```bash
cd terraform
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned infrastructure:
```bash
terraform plan
```

4. Deploy everything:
```bash
terraform apply
```

That's it! This single command will provision:

**AWS Infrastructure:**
- VPC with multi-AZ setup (public, private, and database subnets)
- EKS cluster
- RDS MySQL database with automated password generation
- S3 bucket for file cleanup
- Lambda function for automated cleanup
- Security groups and networking
- IAM roles and policies

**Kubernetes Resources (via Terraform):**
- Namespace (`simple-social`)
- Secrets (database credentials)
- ConfigMaps (database config, API URL)
- Deployments (API and Frontend, 2 replicas each)
- Services (ClusterIP for internal communication)
- Ingress with AWS ALB Controller
- AWS Load Balancer Controller (Helm release)

5. Get the application URL:
```bash
terraform output alb_dns_name
```

Or check the ingress:
```bash
aws eks update-kubeconfig --name simple-social-eks --region your-region
kubectl get ingress -n simple-social
```

6. Monitor deployment (optional):
```bash
kubectl get pods -n simple-social
kubectl get services -n simple-social
```

### Teardown

To destroy all resources:
```bash
terraform destroy
```

## 🔧 Configuration

### Backend Configuration

The backend uses the following environment variables:

- `DB_URL`: MySQL database host (auto-configured by Terraform in K8s)
- `DB_USER`: Database username (auto-configured by Terraform in K8s)
- `DB_PASS`: Database password (auto-generated and configured by Terraform in K8s)
- `DB_NAME`: Database name (auto-configured by Terraform in K8s)
- `IMAGEKIT_PUBLIC_KEY`: ImageKit public API key (configure in your deployment)
- `IMAGEKIT_PRIVATE_KEY`: ImageKit private API key (configure in your deployment)
- `IMAGEKIT_URL_ENDPOINT`: ImageKit URL endpoint (configure in your deployment)

### Frontend Configuration

- `API_URL`: Backend API URL (auto-configured by Terraform as `backend-service.simple-social.svc.cluster.local`)

**Note**: When deploying to AWS with Terraform, database credentials and API URLs are automatically managed via Kubernetes Secrets and ConfigMaps. You only need to configure ImageKit credentials for local development or add them to the Terraform configuration.

## 📁 Project Structure

```
simple_social/
├── backend/              # FastAPI backend application
│   ├── app/
│   │   ├── app.py       # Main FastAPI application
│   │   ├── db.py        # Database models and session management
│   │   ├── users.py     # User authentication setup
│   │   ├── images.py    # ImageKit integration
│   │   └── schemas.py   # Pydantic schemas
│   ├── Dockerfile       # Backend container definition
│   ├── main.py          # Application entry point
│   └── pyproject.toml   # Python dependencies
├── web/                 # Streamlit frontend
│   ├── frontend.py      # Main Streamlit application
│   ├── Dockerfile       # Frontend container definition
│   └── pyproject.toml   # Python dependencies
├── terraform/           # Infrastructure as Code (manages everything!)
│   ├── main.tf          # Main infrastructure (VPC, EKS, RDS)
│   ├── k8s.tf          # Kubernetes resources (deployments, services, ingress)
│   ├── cleaner.tf      # Lambda cleanup function
│   └── ...             # Other Terraform configs
└── k8s/                # Reference K8s manifests (not used - Terraform manages K8s)
    ├── api_deployment.yaml
    ├── web_deployment.yaml
    ├── ingress.yaml
    └── ...
```

## 🛠️ API Endpoints

### Authentication
- `POST /auth/register` - Register a new user
- `POST /auth/jwt/login` - Login and get JWT token
- `POST /auth/jwt/logout` - Logout
- `POST /auth/forgot-password` - Request password reset
- `POST /auth/reset-password` - Reset password
- `GET /users/me` - Get current user info

### Posts
- `POST /upload` - Upload a new post (image/video with caption)
- `GET /feed` - Get all posts ordered by creation date
- `DELETE /posts/{post_id}` - Delete a specific post (owner only)

## 🧪 Testing

Run backend tests:
```bash
cd backend
pytest test.py
```

## 📦 Dependencies

### Backend
- FastAPI - Modern web framework
- FastAPI Users - Authentication system
- SQLAlchemy - ORM with async support
- aiomysql - Async MySQL driver
- ImageKitIO - Media storage SDK
- Uvicorn - ASGI server
- python-dotenv - Environment variable management

### Frontend
- Streamlit - Web UI framework
- Requests - HTTP client

## 🔐 Security

- JWT-based authentication with FastAPI Users
- Password hashing and verification
- User ownership validation for post deletion
- Secure database credentials management via environment variables
- AWS security groups for network isolation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

Maintained by the Simple Social team

## 🙏 Acknowledgments

- **[Code with Tim](https://www.youtube.com/@TechWithTim)** - This project is based on a FastAPI and Streamlit tutorial by Code with Tim. The original tutorial provided the foundation for the backend API and frontend interface.
  - **Modifications made**: 
    - Migrated database from SQLite to MySQL with async support
    - Added file deletion functionality from ImageKit
    - Containerized the application with Docker (Dockerfile for both backend and frontend)
    - Made backend URL configurable via environment variables (was hardcoded in original)
    - Implemented full AWS cloud deployment with Terraform
    - Added Kubernetes orchestration on EKS
    - Enhanced infrastructure with VPC, RDS, and automated cleanup
- FastAPI for the excellent web framework
- Streamlit for the easy-to-use UI framework
- ImageKit for media storage solutions
- AWS for cloud infrastructure
