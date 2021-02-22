extends Node2D

const card = preload("res://scenes/game/Card.tscn")

var cards # cards as their string names
var card_objects = []

var deck # selected cards as string names

var selected_cards = []

var first_card_loc = Vector2(-225 + (1 * 350), (1 * 400) - 350)

var last_card_loc : Vector2

var camera_move = 50

var top_bottom_gaps = 100

var previous_camera_position = Vector2(960, 500)

var camera

enum {
	in_hand,
	on_table,
	under_mouse,
	focused_in_hand,
	move_to_hand,
	reorganise_hand,
	in_attack
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_cards()
	camera = get_node("Camera2D")
	camera.position = Vector2(960, 500)
	get_parent().get_node("Client").request_deck()

func _initialize_cards():
	var i = 1
	var j = 0
	for c in cards:
		j+= 1
		_initialize_a_card(Vector2(-225 + (j * 350), (i * 400) - 350), c)
		if j % 5 == 0:
			i+= 1
			j = 0
		last_card_loc = Vector2(-225 + (j * 350), (i * 400) - 350)

func _initialize_a_card(n_position : Vector2, card_name : String):
	var new_card = card.instance()
	new_card.init(card_name)
	new_card.rect_position = n_position
	new_card.target_position = n_position
	new_card.default_position = n_position
	new_card.state = on_table
	new_card.start_rotation = 0
	new_card.target_rotation = 0
	new_card.on_deck_maker = true
	card_objects.append(new_card)
	add_child(new_card)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scrolldown"):
		previous_camera_position = camera.position
		get_node("Camera2D").position.y += camera_move
	if event.is_action_pressed("scrollup"):
		previous_camera_position = camera.position
		get_node("Camera2D").position.y -= camera_move
	if camera.position.y <= first_card_loc.y + top_bottom_gaps:
		camera.position.y = previous_camera_position.y
	if camera.position.y >= last_card_loc.y - top_bottom_gaps:
		camera.position.y = previous_camera_position.y
	
func set_deck (de):
	deck = de
	for c in card_objects:
		print(c)
		for d in deck:
			if c.file_name == d:
				c.set_selected()
					

func update_card_count_label(n : int):
	get_node("CardCount").text = str(n) + "/40"

func _on_Submit_pressed() -> void:
	var n_cards = ""
	if len(selected_cards) == 40:
		for c in selected_cards:
			n_cards += c.file_name + ","
		n_cards.erase(n_cards.length() - 1, 1)
		get_parent().get_node("Client").update_deck(n_cards)
	get_parent().switch_to_menu()
	get_parent().remove_child($".")
