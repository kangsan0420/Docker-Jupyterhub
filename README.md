# Configurable Jupyterhub on Docker

## 1. Clone this repo.
```bash
git clone git@svc.mnc.ai:mnc/mnc-docker-jupyterhub.git
cd mnc-docker-jupyterhub
```

## 2. Build the Dockerfile first:
```bash
docker build -t mnc_jupyter:latest .
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
### 4-1. with docker run
```bash
docker run -d --ulimit core=0 \
    --shm-size=32G \
    -v $(pwd):/vol_hub_setting \ # to handle "user-setting.yaml" on runtime
    -v <host_volume_path>:/VOLUME \ # workspace directory
    -p <jupyterhub_port>:8000 \
    --name <container_name> \
    mnc_jupyter:latest
```
- Set the default umask on JupyterHub: `-e umask=0o002`
- For debug mode (turn off JupyterHub): `-e HUB_OFF=true`

### 4-2. with docker-compose
```bash
docker-compose up -d
docker-compose up -d --profile with-db # run a mariadb container.
```

To stop and remove the service:
```bash
docker-compose down
```
