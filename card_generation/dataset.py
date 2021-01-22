# This file is part of the tashimasu distribution (https://github.com/peryngveohlin666/tashimasu).
# Copyright (c) 2021 peryngveohlin666.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import os
import queue
import threading
import concurrent.futures

from PIL import Image
import numpy as np

path = "../dataset/faces"



# a function that takes a list of files and returns it as a dataset
def load_data(files):
    x, y = [], []
    for file in files:
        print(file)
        pic = Image.open(path + "/" + file)
        pic = np.asarray(pic)
        x.append(pic)
        # I don't have labels for the pictures as there is only one type but I will need a label for the y values in GAN
        y.append(0)
    return x, y

# load the whole dataset running the load data function in multiple threads
def load_dataset(load_from, load_to, thread_num):
    x = []
    y = []
    threads = []
    # split the data into chunks equal to the thread count (to avoid memory errors I am splitting the dataset as it is too big for my memory to handle)
    chunks = np.array_split(np.asarray(os.listdir(path)[load_from:load_to]), thread_num)
    with concurrent.futures.ThreadPoolExecutor() as executor:
        for chunk in chunks:
            f = executor.submit(load_data, chunk)
            threads.append(f)
    for thread in threads:
        for X in thread.result()[0]:
            x.append(X)
        for Y in thread.result()[1]:
            y.append(Y)
    return np.asarray(x), np.asarray(y)