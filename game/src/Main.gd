extends Node


var logged_in :bool # to check if the player is logged in
var login_screen = load("res://scenes/ui/Login.tscn").instance() # create an instance of the scene "login screen"
var client : Node # the client code instance that is attached to this node

# Called when the node enters the scene tree for the first time.
func _ready():
	client = get_node("Client") # get the child node client and attach it to the variable client
	logged_in = false
	add_child(login_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	client.register("mert", "123")
	client.login("mert", "123")
