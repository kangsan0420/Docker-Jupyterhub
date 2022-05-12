docker run --shm-size=32G -d -v <some_path>:/VOLUME -p <some_port>:80 --ulimit core=0 --name <cnt_name> <img_name>
