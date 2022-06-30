# copy if not exists
cp -n /vol_hub_setting/user-setting.yaml /jupyterhub/user-setting.yaml

# create users and groups
if [ "$(ls /home)" ]; then
    echo "Users and groups are already created."
else
    source $(python /jupyterhub/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m user)
fi

# run jupyterhub
source $(python /jupyterhub/gen_shell_script.py -f /jupyterhub/user-setting.yaml -m hub)