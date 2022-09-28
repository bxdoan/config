import os
from PIL import Image


def get_size_format(b, factor=1024, suffix="B", number_only=False):
    """
    Scale bytes to its proper byte format
    e.g:
        1253656 => '1.20MB'
        1253656678 => '1.17GB'
    """
    for unit in ["", "K", "M", "G", "T", "P", "E", "Z"]:
        if b < factor:
            return f"{b:.2f}{unit}{suffix}"
        b /= factor

    if number_only:
        return f"{b:.2f}"
    else:
        return f"{b:.2f}Y{suffix}"


def calc_new_size_ratio(image_size):
    if 300000 < image_size < 10000000:
        new_size_ratio = 0.6
    elif 10000000 < image_size < 100000000:
        new_size_ratio = 0.3
    elif 100000000 < image_size:
        new_size_ratio = 0.1
    else:
        new_size_ratio = 1
    return new_size_ratio


def compress_img(image_name, filename=None, quality=80, width=None, height=None, to_jpg=True):
    # load the image to memory
    img = Image.open(image_name)
    path, _filename = os.path.split(image_name)
    # print the original image shape
    print("[*] Image shape:", img.size)
    # get the original image size in bytes
    image_size = os.path.getsize(image_name)
    print("[*] Size before compression in byte", image_size)
    new_size_ratio = calc_new_size_ratio(image_size)
    if new_size_ratio == 1:
        return None

    # split the filename and extension
    if not filename:
        filename, ext = os.path.splitext(image_name)
        _, filename = os.path.split(filename)
    # make new filename appending _compressed to the original file name
    if to_jpg:
        # change the extension to JPEG
        new_filename = f"{path}/{filename}_compressed.jpg"
    else:
        # retain the same extension of the original image
        new_filename = f"{path}/{filename}_compressed{ext}"

    print("[*] New size ratio", new_size_ratio)
    # print the size before compression/resizing
    size_format = get_size_format(image_size)
    print("[*] Size before compression:", size_format)
    if new_size_ratio < 1.0:
        # if resizing ratio is below 1.0, then multiply width & height with this ratio to reduce image size
        step_reduce_new_size_ratio = new_size_ratio * 0.1
        new_image_size = image_size
        while new_image_size > 300000:
            # if resizing ratio is below 1.0, then multiply width & height with this ratio to reduce image size
            new_width = int(img.size[0] * new_size_ratio)
            new_height = int(img.size[1] * new_size_ratio)
            print(f"[-] New Image shape new width-height: ({new_width}, {new_height})")
            img = img.resize((new_width, new_height), Image.ANTIALIAS)
            save_image(img, new_filename, quality)
            print("[-] New size ratio:", new_size_ratio)
            new_image_size = os.path.getsize(new_filename)
            print("[-] Size after compression:", get_size_format(new_image_size))
            new_size_ratio = round(new_size_ratio - step_reduce_new_size_ratio, 2)

        # print new image shape
        print("[+] New Image shape:", img.size)
    elif width and height:
        # if width and height are set, resize with them instead
        img = img.resize((width, height), Image.ANTIALIAS)
        save_image(img, new_filename, quality)
        # print new image shape
        print("[-] New Image shape:", img.size)

    print("[*] Image shape after:", img.size)
    print("[+] New file saved:", new_filename)
    # get the new image size in bytes
    new_image_size = os.path.getsize(new_filename)
    # print the new size in a good format
    print("[+] Size after compression:", get_size_format(new_image_size))
    # calculate the saving bytes
    saving_diff = new_image_size - image_size
    size_changed = f"{saving_diff/image_size*100:.2f}"
    # print the saving percentage
    print(f"[+] Image size change: {size_changed}% of the original image size.")
    return new_filename


def save_image(img, new_filename, quality):
    try:
        # save the image with the corresponding quality and optimize set to True
        img.save(new_filename, quality=quality, optimize=True)
    except OSError:
        # convert the image to RGB mode first
        img = img.convert("RGB")
        # save the image with the corresponding quality and optimize set to True
        img.save(new_filename, quality=quality, optimize=True)


if __name__ == "__main__":
    image = "/Users/don/Downloads/claim-2450-ID-20220917_084306.jpg"
    # compress the image
    compress_img(image)
