FROM pytorchlightning/pytorch_lightning:base-cuda-py3.9-torch1.11

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
COPY ./gen_shell_script.py ./run.sh /jupyterhub/
WORKDIR /jupyterhub

RUN echo 'cd $notebook_dir' >> /etc/skel/.bashrc
RUN echo "HISTTIMEFORMAT=\"%Y%m%d %H:%M:%S] \"" >> /etc/profile
RUN mkdir /var/log/jupyterhub

RUN chmod +x /jupyterhub/run.sh
ENTRYPOINT /jupyterhub/run.sh
