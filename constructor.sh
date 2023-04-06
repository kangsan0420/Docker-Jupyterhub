
function pip_install_if_not_exists() {
	local PKG=$1

    if pip list | grep $PKG &>/dev/null; then
        echo "\"$PKG\" already installed."
    else
        pip install $PKG
    fi
}

echo -e "\n\
    \r============================= \n\
    \r== Jupyter IDE Constructor == \n\
    \r============================= \n"

echo "Select Jupyter-:"
echo "[1] Lab"
echo "[2] Hub"
read -rp "Enter your choice [1]: " TYPE

case $TYPE in
    1) TYPE="lab" ;;
    2) TYPE="hub" ;;
    *) TYPE="lab" ;;
esac

if [ "$TYPE" == "lab" ]; then
    pip_install_if_not_exists "jupyterlab"
else
    pip_install_if_not_exists "jupyterhub"
fi

# read -rp "IP of Jupyter $TYPE ['*']: " ip
ip=${ip:-"'0.0.0.0'"}

read -rp "Port of Jupyter $TYPE [80]: " PORT
PORT=${PORT:-80}

read -rp "Base URL? ['/']: " URL
BASE_URL=${URL:-/}

read -rp "Root Directory ? ['']: " ROOT_DIR
ROOT_DIR=${ROOT_DIR:-}

read -rp "Load settings for jupyter lab/notebook? ([y]/n): " LOAD
if [[ ${LOAD:-y} =~ ^[Yy]$ ]]
then
    echo 'Cloning from "https://github.com/kangsan0420/Docker-Jupyterhub.git":'
    git clone https://github.com/kangsan0420/Docker-Jupyterhub.git
    mv Docker-Jupyterhub/.jupyter ~/.jupyter
    rm -rf Docker-Jupyterhub
    echo "HISTTIMEFORMAT=\"%Y%m%d %H:%M:%S] \"" >> /etc/profile
fi
    
read -rp 'Install "jupyterlab-execute-time"? ([y]/n): ' EX1
read -rp 'Install "jupyterlab-system-monitor"? ([y]/n): ' EX2
read -rp 'Install "jupyterlab-lsp"? ([y]/n): ' EX3

if [[ ${EX1:-y} =~ ^[Yy]$ ]]; then pip_install_if_not_exists "jupyterlab-execute-time"; fi
if [[ ${EX2:-y} =~ ^[Yy]$ ]]; then pip_install_if_not_exists "jupyterlab-system-monitor"; fi
if [[ ${EX3:-y} =~ ^[Yy]$ ]]; then pip_install_if_not_exists "jupyterlab-lsp"; fi

if [ "$TYPE" == "lab" ]; then
    read -rp 'Set password for jupyter lab"? (y/[n]): ' JL1
    if [[ ${JL1:-n} =~ ^[Yy]$ ]]; then
        PASSWD=$(python3 -c "from jupyter_server.auth import passwd; print(passwd())")
    fi
else
    if node -v &>/dev/null; then
        echo '"NodeJS" already installed.'
    else
        curl -s https://deb.nodesource.com/setup_16.x | sh
    fi
    if npm explain configurable-http-proxy &>/dev/null; then
        echo '"configurable-http-proxy" already installed.'
    else
        npm install -g configurable-http-proxy
    fi
    
    cp -r ~/.jupyter /etc/skel/
    echo "SKEL=/etc/skel" >> /etc/default/useradd
    
    ADMINS=()
    while :
    do
        read -rp "Type username to add as admin (Type N to stop). [{username}/n]: " NAME
        if [[ $NAME =~ ^[Nn]$ ]]; then
            break
        fi
        if id "$NAME" &>/dev/null; then
            echo "User \"$NAME\" already exists."
        else
            useradd $NAME
            passwd $NAME
            mkdir /home/$NAME
            chown $NAME:$NAME /home/$NAME
        fi
        ADMINS+=($NAME)
    done
    USERS=()
    while :
    do
        read -rp "Type username to add as user (Type N to stop). [{username}/n]: " NAME
        if [[ $NAME =~ ^[Nn]$ ]]; then
            break
        fi
        if id "$NAME" &>/dev/null; then
            echo "User \"$NAME\" already exists."
        else
            useradd $NAME
            passwd $NAME
            mkdir /home/$NAME
            chown $NAME:$NAME /home/$NAME
        fi
        USERS+=($NAME)
    done
fi

CMD="jupyter"
if [ "$TYPE" == "lab" ]; then
    CMD+="-lab"
    CMD+=" --allow-root --no-browser --ip='*' --port-retries=0"
    CMD+=" --ServerApp.quit_button=false --ServerApp.allow_password_change=false"
    CMD+=" --port $PORT --notebook-dir=$ROOT_DIR --ServerApp.base_url=$BASE_URL"
    if [ -n "$PASSWD" ]; then
        CMD+=" --ServerApp.password=$PASSWD"
    else
        CMD+=" --ServerApp.token=''"
    fi
    # CMD+=" --collaborative"
else
    CMD+="hub"
    CMD+=" --Spawner.default_url=/lab --Spawner.environment='TZ=Asia/Seoul'"
    CMD+=" --url='http://$IP:$PORT' --base-url=$BASE_URL --Spawner.notebook_dir=$ROOT_DIR"
    for USER in "${ADMINS[@]}"
    do
        CMD+=" --Authenticator.admin_users=$USER"
    done
    for USER in "${USERS[@]}"
    do
        CMD+=" --Authenticator.allowed_users=$USER"
    done
    # CMD+=" --JupyterHub.logo_file='' --Spawner.cpu_guarantee=1  --Spawner.mem_limit=16G"
fi

$CMD

## jupyter_lab_config.py
# c = get_config()  #noqa
# c.ServerApp.ip = 'localhost'
# c.ServerApp.open_browser = False
# c.ServerApp.port_retries = 0
# c.ServerApp.quit_button = True
# c.ServerApp.allow_password_change = True
# c.ServerApp.allow_root = False
# c.LabApp.collaborative = False
# c.ServerApp.port = 0
# c.ServerApp.root_dir = ''
# c.ServerApp.base_url = '/'
# c.ServerApp.password = ''
# c.ServerApp.token = '<generated>'

## jupyterhub_config.py
# c = get_config()  #noqa
# c.JupyterHub.logo_file = ''
# c.Spawner.default_url = '/lab'  # initial directory
# c.Spawner.env_keep = ['PATH', 'PYTHONPATH', 'LANG', 'LC_ALL']
# c.Spawner.environment = {'TZ': 'Asia/Seoul'}
# c.Spawner.cpu_guarantee = None  
# c.Spawner.cpu_limit = None
# c.Spawner.mem_guarantee = None
# c.Spawner.mem_limit = None
# c.Spawner.notebook_dir = '' # hub root (~ and {username} are available)
# c.JupyterHub.base_url = '/'
# c.Authenticator.admin_users = set()
# c.Authenticator.allowed_users = set()
# c.JupyterHub.bind_url = 'http://:8000'
# # from subprocess import check_call
# # def my_hook(spawner):
# #     username = spawner.user.name
# #     check_call(['./examples/bootstrap-script/bootstrap.sh', username])
# c.Spawner.pre_spawn_hook = None
# c.Spawner.post_stop_hook = None