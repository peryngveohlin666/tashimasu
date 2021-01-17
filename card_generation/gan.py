from keras.layers import Input, Dense, Reshape, Flatten
from keras.layers import BatchNormalization
from keras.layers.advanced_activations import LeakyReLU
from keras.models import Sequential, Model
from keras.optimizers import Adam
import numpy as np
import dataset as ds
from keras.preprocessing.image import array_to_img

img_rows = 512
img_cols = 512
channels = 3
img_shape = (img_rows, img_cols, channels)


def build_generator():
    noise_shape = (100,)  # 1D array of size 100 (latent vector / noise)

    model = Sequential()

    model.add(Dense(64, input_shape=noise_shape))
    model.add(LeakyReLU(alpha=0.2))
    model.add(BatchNormalization(momentum=0.8))

    model.add(Dense(128))
    model.add(LeakyReLU(alpha=0.2))
    model.add(BatchNormalization(momentum=0.8))

    model.add(Dense(128))
    model.add(LeakyReLU(alpha=0.2))
    model.add(BatchNormalization(momentum=0.8))

    model.add(Dense(256))
    model.add(LeakyReLU(alpha=0.2))
    model.add(BatchNormalization(momentum=0.8))

    model.add(Dense(256))
    model.add(LeakyReLU(alpha=0.2))
    model.add(BatchNormalization(momentum=0.8))

    model.add(Dense(np.prod(img_shape), activation='tanh'))
    model.add(Reshape(img_shape))

    model.summary()

    noise = Input(shape=noise_shape)
    img = model(noise)  # Generated image

    return Model(noise, img)


def build_discriminator():
    model = Sequential()

    model.add(Flatten(input_shape=img_shape))
    model.add(Dense(256))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(128))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(128))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(512))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(1, activation='sigmoid'))

    model.summary()

    img = Input(shape=img_shape)
    validity = model(img)

    return Model(img, validity)


def train(epochs, batch_size=128, save_interval=50, ds_begin=0, ds_end=1600, threads=16):
    # Load the dataset
    X_train = ds.load_dataset(ds_begin, ds_end, threads)[0]

    # Convert to float and Rescale -1 to 1 (Can also do 0 to 1)
    X_train = (X_train.astype(np.float32) - 127.5) / 127.5

    half_batch = int(batch_size / 2)

    for epoch in range(epochs):


        idx = np.random.randint(0, X_train.shape[0], half_batch)
        imgs = X_train[idx]

        noise = np.random.normal(0, 1, (half_batch, 100))

        gen_imgs = generator.predict(noise)

        d_loss_real = discriminator.train_on_batch(imgs, np.ones((half_batch, 1)))
        d_loss_fake = discriminator.train_on_batch(gen_imgs, np.zeros((half_batch, 1)))

        d_loss = 0.5 * np.add(d_loss_real, d_loss_fake)

        noise = np.random.normal(0, 1, (batch_size, 100))

        valid_y = np.array([1] * batch_size)

        g_loss = combined.train_on_batch(noise, valid_y)

        print("%d [D loss: %f, acc.: %.2f%%] [G loss: %f]" % (epoch, d_loss[0], 100 * d_loss[1], g_loss))

        if epoch % save_interval == 0:
            save_imgs(epoch, "" + str(ds_begin) + "-" + str(ds_end))


def save_imgs(epoch, ds):
    noise = np.random.normal(0, 1, (1, 100))
    gen_imgs = generator.predict(noise)
    for image in gen_imgs:
        img = array_to_img(image)
        img.save("output/" + ds + "_anime_" + str(epoch) + ".png")


optimizer = Adam(0.0002, 0.5)

discriminator = build_discriminator()
discriminator.compile(loss='binary_crossentropy',
                      optimizer=optimizer,
                      metrics=['accuracy'])

generator = build_generator()
generator.compile(loss='binary_crossentropy', optimizer=optimizer)


z = Input(shape=(100,))
img = generator(z)


discriminator.trainable = False


valid = discriminator(img)

combined = Model(z, valid)
combined.compile(loss='binary_crossentropy', optimizer=optimizer)

for i in range(0, 140000, 64):
    train(epochs=100, batch_size=64, save_interval=50, ds_begin=i, ds_end=i+64)
    generator.save('generator_model.h5')
