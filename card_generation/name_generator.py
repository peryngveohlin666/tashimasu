from random import randint
import re

path = "../dataset/names"

mei = []  # forenames
sei = []  # surnames

text_names = open(path + "/names.csv")
text_surnames = open(path + "/surnames.csv")

for line in text_names:
    line = re.sub('["\n]', '', line)  # replace every new line and " symbols with nothing
    mei.append(line)

for line in text_surnames:
    line = re.sub('["\n]', '', line)  # replace every new line and " symbols with nothing
    sei.append(line)


# a function to generate names
def generate_names(n=1):
    names = []
    for i in range(n):
        names.append(mei[randint(0, len(mei))] + " " + sei[randint(0, len(sei))])
    return names

