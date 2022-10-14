import sys, yaml
import argparse

def user_group_command(config):
    lines = []

    for grp in config['groups']:
        line = f"groupadd {grp['name']}" + addIf('--gid', grp.get('gid'))
        lines.append(line)

    for usr in config['users']:
        line = f"useradd {usr['name']} -rm -s /bin/bash" \
               + addIf('-g', usr.get('group')) \
               + addIf('-G', 'sudo' if usr.get('sudo') else None) \
               + addIf('-u', usr.get('uid')) \
               + addIf('-p', usr.get('passwd', usr['name']), format='''$(perl -e 'print crypt($ARGV[0], "password")' {})''')

        lines.append(line)

    return '\n'.join(lines)
 
parser = argparse.ArgumentParser(description='Generate shell command from yaml file.')
parser.add_argument('-f', '--fname', type=str, required=True, help='Path to yaml file')
args = parser.parse_args()

config = yaml.load(open(args.fname), yaml.SafeLoader)

print(user_group_command(config))
