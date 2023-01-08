import argparse
import random

g = "\x1b[1;32m" # green color format
n = "\x1b[0m" # normal color format

result = []
f = open("tmp/result.txt","w")


def gen(numbers):
    numbers = int(numbers)
    while True:
        if len(result) > numbers - 1: break
        x = 0
        nvar = 0
        num = []
        num_n = []
        num_s = []
        for i in range(random.randrange(13, 17)):
            num.append(random.randrange(0,10))
        for num_x in num[:len(num)-1][::-1]:
            if x == 0:
                num_xx = num_x * 2
                if num_xx > 9:
                    num_xx = num_xx % 10 + 1
                num_n.append(num_xx)
                x = 1
            elif x == 1:
                num_n.append(num_x)
                x = 0
        for n in num: num_s.append(str(n))
        for n in num_n: nvar+=n
        if int(str(nvar * 9)[-1]) == num[-1]:
            print(f"{g}{''.join(num_s)}{n}")
            f.write("".join(num_s)+"\n")
            result.append("".join(num_s))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="Analise token holder address."
    )

    parser.add_argument(
        "-n", "--number", default=10,
        help=f"\033[32m\033[1m\nNumber credit card gen \033[0m"
    )

    number = parser.parse_args().number
    gen(number)
