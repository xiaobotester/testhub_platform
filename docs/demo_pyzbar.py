# -*- coding: utf-8 -*-
# -----------------------------
# @Author    : 影子
# @Time      : 2026/2/2 10:35
# @Software  : PyCharm
# @FileName  : demo_pyzbar.py
# -----------------------------
from pyzbar.pyzbar import decode
from PIL import Image

# 读取图像文件
image = Image.open('../static_files/img/barcode_1769491234_cd91d251_code128.png')

# 解码图像中的条形码或 QR 码
decoded_objects = decode(image)

# 打印解码结果
for obj in decoded_objects:
    print(f"Data: {obj.data.decode('utf-8')}, Type: {obj.type}")