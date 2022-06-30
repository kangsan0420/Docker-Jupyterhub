# copy if not exists
cp -n /vol_hub_setting/user-setting.yaml /jupyterhub/user-setting.yaml

# create users and groups
if [ -d /jupyterhub/gen  ]; then
    echo "It's not a first running. Just starting jupyterhub..."
else
    mkdir /jupyterhub/gen
    python /jupyterhub/src/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m user > /jupyterhub/gen/create_users_and_groups.sh
    python /jupyterhub/src/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m hub > /jupyterhub/gen/hub.sh
    
    source /jupyterhub/gen/create_users_and_groups.sh
fi

# run jupyterhub
source /jupyterhub/gen/hub.sh
