extends Node

# port and the url (for now some random port on my localhost)
const PORT: int = 6565
const URL: String = "wss://localhost:%s" % PORT

# protocol level seperator and the data seperator
const SEPERATOR: String = ":"
const DATA_SEPERATOR: String = ","

# protocol level login message
const LOGIN_MESSAGE: String = "LOGIN"

var client: WebSocketClient
var cert : X509Certificate

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
	
# a function to send message to the server
func send_message(message: String) -> void:
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	
# a function to log in
func login(username: String, password: String):
	send_message(LOGIN_MESSAGE + SEPERATOR + str(len(username)) + 
	DATA_SEPERATOR + str(len(password)) + DATA_SEPERATOR + username + DATA_SEPERATOR + password)
