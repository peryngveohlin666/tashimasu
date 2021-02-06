extends Control

func _ready():
	var exit_button = get_node("Menu/CenterRow/Buttons/ExitButton")
	var matchmake_button = get_node("Menu/CenterRow/Buttons/MatchmakeButton")
	var deck_maker_button = get_node("Menu/CenterRow/Buttons/DeckMakerButton")
	exit_button.connect("pressed", self, "_on_exit_pressed")
	matchmake_button.connect("pressed", self, "_on_matchmake_pressed")
	deck_maker_button.connect("pressed", self, "_on_deckmaker_pressed")

func _on_exit_pressed():
	get_tree().quit()	

func _on_deckmaker_pressed():
	var title_screen = get_node(".")
	var main_screen = title_screen.get_parent()
	main_screen.remove_child(title_screen)
	var deckmaker_screen = load("res://scenes/game/DeckMaker.tscn").instance()
	main_screen.add_child(deckmaker_screen)
