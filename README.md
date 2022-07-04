# Configurable Jupyterhub on Docker

## 1.Build the Dockerfile first:
```bash
docker build -t mnc_jupyter:latest .
```

## 2. Set config with user-setting.yaml
- valid keys: sudo, group, uid, passwd

## 3. Run
### 3-1. with docker run
```bash
docker run --shm-size=32G -d -v <host_volume_path>:/VOLUME -p <jupyterhub_port>:8000 --ulimit core=0 --name <container_name> mnc_jupyter:latest
```
- Set the default umask on JupyterHub: `-e umask=0o002`
- For debug mode (turn off JupyterHub): `-e HUB_OFF=true`

## 3-2. with docker-compose
```bash
docker-compose up -d
docker-compose up -d --profile with-db # run a mariadb container too.
```

To stop and remove the service:
```bash
docker-compose down
```

