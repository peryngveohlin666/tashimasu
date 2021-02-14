extends MarginContainer

# card attributes
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

# card state
enum {
	in_hand,
	on_table,
	under_mouse,
	focused_in_hand,
	move_to_hand,
	reorganise_hand
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
		in_hand:
			pass
		on_table:
			pass
		under_mouse:
			pass
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

func setup():
	start_position = rect_position
	start_rotation = rect_rotation
	start_scale = rect_scale
	time = 0
	reorganize_neighbors = true
	setup = false

func _on_Focus_mouse_entered() -> void:
	match state:
		in_hand, reorganise_hand:
			setup = true
			target_rotation = 0
			target_position = default_position
			target_position.y -= 150
			state = focused_in_hand

func _on_Focus_mouse_exited() -> void:
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
