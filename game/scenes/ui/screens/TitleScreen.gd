extends Control

var title_screen : Node
var main_screen : Node
var client : Node

func _ready():
	title_screen = get_node(".")
	main_screen = title_screen.get_parent()
	client = main_screen.get_node("Client")
	var exit_button = get_node("Menu/CenterRow/Buttons/ExitButton")
	var matchmake_button = get_node("Menu/CenterRow/Buttons/MatchmakeButton")
	var deck_maker_button = get_node("Menu/CenterRow/Buttons/DeckMakerButton")
	exit_button.connect("pressed", self, "_on_exit_pressed")
	matchmake_button.connect("pressed", self, "_on_matchmake_pressed")
	deck_maker_button.connect("pressed", self, "_on_deckmaker_pressed")

func _on_exit_pressed():
	get_tree().quit()	

func _on_deckmaker_pressed():
	get_parent().get_node("Client").request_cards()

func switch_to_deckmaker(cards):
	main_screen.remove_child(title_screen)
	var deckmaker_screen = load("res://scenes/game/DeckMaker.tscn").instance()
	deckmaker_screen.cards = cards
	main_screen.add_child(deckmaker_screen)
	
func _on_matchmake_pressed():
	client.matchmake()
	main_screen.show_matchmaking_popup()

