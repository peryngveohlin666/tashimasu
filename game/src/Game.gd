extends Node2D


const card = preload("res://scenes/game/Card.tscn")
const card_scale = Vector2(0.75, 0.75)

# cards on places and the deck size
var hand : Array
var table : Array
var enemy_table : Array
var deck_size : int = 40

# angle between each card
var between_cards = 0.15
# card no in the deck
var card_no = 0

# where the hand is located
var hand_location = Vector2(700, 1250)
var hand_horizontal_radius = 960
var hand_vertical_radius = 430
var card_angle = deg2rad(90) + 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# there was no other way to move the enum from Card.gd here
enum {
	in_hand,
	on_table,
	under_mouse,
	focused_in_hand,
	move_to_hand,
	reorganise_hand
}

func _input(event):
	if Input.is_action_just_released("leftclick"):
		draw_a_card("Big_Arei_Yanagi_21_12_11.png")

func draw_a_card(cardname : String):
		card_angle = PI/2 + between_cards*(len(hand)/2 - len(hand))
		var new_card = card.instance()
		new_card.init(cardname) # initialize the cards attributes from the name
		new_card.rect_position = $Deck.position # to stop clipping
		# set the target and the start position for animating card draw also the state
		new_card.target_position = hand_location + Vector2(hand_horizontal_radius * cos(card_angle), -hand_vertical_radius * sin(card_angle))
		new_card.start_position = $Deck.position
		new_card.state = move_to_hand
		# set the rotation
		new_card.start_rotation = 0
		new_card.target_rotation = (90 - rad2deg(card_angle))/4
		# add card to the list of cards in my hand
		hand.append(new_card)
		# resize card
		new_card.rect_scale = card_scale
		# reorganise the hand according to the card
		_reorganise_hand()
		# render card
		add_child(new_card)
		deck_size -= 1
		# update the deck size
		$Deck/ColorRect/CenterContainer/CardCount.text = str(deck_size)
		
func _reorganise_hand():
	card_no = 0
	for ca in hand: # reorganize
		card_angle = PI/2 + between_cards*(len(hand)/2 - card_no)
		ca.target_position = hand_location + Vector2(hand_horizontal_radius * cos(card_angle), -hand_vertical_radius * sin(card_angle))
		# set the rotation
		ca.start_rotation = 0
		ca.target_rotation = (90 - rad2deg(card_angle))/4
		card_no += 1
		if ca.state == in_hand:
			ca.state = reorganise_hand
			ca.start_position = ca.rect_position
		elif ca.state == move_to_hand:
			# fix the jittering by teleporting the card secretly
			ca.start_position = ca.target_position - (ca.target_position - ca.rect_position/(1-ca.time))
			
