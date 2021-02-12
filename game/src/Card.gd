extends MarginContainer

# card attributes
var file_name : String
var image_location : String
var card_type : String
var card_name : String
var attack : int
var defense : int
var cost : int



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
#func _process(delta):
#	pass
