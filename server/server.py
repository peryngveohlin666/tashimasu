import asyncio, websockets, ssl

IP = "localhost"
PORT = 6565

SEPERATOR = ":"    # seperate the protocol level messages like LOGIN and the data that comes with them
DATA_SEPERATOR = ","    # seperate the data sent alongside with a message

LOGIN_MESSAGE = "LOGIN"


ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
ssl_context.load_cert_chain('cert/tashimasu.crt', 'cert/tashimasu.key')


def handle_message(message):
    if message == "connected":
        response = "ayyyyyyyy"
    else:
        response = f"h{message}"

    return response


def login(username, password):
    if username == password:
        return True
    return False


protocol_to_function = {
        "LOGIN": login
    }


async def respond(websocket, path):
    i = 0 # this information is different for each client
    try:
        async for message in websocket:
            i+=1
            message = message.decode('UTF-8')
            response = handle_message(message)
            response = str(i)
            print(message)
            await websocket.send(response)
    except:
        print("an error occured")
    finally:
        print(f"disconnected unresponsive socket {websocket}")

start_server = websockets.serve(respond, IP, PORT)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()