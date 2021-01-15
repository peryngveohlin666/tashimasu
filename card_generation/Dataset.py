import os
import queue
import threading
import concurrent.futures

from PIL import Image
import numpy as np

path = "../dataset"
thread_num = 16
# split the data into chunks equal to the thread count (to avoid memory errors I am splitting the dataset as it is too big for my memory to handle)
chunks = np.split(np.asarray(os.listdir(path)), thread_num)


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
def load_dataset(load_from, load_to):
    x = []
    y = []
    threads = []
    with concurrent.futures.ThreadPoolExecutor() as executor:
        for chunk in chunks[load_from:load_to]:
            f = executor.submit(load_data, chunk)
            threads.append(f)
    for thread in threads:
        for X in thread.result()[0]:
            x.append(X)
        for Y in thread.result()[1]:
            y.append(Y)
    return np.asarray(x), np.asarray(y)



print(load_dataset(0, 6400))