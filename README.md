# Configurable Jupyterhub on Docker

## 1.Build the Dockerfile first:
```
docker build -t mnc_jupyter:latest .
```

## 2. Set config with user-setting.yaml
- valid keys: sudo, group, uid, passwd

## 3. Run
### 3-1. with docker run
```
docker run --shm-size=32G -d -v <host_volume_path>:/VOLUME -p <jupyterhub_port>:8000 --ulimit core=0 --name <container_name> mnc_jupyter:latest
```

## 3-2. with docker-compose
```
docker-compose up -d
docker-compose up -d --profile with-db # run a mariadb container too.
```

To stop and remove the service:
```
docker-compose down
```

