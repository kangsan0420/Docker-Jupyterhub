import sys, yaml
import argparse

def user_group_command(config):
    script = []
    for group in set(dic['group'] for dic in config.values()):
        script.append("groupadd %s" % group)

    for user, dic in config.items():
        options = ('-rm -s /bin/bash') +\
                  (' -g %s' % dic['group'] if 'group' in dic else '') +\
                  (' -G sudo' if dic.get('sudo', False) else '') +\
                  (' -u %s' % dic['uid'] if 'uid' in dic else '')

        if key := {'pw', 'passwd', 'password'} & dic.keys():
            passwd = dic[key.pop()]
        else:
            passwd = user
        options += f" -p $(perl -e 'print crypt($ARGV[0], \"password\")' {passwd})"

        script.append('useradd %s %s' % (options, user))

    script = '\n'.join(script)
    return script
  
def jupyterhub_command(config):
    admin_users = {user for user, dic in config.items() if dic.get('sudo')}
    allowed_users = set(config.keys()) - admin_users

    script = [
        'jupyterhub',
        '--ip=0.0.0.0',
        '--log-level="WARN"',
        '--log-file=/var/log/jupyterhub/stdout.log',
        '--pid-file=/var/log/jupyterhub/processes.pid',
        '--Spawner.default_url="/lab"',
        '--Spawner.notebook_dir=$notebook_dir',
        '--Spawner.environment TZ=$TZ'
    ]
    script += [f'--Authenticator.admin_users="{admin_users}"'] if len(admin_users) else []
    script += [f'--LocalAuthenticator.allowed_users="{allowed_users}"'] if len(allowed_users) else []
    script = ' '.join(script)
    return script

parser = argparse.ArgumentParser(description='Generate shell command from yaml file.')
parser.add_argument('-f', '--fname', type=str, required=True, help='Path to yaml file')
parser.add_argument('-m', '--mode', type=str, required=True, help="(user, hub)")
args = parser.parse_args()

config = yaml.load(open(args.fname), yaml.SafeLoader)

options = {
  'user': user_group_command,
  'hub': jupyterhub_command
}

print(options[args.mode](config))
