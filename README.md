# Complete Guide: React App with Docker & GitHub Actions CI/CD

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installing Docker](#installing-docker)
3. [Creating React Application](#creating-react-application)
4. [Dockerizing the React App](#dockerizing-the-react-app)
5. [Setting up Docker Hub](#setting-up-docker-hub)
6. [Configuring GitHub Actions CI/CD](#configuring-github-actions-cicd)
7. [Testing the Pipeline](#testing-the-pipeline)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:
- Node.js (version 14 or higher)
- Git installed on your system
- GitHub account
- Docker Hub account

---

## Installing Docker

### Windows
1. **Download Docker Desktop:**
   - Visit [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
   - Download the installer

2. **Install Docker Desktop:**
   - Run the installer as administrator
   - Follow the installation wizard
   - Restart your computer when prompted

3. **Verify Installation:**
   ```bash
   docker --version
   docker-compose --version
   ```

### macOS
1. **Download Docker Desktop:**
   - Visit [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
   - Download the appropriate version (Intel or Apple Silicon)

2. **Install Docker Desktop:**
   - Open the downloaded .dmg file
   - Drag Docker to Applications folder
   - Launch Docker from Applications

3. **Verify Installation:**
   ```bash
   docker --version
   docker-compose --version
   ```

### Linux (Ubuntu/Debian)
1. **Update package index:**
   ```bash
   sudo apt-get update
   ```

2. **Install required packages:**
   ```bash
   sudo apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   ```

3. **Add Docker's official GPG key:**
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

4. **Set up repository:**
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Install Docker Engine:**
   ```bash
   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
   ```

6. **Add user to docker group:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

7. **Verify Installation:**
   ```bash
   docker --version
   docker compose version
   ```

---

## Creating React Application

### Step 1: Create React App
```bash
# Create new React application
npx create-react-app my-react-app

# Navigate to project directory
cd my-react-app

# Test the application
npm start
```

### Step 2: Initialize Git Repository
```bash
# Initialize git repository
git init

# Add remote repository (replace with your GitHub repo URL)
git remote add origin https://github.com/yourusername/my-react-app.git

# Add all files
git add .

# Commit initial files
git commit -m "Initial commit"

# Push to GitHub
git branch -M master
git push -u origin master
```

### Step 3: Customize Your App (Optional)
Edit `src/App.js` to add your custom content:
```javascript
function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>My React App with Docker & CI/CD</h1>
        <p>Successfully deployed with GitHub Actions!</p>
      </header>
    </div>
  );
}

export default App;
```

### Step 4: Update Test File
After customizing your app, update `src/App.test.js` to match your new content:
```javascript
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders app title', () => {
  render(<App />);
  const titleElement = screen.getByText(/My React App with Docker & CI\/CD/i);
  expect(titleElement).toBeInTheDocument();
});

test('renders deployment message', () => {
  render(<App />);
  const messageElement = screen.getByText(/Successfully deployed with GitHub Actions!/i);
  expect(messageElement).toBeInTheDocument();
});
```

---

## Dockerizing the React App

### Step 1: Create Dockerfile
Create a `Dockerfile` in your project root:

```dockerfile
# Multi-stage build for production
FROM node:18-alpine as build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built app to nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx config (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

### Step 2: Create .dockerignore
Create `.dockerignore` file:
```
node_modules
npm-debug.log
Dockerfile
.dockerignore
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.coverage.*
```

### Step 3: Build and Test Docker Image Locally
```bash
# Build Docker image
docker build -t my-react-app .

# Run container locally
docker run -p 3000:80 my-react-app

# Test in browser: http://localhost:3000
```

---

## Setting up Docker Hub

### Step 1: Create Docker Hub Account
1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign up for a free account
3. Verify your email address

### Step 2: Create Repository
1. Click "Create Repository"
2. Enter repository name (e.g., `my-react-app`)
3. Set visibility (Public/Private)
4. Click "Create"

### Step 3: Login to Docker Hub via CLI
```bash
# Login to Docker Hub
docker login

# Enter your Docker Hub username and password
```

### Step 4: Push Image to Docker Hub
```bash
# Tag your image
docker tag my-react-app youknowwhoitssaymon/my-react-app:latest

# Push to Docker Hub
docker push youknowwhoitssaymon/my-react-app:latest
```

---

## Configuring GitHub Actions CI/CD

### Step 1: Create GitHub Secrets
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the following secrets:
   - `DOCKER_HUB_USERNAME`: youknowwhoitssaymon
   - `DOCKER_HUB_ACCESS_TOKEN`: Docker Hub access token

### Step 2: Generate Docker Hub Access Token
1. Go to Docker Hub → Account Settings → Security
2. Click "New Access Token"
3. **Important:** Set permissions to "Read, Write, Delete" (not just Read)
4. Give it a description (e.g., "GitHub Actions CI/CD")
5. Copy the token immediately (you won't see it again)
6. Add this token as `DOCKER_HUB_ACCESS_TOKEN` in GitHub secrets

**Note:** Make sure to use an Access Token, not your Docker Hub password!

### Step 3: Create GitHub Actions Workflow
Create `.github/workflows/ci-cd.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ master, develop ]
  pull_request:
    branches: [ master ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/master'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ secrets.DOCKER_HUB_USERNAME }}/my-react-app
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Step 4: Commit and Push Workflow
```bash
# Add workflow file
git add .github/workflows/ci-cd.yml

# Commit changes
git commit -m "Add CI/CD pipeline with GitHub Actions"

# Push to GitHub
git push origin main
```

---

## Testing the Pipeline

### Step 1: Trigger Pipeline
1. Make a change to your React app
2. Commit and push to main branch:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```

### Step 2: Monitor Pipeline
1. Go to your GitHub repository
2. Click on "Actions" tab
3. Watch the pipeline execution
4. Check for any errors in the logs

### Step 3: Verify Docker Hub
1. Go to your Docker Hub repository
2. Check if the new image was pushed
3. Verify the tags are correct

### Step 4: Test Deployed Image
```bash
# Pull and run the latest image
docker pull youknowwhoitssaymon/my-react-app:latest
docker run -p 3000:80 youknowwhoitssaymon/my-react-app:latest
```

---

## Troubleshooting

### Common Issues and Solutions

#### Docker Build Fails
- **Issue**: `npm ci` fails during build
- **Solution**: Ensure `package-lock.json` is committed to repository

#### GitHub Actions Authentication Fails (401 Unauthorized)
- **Issue**: "failed to authorize: failed to fetch oauth token: 401 Unauthorized"
- **Solutions**:
  1. **Regenerate Docker Hub Access Token**:
     - Go to Docker Hub → Account Settings → Security
     - Delete old token and create new one with "Read, Write, Delete" permissions
     - Update `DOCKER_HUB_ACCESS_TOKEN` secret in GitHub
  
  2. **Verify GitHub Secrets**:
     - Go to GitHub repo → Settings → Secrets and variables → Actions
     - Ensure `DOCKER_HUB_USERNAME` matches your Docker Hub username exactly
     - Ensure `DOCKER_HUB_ACCESS_TOKEN` is the token (not password)
     - Check for any extra spaces in the secrets
  
  3. **Repository Name Check**:
     - Ensure Docker Hub repository exists: `youknowwhoitssaymon/my-react-app`
     - Repository name in workflow must match exactly
     - Make sure repository is public or you have proper permissions

#### Image Push Fails
- **Issue**: Permission denied when pushing to Docker Hub
- **Solution**: Ensure Docker Hub access token has write permissions

#### React App Doesn't Load
- **Issue**: App shows nginx default page
- **Solution**: Verify build output is correctly copied to nginx html directory

#### Port Conflicts
- **Issue**: Port already in use when running locally
- **Solution**: Use different port mapping: `docker run -p 8080:80 image-name`

### Debugging Commands
```bash
# Check Docker processes
docker ps

# View container logs
docker logs container-id

# Inspect image
docker inspect image-name

# Clean up unused images
docker system prune

# Check GitHub Actions logs
# Go to GitHub repository → Actions → Select workflow run
```

### Best Practices
1. Always use multi-stage builds for production
2. Use specific Node.js versions instead of 'latest'
3. Implement proper error handling in workflows
4. Use semantic versioning for Docker tags
5. Keep secrets secure and rotate them regularly
6. Test locally before pushing to main branch
7. Use `.dockerignore` to reduce image size
8. Monitor build times and optimize if necessary

---

## Next Steps

After completing this setup, consider:
1. Adding environment-specific configurations
2. Implementing automated testing with coverage reports
3. Setting up deployment to cloud platforms (AWS, Azure, GCP)
4. Adding monitoring and logging
5. Implementing blue-green deployments
6. Setting up staging environments

---

*This documentation provides a complete workflow for containerizing a React application and setting up automated CI/CD with GitHub Actions and Docker Hub.*
