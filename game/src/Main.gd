extends Node


var title_screen = load("res://scenes/ui/screens/TitleScreen.tscn").instance() # create an instance of the scene "title"
var login_screen = load("res://scenes/ui/screens/LoginScreen.tscn").instance()
var game_screen = load("res://scenes/game/Game.tscn")
var client : Node # the client code instance that is attached to this node
var error_popup : Node
var my_turn : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	client = get_node("Client") # get the child node client and attach it to the variable client
	error_popup = get_node("ErrorPopup")
	add_child(login_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func switch_to_menu_from_login_screen():
	remove_child(login_screen)
	add_child(title_screen)
	
func show_error_popup():
	error_popup.popup_centered(Vector2( 150, 150 ) )
	
func switch_to_game():
	remove_child(title_screen)
	add_child(game_screen)
