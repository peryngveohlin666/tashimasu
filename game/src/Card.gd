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
var time = 0
const draw_time = 0.2
const reorganise_time = 0.15

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
			pass
		# slowly move card to the hand interpolating the position and the rotation
		move_to_hand: # animate from the deck to hand
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(target_position, time)
				# slowly move the rotation
				rect_rotation = start_rotation * (1-time) + (target_rotation * time)
				time+=delta/float(draw_time)
			else:
				rect_position = target_position
				rect_rotation = target_rotation
				state = in_hand
				time = 0
		reorganise_hand:
			if time <= 1:
				# slowly move the position
				rect_position = start_position.linear_interpolate(target_position, time)
				time+=delta/float(reorganise_time)
			else:
				rect_position = target_position
				rect_rotation = target_rotation
				state = in_hand
				time = 0
