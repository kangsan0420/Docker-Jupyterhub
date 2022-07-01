FROM pytorchlightning/pytorch_lightning:base-cuda-py3.9-torch1.11

ENV TZ=Asia/Seoul

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt update && apt install -y nodejs vim sudo libgl1-mesa-glx
RUN npm install -g configurable-http-proxy

RUN pip install jupyter jupyterlab jupyterhub jupyterlab_execute_time \
                pytorch_lightning torchmetrics torchsummary \
                pandas scikit-learn tqdm matplotlib \
                opencv-python ray[tune] wandb
RUN jupyter labextension install @jupyterlab/toc @jupyter-widgets/jupyterlab-manager

RUN echo "SKEL=/etc/skel" >> /etc/default/useradd
RUN echo "cd $notebook_dir" >> /etc/skel/.bashrc
RUN echo "HISTTIMEFORMAT=\"%Y%m%d %H:%M:%S] \"" >> /etc/profile

COPY .jupyter /etc/skel/.jupyter
COPY ./src/gen_shell_script.py ./src/run.sh /jupyterhub/src/

WORKDIR /jupyterhub
RUN mkdir /var/log/jupyterhub
RUN chmod +x /jupyterhub/src/run.sh

ENTRYPOINT /jupyterhub/src/run.sh

