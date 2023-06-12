import os
import sys
import shutil

CODE_HOME = os.getcwd()


def is_duplicate(fod : str, directory : str) -> bool:
    for i in range(1, 10):
        if f' {i}' in fod:
            fod_cleaned = fod.replace(f' {i}', '')
            if fod_cleaned in os.listdir(directory):
                return True
    return False


def main(directory = None):
    if not directory:
        directory = CODE_HOME
    # list all files in directory
    all_files_and_dirs = os.listdir(directory)
    for files_or_dirs in all_files_and_dirs:
        full_path = f"{directory}/{files_or_dirs}"
        if is_duplicate(files_or_dirs, directory):
            print(f"Remove {full_path}")
            if os.path.isdir(full_path):
                shutil.rmtree(full_path)
            else:
                os.remove(full_path)
        elif os.path.isdir(full_path):
            main(full_path)


if __name__ == '__main__':
    args = sys.argv
    if len(args) > 1:
        root_dir = args[1]
        print(f"Clean {root_dir}")
        main(root_dir)
