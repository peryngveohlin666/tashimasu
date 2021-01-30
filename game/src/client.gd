extends Node

const PORT: int = 6565
const URL: String = "ws://localhost:%s" % PORT

var client: WebSocketClient
var cert : X509Certificate

func _ready():
	# cert.load("res://cert/tashimasu.crt")
	client = WebSocketClient.new()
	# client.set_trusted_ssl_certificate(cert)
	
	client.connect_to_url(URL)
	
	client.connect("data_received", self, "_on_received_data")
	client.connect("connection_established", self, "_on_connected")
	

func _process(delta):
	client.poll()

func _on_connected(_protocol: String) -> void:
	print("Connected")
	var message: String = "Boi"
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	
func _on_received_data() -> void:
	print("Received data")
	var packet: PoolByteArray = client.get_peer(1).get_packet()
	var parsed_data: String = packet.get_string_from_utf8()
	print(packet)
