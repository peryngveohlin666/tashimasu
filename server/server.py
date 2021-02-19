import asyncio, websockets, ssl
import os
import random
import string
import bcrypt
import concurrent.futures
import Player

import pymongo
from pymongo import MongoClient

uri = open("uri.txt").read()  # the uri that stores the username and password don't want this in my repo
# something like this mongodb+srv://spike:<password>@tashimasucluster.hxyyh.mongodb.net/<dbname>?retryWrites=true&w=majority

# our database cluster (we only have one since we don't really store that much information)
cluster = MongoClient(uri)
db = cluster["tashimasu"]  # select the cluster
collection = db["tashimasu"]  # select the collection

# ip and port the server is running at
IP = "localhost"
PORT = 6565
# password pepper
PEPPER = "coolpepperbro"

SEPERATOR = ":"  # seperate the protocol level messages like LOGIN and the data that comes with them

DATA_SEPERATOR = ","  # seperate the data sent alongside with a message

# protocol messages here

LOGIN_MESSAGE = "LOGIN"  # a message that the client sends when they try to log in

REGISTER_MESSAGE = "REGISTER"  # a message that the client sends to register

LOGIN_RESPONSE = "SUCCESSFUL_LOGIN"  # a message that the client receives when the login is successfull

SUCCESS_RESPONSE = "SUCCESS"  # a generic message that indicates that the latest event was successfull

SUCCESS_LOGIN_RESPONSE = "SUCCESS_LOGIN" # a generic message that indicates the login was successfull

ERROR_MESSAGE = "ERROR"  # a generic error message

MATCHMAKE_MESSAGE = "MATCHMAKE"  # matchmake message

GAME_FOUND_MESSAGE = "GAMEFOUND"  # game found message, add enemy username, whose turn it is

YOUR_TURN_MESSAGE = "YOURTURN"  # YUGIOH BABY

ENEMY_TURN_MESSAGE = "ENEMYTURN"  # ummm

DRAW_A_CARD_MESSAGE = "DRAW"

PLAY_A_CARD_MESSAGE = "PLAY"  # play a card message a seperator and the card that the player is playing

ENEMY_PLAY_MESSAGE = "ENEMYPLAY"  # when the enemy plays a card send this message to the other client to notify

END_TURN_MESSAGE = "ENDTURN"

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain('cert/tashimasu.crt', 'cert/tashimasu.key')

# keep track of the logged in users.
logged_in_users = []

# a list of currently matchmaking users
matchmaking_users = []



# get a message as a parameter and return an authentication key
def login(message):
    # get the message data from the seperated data
    message_data = get_data(message)

    # username and password lenghts for validation
    username_length = message_data[0]
    password_length = message_data[1]

    username = message_data[2]
    password = message_data[3]

    if (len(username) == int(username_length)) and (len(password) == int(password_length)):
        result = collection.find_one({"username": username})
        if not result:
            return ERROR_MESSAGE, ""

        password_salt = result["password_salt"]
        print(password_salt)

        password_hash = bcrypt.hashpw((PEPPER + password).encode("utf-8"), password_salt)

        if password_hash == result["password_hash"]:
            if username in logged_in_users:
                return ERROR_MESSAGE, ""
            logged_in_users.append(username)
            return (SUCCESS_LOGIN_RESPONSE + SEPERATOR + generate_random_string(), username)

    return ERROR_MESSAGE, ""


def register(message):
    message_data = get_data(message)
    print(message)

    username_length = message_data[0]
    password_length = message_data[1]

    username = message_data[2]
    password = message_data[3]

    password_salt = bcrypt.gensalt()

    password_hash = bcrypt.hashpw((PEPPER + password).encode("utf-8"), password_salt)

    cards = get_starter_cards()

    if (len(username) == int(username_length)) and (len(password) == int(password_length)):
        results = collection.find({"username": username})
        if results.count() > 0:
            return ERROR_MESSAGE

        collection.insert_one(
            {"username": username, "password_hash": password_hash, "password_salt": password_salt, "cards": cards,
             "deck": cards})
        return (SUCCESS_RESPONSE)

    return ERROR_MESSAGE


# get the starter cards from the starter directory to register users with a starter deck
def get_starter_cards():
    cards = os.listdir("starter_cards")
    out = ""
    for card in cards:
        out += str(card) + ","
    out = out[:-1]
    return out

# a function to constantly pair players who are matchmaking
async def matchmake():
    print("matchmake")
    print(matchmaking_users)
    while len(matchmaking_users) >= 2:
        p1 = matchmaking_users.pop(len(matchmaking_users) - 1)
        p2 = matchmaking_users.pop(len(matchmaking_users) - 1)
        for user in matchmaking_users:
            print(user.username)
        p1.set_enemy(p2)
        p2.set_enemy(p1)
        (p1_username, p1_socket) = p1.identifier
        (p2_username, p2_socket) = p2.identifier
        await p1_socket.send(GAME_FOUND_MESSAGE)
        await p2_socket.send(GAME_FOUND_MESSAGE)
        await p1_socket.send(YOUR_TURN_MESSAGE)
        await p2_socket.send(ENEMY_TURN_MESSAGE)

        # sleep for half a second to make sure that the players load the scene so that there won't be a load of commands going through slowing their computer down
        await asyncio.sleep(0.5)

        # draw cards for the players one
        for i in range(6):
            card = p1.draw_a_card()
            await p1_socket.send(DRAW_A_CARD_MESSAGE + SEPERATOR + card)
            if i <= 5:
                card2 = p2.draw_a_card()
                await p2_socket.send(DRAW_A_CARD_MESSAGE + SEPERATOR + card2)

        print(p2_username + p1_username)
    await asyncio.sleep(1) # matchmake every second
    asyncio.create_task(matchmake())


def generate_random_string():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=15))


# get the message before the seperator e.g. ATTACK, LOGIN
def get_protocol_message(message):
    return message.split(SEPERATOR)[0]


# get the data from separated values from the message
def get_data(message):
    return message.split(SEPERATOR)[1].split(DATA_SEPERATOR)


# get the deck of a user
def get_deck(username):
    result = collection.find_one({"username": username})
    return result["deck"].split(DATA_SEPERATOR)




# a dictionary to map protocol level messages to functions, some functions return multiple values so they are handled with if statements
protocol_to_function = {
    REGISTER_MESSAGE: register
}


async def respond(websocket, path):
    username = ""
    auth_key = ""

    player = Player.Player()

    try:
        async for message in websocket:
            message = message.decode('UTF-8')
            protocol_message = get_protocol_message(message)

            print(message)
            print(protocol_message)

            # reset the response
            response = ""

            if protocol_message == LOGIN_MESSAGE:
                response, un = login(message)
                if un != "":
                    username += un
                    auth_key += response.split(SEPERATOR)[1]
                    player.set_identifier((username, websocket)) # set the identifier of the player instance so that other enemies can communicate with us
            elif protocol_message == MATCHMAKE_MESSAGE:
                if player not in matchmaking_users:
                    player.assign_deck(get_deck(username))
                    print(player.deck)
                    matchmaking_users.append(player)
                else:
                    response = ERROR_MESSAGE
            elif protocol_message == PLAY_A_CARD_MESSAGE:
                card_name = get_data(message)[0]
                player.play_a_card(card_name)
                (enemy_username, enemy_socket) = player.enemy.identifier
                await enemy_socket.send(ENEMY_PLAY_MESSAGE + SEPERATOR + card_name)
            elif protocol_message == END_TURN_MESSAGE:
                (enemy_username, enemy_socket) = player.enemy.identifier
                await enemy_socket.send(YOUR_TURN_MESSAGE)
                await websocket.send(ENEMY_TURN_MESSAGE)
                player.mana += 1
                player.current_mana = player.mana
            else:
                # get the proper function for the incoming protocol code and pass the message through to the necessary function
                response = protocol_to_function[get_protocol_message(message)](message)


            print(response)
            print(message)

            if response != "":
                await websocket.send(response)
    finally:
        logged_in_users.remove(username)
        if username in matchmaking_users:
            matchmaking_users.remove(username)
        print(f"disconnected unresponsive socket {websocket}")


start_server = websockets.serve(respond, IP, PORT, ssl=ssl_context)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().create_task(matchmake()) # matchmake in the server
asyncio.get_event_loop().run_forever()
