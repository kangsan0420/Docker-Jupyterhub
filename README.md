# Configurable Jupyterhub on Docker

## 1. Clone this repo.
```bash
git clone git@svc.mnc.ai:mnc/mnc-docker-jupyterhub.git
cd mnc-docker-jupyterhub
```

## 2. Build the Dockerfile first:
```bash
docker build -t mnc/jupyterhub:latest .
```

## 3. Set config with user-setting.yaml
valid keys:  
- groups:  
  - name: required  
  - gid: optional (default: set by OS)  

- users:  
  - name: required
  - sudo: true or false (optional, default: false)  
  - group: any valid group name (optional, default: username)  
  - uid: any valid uid (optional, default: set by OS, must be unique)  
  - passwd: any valid password (optional, default: username)  

```yaml
# example
groups:
  - name: mnc
  - gid: 1004

users:
  - name: kslee
    sudo: true
    group: mnc
    uid: 1003 # match w host uid for permission

  - name: guest
    passwd: 1234
```

## 4. Run
### 4-1. Using docker run
```bash
docker run -d --ulimit core=0 \
    --shm-size=32G \
    -v $(pwd):/vol_hub_setting \ # to pass "user-setting.yaml" on runtime
    -v $host_volume_path:/workspace \ # hub root directory
    -p $jupyterhub_port:8000 \
    --name $container_name \
    mnc/jupyterhub:latest
```
- Set the default umask on JupyterHub: `-e umask=0o002`
- For Single-user (JupyterLab): `-e MODE=JupyterLab`
- For debug mode (turn off entrypoint): `-e Mode= `

### 4-2. Using docker-compose
```bash
docker-compose up -d
docker-compose up -d --profile with-db # run a mariadb container.
```

To stop and remove the service:
```bash
docker-compose down
```
