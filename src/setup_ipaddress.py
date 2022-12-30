from copy import deepcopy
from os import path
import json
import sys

from src import utils

LIST_JSON = ['config.json', 'config.dev.json', 'config.test.json']
sample_json = 'config.sample.json'
CODE_HOME = path.abspath(path.dirname(__file__) + '/..')


class SetupConfig(object):

    def __init__(self, **kwargs):
        self.dir_atlas = kwargs.get('dir_atlas') or ''
        self.ip_address = kwargs.get('ip_address') or ''
        self.file_path = None

    def setup_list_config_file(self):
        for json_file in LIST_JSON:
            self._setup_address(json_file=json_file)

    def _setup_address(self, json_file=None):
        self.file_path = f'{self.dir_atlas}/{json_file}'
        print(f'Update ipaddress file {json_file}')
        config_json_data = self._load_file()
        if config_json_data:
            config_data = deepcopy(config_json_data)
            if config_data.get('postgres'):
                print(f"[BEFORE] postgres : {config_data['postgres']}")
                config_data['postgres'].update({
                    "host": self.ip_address
                })
                print(f"[AFTER]  postgres : {config_data['postgres']}")
            config_data = self.upd_more_config(config_data)
            self._dump_file(config_data=config_data)
            print(f'Update ipaddress file {json_file}...Done!')
        else:
            print(f'not found {self.file_path} - please check it')

    def upd_more_config(self, config_data):
        file_path = f'{self.dir_atlas}/{sample_json}'
        if path.exists(file_path):
            with open(file_path) as f_r:
                config_json_data = json.load(f_r)
                config_sample_data = deepcopy(config_json_data)
                config_data = self._upd_val_key(config_sample_data, config_data)
        else:
            print(f'not found {sample_json} - please check it')
        return config_data

    def _dump_file(self, config_data):
        with open(self.file_path, 'w') as f_w:
            json.dump(config_data, f_w, indent=4, sort_keys=True)

    def _upd_val_key(self, sample_dict, real_dict):
        for key, value_sample_by_key in sample_dict.items():
            if not value_sample_by_key:
                continue
            elif isinstance(value_sample_by_key, dict):
                value_real_by_key = real_dict.get(key)
                if isinstance(value_real_by_key, dict):
                    val_after = self._upd_val_key(value_sample_by_key, value_real_by_key)
                    real_dict = self._do_change_val(real_dict, key, val_after, f_print=False)
                else:
                    real_dict = self._do_change_val(real_dict, key, value_sample_by_key)
            else:
                value_real_by_key = real_dict.get(key)
                if not value_real_by_key:
                    real_dict = self._do_change_val(real_dict, key, value_sample_by_key)
        return real_dict

    def _do_change_val(self, data, k, v=None, f_print=True):
        if f_print:
            print(f"[ADD MORE]  {k} : {v}")
        data.update({
            k: v
        })
        return data

    def _load_file(self):
        if path.exists(self.file_path):
            with open(self.file_path) as f_r:
                json_data = json.load(f_r)
                return json_data
        else:
            return None


if __name__ == '__main__':
    value = utils.split_list(sys.argv[1])
    ip_address = value[0]
    dir_atlas = value[1]
    SetupConfig(
        ip_address = ip_address,
        dir_atlas = dir_atlas,
    ).setup_list_config_file()
