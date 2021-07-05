import copy
import json
import sys
import os

LIST_JSON = ['config.test.json', 'config.dev.json']
sample_json = 'config.sample.json'
CODE_HOME   = os.path.abspath(os.path.dirname(__file__) + '/..')

def setup_list_config_file(ip_address=None):
    for json_file in LIST_JSON:
        setup_address(ip_address=ip_address, json_file=json_file)

def setup_address(ip_address=None, json_file=None):
    file_path = f'{CODE_HOME}/{json_file}'
    if os.path.exists(file_path):
        print(f'Update ipaddress file {json_file}')
        with open(file_path) as f_r:
            config_json_data = json.load(f_r)
            config_data = copy.deepcopy(config_json_data)
            print(f"[BEFORE] postgres : {config_data['postgres']}")
            config_data['postgres'].update({
                "host": ip_address
            })
            print(f"[AFTER]  postgres : {config_data['postgres']}")

            config_data = upd_more_config(config_data)

        with open(file_path, 'w') as f_w:
            json.dump(config_data, f_w, indent=4, sort_keys=True)

        print(f'Update ipaddress file {json_file}...Done!')
    else:
        print(f'not found {json_file} - please create one e.g. cp config.sample.json {json_file}')

def upd_more_config(config_data):
    file_path = f'{CODE_HOME}/{sample_json}'
    if os.path.exists(file_path):
        with open(file_path) as f_r:
            config_json_data = json.load(f_r)
            config_sample_data = copy.deepcopy(config_json_data)
            for key, value in config_sample_data.items():
                value_by_key = config_data.get(key)
                if not value_by_key:
                    print(f"[ADD MORE]  {key} : {value}")
                    config_data.update({
                        key: value
                    })
    else:
        print(f'not found {sample_json} - please check it')

    return config_data

if __name__ == '__main__':
    ip_address = sys.argv[1]
    setup_list_config_file(ip_address)
