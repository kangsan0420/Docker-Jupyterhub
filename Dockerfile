FROM pytorchlightning/pytorch_lightning:base-cuda-py3.9-torch1.11

# Install Required Packages
RUN \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt update && apt install -y nodejs vim sudo libgl1-mesa-glx && \
    npm install -g configurable-http-proxy \
    && \
    pip install jupyter jupyterlab jupyterhub jupyterlab_execute_time

# Customize
RUN \
    echo "SKEL=/etc/skel" >> /etc/default/useradd && \
    echo "cd \$notebook_dir" >> /etc/skel/.bashrc && \
    echo "HISTTIMEFORMAT=\"%Y%m%d %H:%M:%S] \"" >> /etc/profile
COPY .jupyter /etc/skel/.jupyter

# Automate user setting
COPY ./src /jupyterhub/src/
RUN \
    mkdir /var/log/jupyterhub && \
    chmod +x /jupyterhub/src/run.sh

# Install Optional Packages & Clear cache
RUN \
    pip install \
                jupyter-resource-usage \
                pytorch_lightning torchmetrics torchsummary \
                pandas scikit-learn tqdm matplotlib \
                opencv-python ray[tune] wandb \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /root/.cache && \
    rm -rf /var/lib/apt/lists/*

# Environment Variables
ENV \
    TZ=Asia/Seoul \
    MODE=JupyterHub \
    notebook_dir=/

WORKDIR /jupyterhub
ENTRYPOINT /jupyterhub/src/run.sh
