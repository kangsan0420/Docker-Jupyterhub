FROM pytorchlightning/pytorch_lightning:base-cuda-py3.9-torch1.11

# environment variables
ENV notebook_dir=/VOLUME \ 
    dir_uid=1003 \
    admin_id=kslee \
    admin_pw=1234 \
    hub_group=mnc 

ENV TZ=Asia/Seoul

RUN apt update
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs vim sudo libgl1-mesa-glx
RUN npm install -g configurable-http-proxy
RUN pip install pytorch_lightning scikit-learn ray[tune] wandb \
                torchmetrics torchsummary \
                pandas opencv-python tqdm matplotlib \
                jupyter jupyterlab jupyterhub jupyterlab_execute_time
RUN jupyter labextension install @jupyterlab/toc @jupyter-widgets/jupyterlab-manager

RUN echo "SKEL=/etc/skel" >> /etc/default/useradd
COPY .jupyter /etc/skel/.jupyter
RUN echo "cd ${notebook_dir}" >> /etc/skel/.bashrc
RUN groupadd mnc
RUN useradd -rm -G sudo,$hub_group $admin_id -s /bin/bash -p $(perl -e 'print crypt($ARGV[0], "password")' $admin_pw) -u $dir_uid
RUN chmod 777 /tmp
WORKDIR /jupyterhub

ENTRYPOINT jupyterhub --port=80 --ip=0.0.0.0 --Spawner.default_url="/lab" --Spawner.notebook_dir=$notebook_dir --LocalAuthenticator.create_system_users=true --Authenticator.admin_users $admin_id --Spawner.environment TZ=$TZ --LocalAuthenticator.allowed_groups=$hub_group

