

test = {
    'a': {
        'b': 'c'
    },
    'a2': {
        'b2': {
            'c2': {
                'd2': 1,
                'e2': 2
            }
        }
    },
    'a3': 'b3'
}


# flatten a nested dictionary
def flatten_dict(d = None, new_d = None, pre_key=None) -> dict:
    if d is None:
        d = {}
    if new_d is None:
        new_d = {}

    for k, v in d.items():
        print(f'k: {k}, v: {v}, pre_key: {pre_key}')
        if isinstance(v, dict):
            pre_key = k if not pre_key else f'{pre_key}__{k}'
            new_d = flatten_dict(v, new_d=new_d, pre_key=pre_key)
        elif pre_key:
            new_d.update({
                f'{pre_key}__{k}': v
            })
        else:
            new_d.update({
                f'{k}': v
            })

    return new_d


class GetOb(object):
    def __init__(self, template_name, **kwargs):
        self.template_name = template_name

    def process(self):
        something = 'something'
        if self.template_name:
            func = f'{self.template_name}__'
            print(f'func: {func}')
            # get self method
            method = getattr(self, func, None)
            if method:
                method()
            else:
                print("not found")

        print("from process")

    def mep__(self):
        print("from mep")


if __name__ == '__main__':
    # res = flatten_dict(test)
    # print(f'res: {res}')
    GetOb('mep').process()


