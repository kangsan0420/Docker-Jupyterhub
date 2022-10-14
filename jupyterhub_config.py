# Configuration file for jupyterhub.

import os
os.umask(int(str(os.environ.get('umask') or '0o022'), 8))
""" Default file permission created on Hub
0o022: u=rwx,g=rx,o=rx  (normal)
0o002: u=rwx,g=rwx,o=rx (allowed)
0o023: u=rwx,g=rx,o=r   (strict)
"""

import yaml
user_config = yaml.safe_load(open('/vol_hub_setting/user-setting.yaml'))

c.JupyterHub.bind_url = 'http://0.0.0.0:8000'
c.JupyterHub.pid_file = '/var/log/jupyterhub/jupyterhub.pid'
c.Spawner.default_url = '/lab'
c.Spawner.environment = {key: os.environ.get(key) for key in [
  'TZ', 'notebook_dir'
]}
c.Spawner.notebook_dir = os.environ.get('notebook_dir', '/')
c.JupyterHub.admin_access = True
c.Authenticator.admin_users = set(usr['name'] for usr in user_config['users'] if usr.get('sudo') is True)
c.Authenticator.allowed_users = set(usr['name'] for usr in user_config['users']) - c.Authenticator.admin_users
c.JupyterHub.logo_file = '/jupyterhub/src/mnc_logo_orange.png'

# jupyterhub >> /var/log/jupyterhub.log
