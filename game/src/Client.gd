extends Node

# port and the url (for now some random port on my localhost)
const PORT: int = 6565
const URL: String = "wss://localhost:%s" % PORT

# protocol level seperator and the data seperator
const SEPERATOR: String = ":"
const DATA_SEPERATOR: String = ","

# protocol level login message
const LOGIN_MESSAGE: String = "LOGIN"

# protocol level register message
const REGISTER_MESSAGE: String = "REGISTER"

# protocol level success login response
const SUCCESS_LOGIN_RESPONSE: String = "SUCCESS_LOGIN"

const ERROR_MESSAGE = "ERROR" # a generic error message

const MATCHMAKE_MESSAGE: String = "MATCHMAKE" # matchmake message

const GAME_FOUND_MESSAGE: String = "GAMEFOUND"  # game found message, add enemy username, whose turn it is

const ENEMY_TURN_MESSAGE: String = "ENEMYTURN"

const YOUR_TURN_MESSAGE: String = "YOURTURN"

const DRAW_A_CARD_MESSAGE: String = "DRAW"

const PLAY_A_CARD_MESSAGE: String = "PLAY"

const ENEMY_PLAY_MESSAGE: String = "ENEMYPLAY"

const END_TURN_MESSAGE: String = "ENDTURN"

const ATTACK_MESSAGE: String = "ATTACK"

const GET_ATTACKED_MESSAGE: String = "GETATTACKED"

const ATTACK_HEAD_MESSAGE: String = "ATTACKHEAD"

const GET_ATTACKED_ON_THE_HEAD_MESSAGE: String = "ATTACKEDHEAD"

const REQUEST_CARDS_MESSAGE: String = "REQUESTCARDS"

const CARDS_MESSAGE: String = "CARDS"

const REQUEST_DECK_MESSAGE: String = "SENDDECK"

const RESPOND_DECK_MESSAGE: String = "TAKEDECK"

const UPDATE_DECK_MESSAGE: String = "UPDATEDECK"

const WON_GAME_MESSAGE: String = "WON"

const LOST_GAME_MESSAGE: String = "LOST"


var client: WebSocketClient
var cert : X509Certificate

var auth_token: String

# a boolean variable to check if the first turn message is sent
var first_turn_message_sent: bool = false

func _ready():
	
	# load the certificate
	cert = X509Certificate.new()
	cert.load("res://cert/tashimasu.crt")
	
	# set the certificate but don't check it with a CA as I don't want to pay for that
	client = WebSocketClient.new()
	client.set_trusted_ssl_certificate(cert)
	client.set_verify_ssl_enabled(false)
	
	# connect to the server
	client.connect_to_url(URL)
	
	# set the data received and connection established functions
	client.connect("data_received", self, "_on_received_data")
	client.connect("connection_established", self, "_on_connected")
	
# poll the network data on every update
func _process(delta):
	client.poll()

# do when first connected to the server
func _on_connected(_protocol: String) -> void:
	print("Connected")
	
# do when whenever data is received
func _on_received_data() -> void:
	print("Received data")
	var packet: PoolByteArray = client.get_peer(1).get_packet()
	var parsed_data: String = packet.get_string_from_utf8()
	print(parsed_data)
	# ree godot doesn't have a switch-case statement this is stupid
	if(_get_protocol_message(parsed_data) == SUCCESS_LOGIN_RESPONSE):
		auth_token = _get_data(parsed_data)[0]
		get_parent().switch_to_menu_from_login_screen()
	if(_get_protocol_message(parsed_data) == ERROR_MESSAGE):
		get_parent().show_error_popup()
	if(_get_protocol_message(parsed_data) == GAME_FOUND_MESSAGE):
		get_parent().switch_to_game()
		get_parent().hide_matchmaking_popup()
	if(_get_protocol_message(parsed_data) == YOUR_TURN_MESSAGE):
		get_parent().get_node("./Game").update_turn_info(true)
		first_turn_message_sent = true
	if(_get_protocol_message(parsed_data) == ENEMY_TURN_MESSAGE):
		get_parent().get_node("./Game").update_turn_info(false)
		if first_turn_message_sent:
			get_parent().get_node("./Game").enemy_draw_a_card()
		first_turn_message_sent = true
	if(_get_protocol_message(parsed_data) == DRAW_A_CARD_MESSAGE):
		get_parent().get_node("./Game").draw_a_card(_get_data(parsed_data)[0])
	if(_get_protocol_message(parsed_data) == ENEMY_PLAY_MESSAGE):
		print(_get_data(parsed_data)[0])
		get_parent().get_node("./Game").play_enemy_card(_get_data(parsed_data)[0])
	if(_get_protocol_message(parsed_data) == GET_ATTACKED_MESSAGE):
		get_parent().get_node("./Game").enemy_attack(_get_data(parsed_data)[0], _get_data(parsed_data)[1])
		print(_get_data(parsed_data)[1])
		print(_get_data(parsed_data)[0])
	if(_get_protocol_message(parsed_data) == GET_ATTACKED_ON_THE_HEAD_MESSAGE):
		get_parent().get_node("./Game").enemy_attack_head(_get_data(parsed_data)[0])
	if(_get_protocol_message(parsed_data) == CARDS_MESSAGE):
		get_parent().get_node("TitleScreen").switch_to_deckmaker(_get_data(parsed_data))
	if(_get_protocol_message(parsed_data) == RESPOND_DECK_MESSAGE):
		get_deck(parsed_data)
	if(_get_protocol_message(parsed_data) == WON_GAME_MESSAGE):
		var data = _get_data(parsed_data)[0]
		get_parent().won_game(data)
	if(_get_protocol_message(parsed_data) == LOST_GAME_MESSAGE):
		get_parent().lost_game()

	
# a function to send message to the server
func send_message(message: String) -> void:
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	
func play_a_card(card_name: String) -> void:
	send_message(PLAY_A_CARD_MESSAGE + SEPERATOR + card_name)
	
func attack_to_a_card(attacking_card: String, attacked_card: String):
	send_message(ATTACK_MESSAGE + SEPERATOR + attacking_card + DATA_SEPERATOR + attacked_card)
	
# a function to log in
func login(username: String, password: String):
	send_message(LOGIN_MESSAGE + SEPERATOR + str(len(username)) + 
	DATA_SEPERATOR + str(len(password)) + DATA_SEPERATOR + username + DATA_SEPERATOR + password)
	
# a function to register
func register(username: String, password: String):
	send_message(REGISTER_MESSAGE + SEPERATOR + str(len(username)) + 
	DATA_SEPERATOR + str(len(password)) + DATA_SEPERATOR + username + DATA_SEPERATOR + password)
	
func attack_enemy_head(card_name : String):
	send_message(ATTACK_HEAD_MESSAGE + SEPERATOR + card_name)
	
func request_cards():
	send_message(REQUEST_CARDS_MESSAGE)
	
func request_deck():
	send_message(REQUEST_DECK_MESSAGE)
	print("requested")
	
func get_deck(message: String):
	print("gotem")
	var n = len(get_parent().get_children())
	get_parent().get_child(n - 1).set_deck(_get_data(message))
	
func update_deck(cards: String):
	send_message(UPDATE_DECK_MESSAGE + SEPERATOR + cards)
	
# a function to get the protocol level message	
func _get_protocol_message(message: String) -> String:
	if SEPERATOR in message:
		return message.split(SEPERATOR)[0]
	else: 
		return message
	
# a function to get the data
func _get_data(message: String) -> PoolStringArray:
	if SEPERATOR in message:
		if DATA_SEPERATOR in message:
			return message.split(SEPERATOR)[1].split(DATA_SEPERATOR)
		else:
			return PoolStringArray([message.split(SEPERATOR)[1]])
	# thanks godot, for not having try, catch
	return PoolStringArray(["not an", "error"])
	
func matchmake():
	send_message(MATCHMAKE_MESSAGE)
