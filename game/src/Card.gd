extends MarginContainer

# card attributes
var enemy_card = false
var file_name : String
var image_location : String
var card_type : String
var card_name : String
var attack : int
var defense : int
var cost : int

# attributes for animating etc.
var start_position
var target_position
var start_rotation
var target_rotation
var default_rotation
var start_scale = Vector2(0.75, 0.75)
var time = 0
const draw_time = 0.2
const reorganise_time = 0.15
var setup = true
var original_scale = Vector2()
var default_position = Vector2()
var zoom_scale = Vector2(1, 1)
var reorganize_neighbors = true
var card_in_hand_count = 0
var card_no = 0
var card_selected = true
var old_state
# check if the card is moving to table
var moving_to_table = false
# check which slot the card is put in
var slot
# check if we should draw the attack line
var attacking = false
# check if the mouse is inside the card
var mouse_is_inside = false
# the card we are attacking at
var attacking_at : Node
# check if the attack is on the way or on the way back
var on_the_way = false
# old position
var previous_position = Vector2()
# last attacked card
var last_attacked
# to check if the card attacked this round
var attacked = false

# card state
enum {
	in_hand,
	on_table,
	under_mouse,
	focused_in_hand,
	move_to_hand,
	reorganise_hand,
	in_attack
}

var state = in_hand

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# an init function to initialize values
func init(fn: String):
	self.file_name = fn # card name for the card
	initialize_attributes(file_name)
	# set the texture and the texture size
	$Artwork.texture = load(image_location)
	$Artwork.scale = Vector2 (0.4, 0.4)
	# set labels
	$TextContainer/TopBar/CostMargin/CenterContainer/Cost.text = "Cost: " + str(cost)
	$TextContainer/NameMargin/CenterContainer/Name.text = card_type + " " + card_name
	$TextContainer/BottomBar/DefenseMargin/CenterContainer/Defense.text = "Def: " + str(defense)
	$TextContainer/BottomBar/AttackMargin/CenterContainer/Attack.text = "Atk: " + str(attack)
	original_scale = rect_scale
	
# initialize the attributes after extracting them from the file name
func initialize_attributes(fn):
	self.image_location = "res://assets/cards/" + fn
	var attributes = fn.split(".")[0].split("_")
	self.card_type = attributes[0]
	self.card_name = attributes[1] + " " + attributes[2]
	self.defense = int(attributes[3])
	self.attack = int(attributes[4])
	self.cost = int(attributes[5])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		in_attack:
			if setup:
				setup()
			if on_the_way:
				if time <= 1:
					# slowly move the position
					rect_position = start_position.linear_interpolate(target_position, time)
					# slowly move the rotation
					rect_rotation = start_rotation * (1-time) + (target_rotation * time)
					time+=delta/0.25
				else:
					rect_position = target_position
					on_the_way = false
					setup = true
					time = 0
					if last_attacked:
						# kill the cards that need to die
						if last_attacked.defense < defense:
							last_attacked.die()
						if last_attacked.defense == defense:
							die()
							last_attacked.die()
						if last_attacked.defense > defense:
							die()
					last_attacked = null # just to avoid bugs bc i know this is going to happen
			elif on_the_way == false:
				target_position = previous_position
				if time <= 1:
					# slowly move the position
					rect_position = start_position.linear_interpolate(target_position, time)
					# slowly move the rotation
					rect_rotation = start_rotation * (1-time) + (target_rotation * time)
					time+=delta/0.25
				else:
					rect_position = target_position
					on_the_way = false
					time = 0
					state = on_table
		in_hand:
			pass
		on_table:
			if setup:
				setup()
			# move the card to the table
			if moving_to_table:
				start_position = rect_position
				target_position = slot.rect_position
				target_rotation = 0
				var target_scale = Vector2(0.75, 0.75)
				if time <= 1:
					# slowly move the position
					rect_position = start_position.linear_interpolate(target_position, time)
					# slowly move the rotation
					rect_rotation = start_rotation * (1-time) + (target_rotation * time)
					rect_scale = rect_scale * (1-time) + (target_scale * time)
					time+=delta/1
				else:
					rect_position = target_position
					rect_rotation = target_rotation
					rect_scale = target_scale
					time = 0
					moving_to_table = false
		under_mouse:
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(get_global_mouse_position() - rect_min_size/2, time)
				# slowly move the rotation
				rect_rotation = start_rotation * (1-time) + (0 * time)
				time+=delta/0.05
				print("under")
			else:
				rect_position = get_global_mouse_position() - rect_min_size/2
				rect_rotation = 0
		focused_in_hand:
			if setup:
				setup()
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(target_position, time)
				# slowly scale back
				rect_scale = start_scale * (1-time) + zoom_scale*time
				time+=delta/float(reorganise_time)
				if reorganize_neighbors:
					reorganize_neighbors = false
					print(card_no)
					card_in_hand_count = len($"../.".hand) - 1
					if card_no <= card_in_hand_count:
						move_neighbor_card(card_no, false, 1)
					if card_no +1 <= card_in_hand_count:
						move_neighbor_card(card_no +1, false, 0.25)
					if card_no -2 >= 0:
						move_neighbor_card(card_no -2, true, 1)
					if card_no -3 >= 0:
						move_neighbor_card(card_no -3, true, 0.25)
			else:
				rect_position = target_position
				rect_rotation = target_rotation
				rect_scale = zoom_scale
		# slowly move card to the hand interpolating the position and the rotation
		move_to_hand: # animate from the deck to hand
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(target_position, time)
				# slowly move the rotation
				rect_rotation = start_rotation * (1-time) + (target_rotation * time)
				rect_scale.x = original_scale.x * abs(2*time - 1)
				time+=delta/float(draw_time)
			else:
				rect_position = target_position
				rect_rotation = target_rotation
				state = in_hand
				time = 0
		reorganise_hand:
			if setup:
				setup()
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(target_position, time)
				# slowly scale back
				rect_scale = start_scale * (1-time) + original_scale*time
				time+=delta/float(reorganise_time)
				# if the reorganise neighbors has been triggered fix my hand
			else:
				rect_position = target_position
				rect_rotation = target_rotation
				rect_scale = original_scale
				state = in_hand
				time = 0
			if reorganize_neighbors == false:
				if card_no <= card_in_hand_count:
					reset_card(card_no)
				if card_no +1 <= card_in_hand_count:
					reset_card(card_no +1)
				if card_no -2 >= 0:
					reset_card(card_no -2)
				if card_no -3 >= 0:
					reset_card(card_no -3)
				reorganize_neighbors = true
	update()

func setup():
	start_position = rect_position
	start_rotation = rect_rotation
	start_scale = rect_scale
	time = 0
	reorganize_neighbors = true
	setup = false

func _on_Focus_mouse_entered() -> void:
	print("entered")
	mouse_is_inside = true
	match state:
		in_hand, reorganise_hand:
			setup = true
			target_rotation = 0
			target_position = default_position
			target_position.y -= 150
			state = focused_in_hand

func _on_Focus_mouse_exited() -> void:
	mouse_is_inside = false
	match state:
		focused_in_hand:
			# restore the card pos and rot
			target_position = default_position
			target_rotation = default_rotation
			state = reorganise_hand
			
# move the neighbor card (check if on the left and multiply by spread factor)
func move_neighbor_card(card_num, left, spread_factor):
	var neighbour_card = $"../.".hand[card_num]
	if left:
		neighbour_card.target_position = neighbour_card.default_position - spread_factor*Vector2(100, 0)
	else:
		neighbour_card.target_position = neighbour_card.default_position + spread_factor*Vector2(150, 0)
	neighbour_card.setup = true
	neighbour_card.state = reorganise_hand
	
# return the card to its default position
func reset_card(card_num):
	var neighbour_card = $"../.".hand[card_num]
	neighbour_card.target_position = neighbour_card.default_position
	neighbour_card.setup = true
	neighbour_card.state = reorganise_hand
	
func _input(event: InputEvent) -> void:
	match state:
		focused_in_hand, under_mouse:
			# pick up the card
			if event.is_action_pressed("leftclick"):
				if card_selected:
					state = under_mouse
					setup = true
					old_state = state
					card_selected = false
			# play a card
			if event.is_action_released("leftclick") && get_parent().my_turn && get_parent().current_mana >= cost:
				print(card_selected)
				if card_selected == false:
					var card_slots = get_parent().friendly_slots
					var mouse_position = get_global_mouse_position()
					# if the mouse is inside the card playing area
					if mouse_position.x <= 1500 && mouse_position.x >= 110 && mouse_position.y <= 800 &&  mouse_position.y >= 200:
						for cs in card_slots:
							if cs.is_empty && cs.enemy_slot == false:
								setup = true
								moving_to_table = true
								get_parent().table.append($".")
								state = on_table
								slot = cs
								get_parent().hand.erase($".")
								cs.is_empty = false
								# update mana
								get_parent().current_mana -= cost
								get_parent().update_mana_text(str(get_parent().current_mana))
								get_parent().reorganise_hand()
								get_parent().get_parent().get_node("Client").play_a_card(file_name)
								break
						
			# return the card back on right click
			if event.is_action_pressed("rightclick"):
					state = reorganise_hand
					setup = true
					target_position = default_position
					card_selected = true
					get_parent().reorganise_hand()
		on_table:
			if get_parent().my_turn:
				if not attacked:
					# draw the attacking line
					if event.is_action_pressed("leftclick") && attacking == false && enemy_card == false && mouse_is_inside:
						attacking = true
					# stop drawing the attacking line and if the mouse is inside a card or the enemy head attack the card or the head
					if event.is_action_released("leftclick") && attacking == true:
						attacking = false
						var enemy_cards = get_parent().enemy_table
						var mouz_loc = get_global_mouse_position()
						var enemy_head = get_parent().get_node("EnemyHead")
						var real_head_size = enemy_head.get_node("ColorRect").rect_size
						var he_mid = enemy_head.position + real_head_size/2
						# check if attacking the head and attack it
						if he_mid.x - real_head_size.x/2 < mouz_loc.x && he_mid.x + real_head_size.x/2 > mouz_loc.x && he_mid.y - real_head_size.y/2 < mouz_loc.y && he_mid.y + real_head_size.y/2 > mouz_loc.y :
								previous_position = rect_position
								setup = true
								state = in_attack
								target_position = enemy_head.position
								on_the_way = true
								attacked = true
								get_parent().get_parent().get_node("Client").attack_enemy_head(file_name)
								get_parent().hit_enemy(attack)
						for ca in enemy_cards:
							# if the mouse is in the enemy card attack it
							var real_ca_size = ca.rect_size * ca.rect_scale
							var ca_mid = ca.rect_position + real_ca_size/2
							if ca_mid.x - real_ca_size.x/2 < mouz_loc.x && ca_mid.x + real_ca_size.x/2 > mouz_loc.x && ca_mid.y - real_ca_size.y/2 < mouz_loc.y && ca_mid.y + real_ca_size.y/2 > mouz_loc.y :
								previous_position = rect_position
								setup = true
								state = in_attack
								target_position = ca.rect_position
								on_the_way = true
								last_attacked = ca
								attacked = true
								get_parent().get_parent().get_node("Client").attack_to_a_card(file_name, ca.file_name)
								break
						
func _draw():
	if attacking:
		# now i can say that i hate local positions
		# I mean what is their point, we can just use global positions for everything and nothing will be confusing
		# anymore
		draw_line(make_canvas_position_local(rect_position) + rect_size/2, get_local_mouse_position(), Color(1, 0, 0, 0.5), 25)
		
func die():
	# remove from the table list
	if enemy_card:
		get_parent().enemy_table.erase(get_node("."))
	else:
		get_parent().table.erase(get_node("."))
	if slot:
		slot.is_empty = true
		# remove the card
		queue_free()
