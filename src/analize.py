import argparse
from os import path

from src import utils

CURR_DIR = path.dirname(path.abspath(__file__))
CURR_DIR_TMP = f"{CURR_DIR}/tmp"
CODE_HOME = f"{CURR_DIR}/.."  # code home
CODE_HOME_TMP = f"{CODE_HOME}/tmp"
COLUMN_MAPPING = {
    'HolderAddress': 'address',
    'Balance': 'balance',
    'PendingBalanceUpdate': 'update',
}


class AnaliseConfig(object):

    def __init__(self, **kwargs):
        self.dir = kwargs.get('dir') or ''
        self.from_top = kwargs.get('from_top') or 10
        self.to_top = kwargs.get('from_top') or 40
        self.step = kwargs.get('step') or 5

    def check_file(self):
        if not path.isfile(self.dir):
            self.dir = f"{CURR_DIR_TMP}/{self.dir}"
            if not path.isfile(self.dir):
                self.dir = f"{CODE_HOME_TMP}/{self.dir}"
                if not path.isfile(self.dir):
                    print(f"{self.dir} is not exist")
                    exit()

    def process(self):
        self.check_file()
        datas = self._parser_file()

        sum_all, count = self._cal(datas)
        print(f"{sum_all=} and {count=}\n")
        list_loop = self._generate_list()
        print(f"{list_loop=}\n")
        for number in list_loop:
            self._cal_and_print(datas=datas, top_address=number, sum_all=sum_all)

    # generate list from value to value with step
    def _generate_list(self):
        return [i for i in range(self.from_top, self.to_top + 1, self.step)]

    def _cal_and_print(self, datas=None, top_address=0, sum_all=0):
        if not datas:
            datas = []
        sum_top, top_address = self._cal(datas, top_address)
        percent = round(sum_top * 100 / sum_all)
        sum_top = '{:,.0f}'.format(sum_top)
        print(f"sum_top={sum_top} and {top_address=} and percent={percent}%")

    def _cal(self, datas=None, top_address=0):
        if not datas:
            datas = []

        sum_all = 0
        count = 0
        for index, d in enumerate(datas):
            if d.get('balance'):
                value = float(d.get('balance'))
                sum_all += value
                count += 1

            if top_address and index == top_address - 1:
                break

        return round(sum_all), round(count)

    def _parser_file(self):
        parsed_records = []
        raw_v_rows = []

        # region read file upload
        if self.dir.lower().endswith('.csv'):
            raw_v_rows = self._read_csv_file()
        elif self.dir.lower().endswith('.xlsx'):
            raw_v_rows = self._read_xlsx_file()
        else:
            raise Exception
        # endregion

        # region covert data
        parser_all = {
            'address': lambda v: str(v).strip() if v else None,
            'balance': lambda v: float(str(v).strip()) if v else None,
            'update': lambda v: str(v).strip() if v else None,
        }

        kept_as_is = lambda v: v
        for rvr in raw_v_rows:
            pr = dict()  # pr aka parsed_row
            for k, v in rvr.items():  # :k aka key, :v aka value
                parser_func = parser_all.get(k, kept_as_is)
                pr[k] = parser_func(v)
            parsed_records.append(pr)

        # endregion
        parsed_records = sorted(parsed_records, key=lambda k: k['balance'], reverse=True)
        return parsed_records

    def _read_csv_file(self, column_mapping=None):
        if not column_mapping:
            column_mapping = COLUMN_MAPPING
        return utils.read_csv_file(dir_file=self.dir, column_mapping=column_mapping)

    def _read_xlsx_file(self, column_mapping=None):
        if not column_mapping:
            column_mapping = COLUMN_MAPPING
        return utils.read_xlsx_file(dir_file=self.dir, column_mapping=column_mapping)


if __name__ == '__main__':
    # Argparse arguments
    parser = argparse.ArgumentParser(
        description="Analise token holder address."
    )

    parser.add_argument(
        "-f", "--file",
        help=f"\033[32m\033[1m\nFile name to analyse \033[0m"
    )

    dir_file = parser.parse_args().file
    # check file is exist

    AnaliseConfig(
        dir = dir_file,
    ).process()
