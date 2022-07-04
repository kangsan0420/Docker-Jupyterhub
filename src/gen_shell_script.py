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
  
parser = argparse.ArgumentParser(description='Generate shell command from yaml file.')
parser.add_argument('-f', '--fname', type=str, required=True, help='Path to yaml file')
args = parser.parse_args()

config = yaml.load(open(args.fname), yaml.SafeLoader)

print(user_group_command(config))
