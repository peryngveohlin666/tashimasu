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

from keras.models import load_model
from keras.preprocessing.image import array_to_img
import numpy as np
import name_generator
from random import randint

# type of the card (these don't matter at the moment)
types = ["Wild", "Cool", "Cute", "Big", "Small"]

# load the model
model = load_model('generator_model.h5', compile=False)


# n determines how many cards you want to generate
def generate_cards(n=1):

    def generate_attribute():
        # luck of the attribute
        luck = randint(1, 100)

        # max of the attribute
        max = randint(1, 20)

        # min of the attribute
        min = randint(1, 5)

        if min > max:
            max = min

        if luck == 100:
            # n of the attribute (the multiplier)
            n = randint(4, 6)
            min+=1
            max+=1
        elif luck < 100:
            n = randint(2, 5)
        elif luck < 60:
            n = randint(1, 4)
        elif luck < 30:
            n = randint(1, 3)
        else:
            n = randint(1, 2)

        attribute = n * randint(min, max)

        return attribute

    for i in range(n):
        # create some noise for the pic
        noise = np.random.normal(0, 1, (1, 100))
        # create an image using the noise as the input
        gen_imgs = model.predict(noise)
        for image in gen_imgs:
            img = array_to_img(image)
            health = generate_attribute()
            damage = generate_attribute()
            name = name_generator.generate_names(n=1)[0]
            type = types[randint(0, len(types) - 1)]
            cost = int((health + damage) / randint(2, 3))
            img.save("output/" + type + "_" + name + "_" + str(health)
                     + "_" + str(damage) + "_" + str(cost) + ".png")


generate_cards(n=20)
