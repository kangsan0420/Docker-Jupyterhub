# copy if not exists
cp -n /vol_hub_setting/user-setting.yaml /jupyterhub/user-setting.yaml

# create users and groups
if [ "$(ls /home)" ]; then
    echo "It's not a first running. Just starting jupyterhub..."
else
    python /jupyterhub/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m user > create_users_and_groups.sh
    source create_users_and_groups.sh
    python /jupyterhub/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m hub > hub.sh
fi

# run jupyterhub
source hub.sh
