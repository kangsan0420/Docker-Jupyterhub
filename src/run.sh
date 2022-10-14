# copy if not exists
if [ -d /vol_hub_setting ]; then
    cp -n /vol_hub_setting/user-setting.yaml /vol_hub_setting/jupyterhub_config.py /jupyterhub/
else
    echo "Couldn't find \"user-setting.yaml\" and \"jupyterhub_config.py\". Set a volume for jupyterhub setting files to \"/vol_hub_setting\""
fi

# create users and groups
if [ -f /jupyterhub/src/create_users_and_groups.sh  ]; then
    echo "It's not a first running. Just starting jupyterhub..."
else
    python /jupyterhub/src/gen_shell_script.py -f /jupyterhub/user-setting.yaml > /jupyterhub/src/create_users_and_groups.sh
    source /jupyterhub/src/create_users_and_groups.sh
fi

# run jupyterhub if $HUB_OFF is not set
if [ "$MODE" == "JupyterHub" ]; then
    jupyterhub -f /jupyterhub/jupyterhub_config.py >> /var/log/jupyterhub/stdout.log
elif [ "$MODE" == "JupyterLab"]; then
    jupyterlab --ip '*' --port 8000 --allow-root --no-browser --ServerApp.token='' --ServerApp.notebook_dir="$notebook_dir"
else
    echo "MODE is not JupyterHub or JupyterLab. sleep infinity..."
    sleep infinity
fi
