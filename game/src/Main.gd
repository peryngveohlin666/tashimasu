extends Node


var title_screen = load("res://scenes/ui/screens/TitleScreen.tscn").instance() # create an instance of the scene "title"
var login_screen = load("res://scenes/ui/screens/LoginScreen.tscn").instance()
var game_screen = load("res://scenes/game/Game.tscn").instance()
var lose_popup = load("res://scenes/ui/popup/LosePopup.tscn").instance()
var client : Node # the client code instance that is attached to this node
var error_popup : Node
var matchmaking_popup : Node
var win_popup : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(lose_popup)
	client = get_node("Client") # get the child node client and attach it to the variable client
	error_popup = get_node("ErrorPopup")
	matchmaking_popup = get_node("MatchmakingPopup")
	matchmaking_popup.popup_exclusive = true # stops the popup from disappearing when clicked outside of it
	add_child(login_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func switch_to_menu_from_login_screen():
	remove_child(login_screen)
	add_child(title_screen)
	
func switch_to_menu():
	add_child(title_screen)
	
func show_error_popup():
	error_popup.popup_centered(Vector2( 150, 150 ) )
	
func switch_to_game():
	remove_child(title_screen)
	add_child(game_screen)
	
func show_matchmaking_popup():
	matchmaking_popup.popup_centered(Vector2( 150, 150 ) )
	
func hide_matchmaking_popup():
	matchmaking_popup.hide()
	
func won_game(earned_card):
	win_popup = load("res://scenes/ui/popup/WinPopup.tscn").instance()
	win_popup.init(earned_card)
	remove_child(game_screen)
	add_child(title_screen)
	add_child(win_popup)
	win_popup.popup_centered(Vector2( 150, 150 ) )
	game_screen = load("res://scenes/game/Game.tscn").instance()
	
func lost_game():
	remove_child(game_screen)
	add_child(title_screen)
	lose_popup.popup_centered(Vector2( 150, 150 ) )
	game_screen = load("res://scenes/game/Game.tscn").instance()
