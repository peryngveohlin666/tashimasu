extends Node2D


const card = preload("res://scenes/game/Card.tscn")
const card_scale = Vector2(0.75, 0.75)

const card_slot = preload("res://scenes/game/CardSlot.tscn")

# gui stuff that tracks our health, enemy health and if it is our turn
var health = 40
var enemy_health = 40
var mana = 0
var enemy_mana = 0
var current_mana = 0
var enemy_current_mana = 1
var my_turn : bool = true

# cards on places and the deck size
var hand : Array
var table : Array
var enemy_table : Array
var deck_size : int = 40
var enemy_deck_size : int = 40
var friendly_slots = []
var enemy_slots = []

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
	for i in 5:
		var new_friendly_slot = card_slot.instance()
		new_friendly_slot.rect_position = Vector2(200 + 250 * i, 550)
		new_friendly_slot.get_child(0).color =  Color (0, 100, 200, 100)
		friendly_slots.append(new_friendly_slot)
		add_child(new_friendly_slot)
	for i in 5:
		var new_enemy_slot = card_slot.instance()
		new_enemy_slot.rect_position = Vector2(200 + 250 * i, 250)
		new_enemy_slot.enemy_slot = true
		enemy_slots.append(new_enemy_slot)
		add_child(new_enemy_slot)

# there was no other way to move the enum from Card.gd here
enum {
	in_hand,
	on_table,
	under_mouse,
	focused_in_hand,
	move_to_hand,
	reorganise_hand,
	in_attack
}

func draw_a_card(cardname : String):
		card_angle = PI/2 + between_cards*(len(hand)/2 - len(hand))
		var new_card = card.instance()
		# resize card
		new_card.rect_scale = card_scale
		new_card.init(cardname) # initialize the cards attributes from the name
		new_card.rect_position = $Deck.position # to stop clipping
		# set the target and the start position for animating card draw also the state
		new_card.target_position = hand_location + Vector2(hand_horizontal_radius * cos(card_angle), -hand_vertical_radius * sin(card_angle))
		new_card.default_position = new_card.target_position
		new_card.start_position = $Deck.position
		new_card.state = move_to_hand
		# set the rotation
		new_card.start_rotation = 0
		new_card.target_rotation = (90 - rad2deg(card_angle))/4
		new_card.default_rotation = new_card.target_rotation
		# add card to the list of cards in my hand
		hand.append(new_card)
		new_card.card_no = len(hand) # set the card no to the size of hand
		# reorganise the hand according to the card
		reorganise_hand()
		# render card
		add_child(new_card)
		deck_size -= 1
		# update the deck size
		$Deck/ColorRect/CenterContainer/CardCount.text = str(deck_size)
		
func reorganise_hand():
	card_no = 0
	for ca in hand: # reorganize
		card_angle = PI/2 + between_cards*(len(hand)/2 - card_no)
		ca.target_position = hand_location + Vector2(hand_horizontal_radius * cos(card_angle), -hand_vertical_radius * sin(card_angle))
		ca.default_position = ca.target_position
		# set the rotation
		ca.start_rotation = 0
		ca.target_rotation = (90 - rad2deg(card_angle))/4
		ca.default_rotation = ca.target_rotation
		card_no += 1
		ca.card_no = card_no # set the index of the card
		if ca.state == in_hand:
			ca.state = reorganise_hand
			ca.start_position = ca.rect_position
		elif ca.state == move_to_hand:
			# fix the jittering by teleporting the card secretly
			ca.start_position = ca.target_position - (ca.target_position - ca.rect_position/(1-ca.time))
			
func enemy_draw_a_card():
	enemy_deck_size -=1
	$EnemyDeck/EnemyCardCount.text = str(enemy_deck_size)

# one up for mana and enemy mana
func add_mana():
	mana += 1
	current_mana = mana
	update_mana_text(str(current_mana))

func add_enemy_mana():
	enemy_mana += 1
	enemy_current_mana = enemy_mana
	update_enemy_mana_text(str(enemy_current_mana))
	
func update_mana_text(mana_text : String):
	$Mana/ManaCount.text = mana_text

func update_enemy_mana_text(mana_text : String):
	$EnemyMana/EnemyManaCount.text = mana_text
	
func update_turn_info(mt : bool):
	my_turn = mt
	# enable clicking if my turn and update the text
	if my_turn:
		$Turn/SkipButton.text = "End Turn"
		$Turn/SkipButton.disabled = false
		add_mana()
	else:
		# disable clicking disable change text to enemy turn
		$Turn/SkipButton.text = "Enemy Turn"
		$Turn/SkipButton.disabled = true
		add_enemy_mana()
	for ca in table:
		ca.attacked = false
	for e_ca in enemy_table:
		e_ca.attacked = false	
		
func take_damage(damage : int):
	health -= damage
	$Deck/Health.text = str(health)
	
func hit_enemy(damage : int):
	enemy_health -= damage
	$EnemyDeck/EnemyHealth.text = str(enemy_health)

func _on_SkipButton_button_down() -> void:
	get_parent().get_node("Client").send_message(get_parent().get_node("Client").END_TURN_MESSAGE)
	print(get_parent().get_node("Client").END_TURN_MESSAGE)

# play an enemy card
func play_enemy_card(card_name : String):
	if len(enemy_table) <= 4:
		print("play enemy")
		var new_card = card.instance()
		# resize card
		new_card.rect_scale = card_scale
		new_card.init(card_name) # initialize the cards attributes from the name
		new_card.rect_position = get_node("EnemyHead").position
		new_card.default_position = new_card.rect_position
		new_card.enemy_card = true
		for slot in enemy_slots:
			if slot.is_empty:
				new_card.start_position = get_node("EnemyHead").position
				new_card.target_position = slot.rect_position
				slot.is_empty = false
				new_card.slot = slot
				new_card.moving_to_table = true
				enemy_current_mana -= new_card.cost
				update_enemy_mana_text(str(enemy_current_mana))
				break
		new_card.setup = true
		enemy_table.append(new_card)
		new_card.state = on_table
		
		enemy_current_mana -= new_card.cost
	
		add_child(new_card)

func enemy_attack(enemy_card_name : String, player_card_name : String):
	var player_card # player card
	var enemy_card # enemy card
	# find the player card from the string
	for pc in table:
		if pc.file_name == player_card_name:
			player_card = pc
			print(pc.file_name)
			break
	# do the same for the enemy card
	for ec in enemy_table:
		if ec.file_name == enemy_card_name:
			enemy_card = ec
			print("enemy")
			print(ec.file_name)
			break
	if player_card && enemy_card:
		enemy_card.last_attacked = player_card
		# set the state and animation variables for the attack animation
		enemy_card.setup = true
		enemy_card.previous_position = enemy_card.rect_position
		enemy_card.state = in_attack
		enemy_card.on_the_way = true
		enemy_card.target_position = player_card.rect_position
		
func enemy_attack_head(enemy_card_name : String):
	var enemy_card
	for ec in enemy_table:
		if ec.file_name == enemy_card_name:
			enemy_card = ec
			print("enemy")
			print(ec.file_name)
			break
	if enemy_card:
		enemy_card.setup = true
		enemy_card.previous_position = enemy_card.rect_position
		enemy_card.state = in_attack
		enemy_card.on_the_way = true
		enemy_card.target_position = Vector2 (1688, 744)
		take_damage(enemy_card.attack)
