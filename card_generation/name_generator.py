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

from random import randint
import re

path = "../dataset/names"

mei = []  # forenames
sei = []  # surnames

# open the datasets
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
        # for each name get a random forename concatinated with a random surname
        names.append(mei[randint(0, len(mei))] + "_" + sei[randint(0, len(sei))])
    return names

