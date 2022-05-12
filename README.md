# Dockerfile and resources to create a jupyterhub docker container with preferences.

run below:
```
docker run --shm-size=32G -d -v <host_volume_path>:/VOLUME -p <hub_port>:80 --ulimit core=0 --name <container_name> <image_name>
```
