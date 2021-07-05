import copy
import json
import sys
import os

LIST_JSON = ['config.test.json', 'config.dev.json']
sample_json = 'config.sample.json'
CODE_HOME   = os.path.abspath(os.path.dirname(__file__) + '/..')

def load_file(file_path):
    if os.path.exists(file_path):
        with open(file_path) as f_r:
            json_data = json.load(f_r)
            return json_data
    else:
        print(f'not found {sample_json} - please check it')


def dump_file(config_data, file_path):
    with open(file_path, 'w') as f_w:
        json.dump(config_data, f_w, indent=4, sort_keys=True)


def setup_list_config_file(ip_address=None):
    for json_file in LIST_JSON:
        setup_address(ip_address=ip_address, json_file=json_file)


def setup_address(ip_address=None, json_file=None):
    file_path = f'{CODE_HOME}/{json_file}'
    print(f'Update ipaddress file {json_file}')
    config_json_data = load_file(file_path)
    config_data = copy.deepcopy(config_json_data)
    print(f"[BEFORE] postgres : {config_data['postgres']}")
    config_data['postgres'].update({
        "host": ip_address
    })
    print(f"[AFTER]  postgres : {config_data['postgres']}")
    config_data = upd_more_config(config_data)
    dump_file(config_data=config_data, file_path=file_path)
    print(f'Update ipaddress file {json_file}...Done!')


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
