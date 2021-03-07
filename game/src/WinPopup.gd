extends Popup


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

const card = preload("res://scenes/game/Card.tscn")

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
	pass # Replace with function body.

func init(card_name):
	var new_card = card.instance()
	new_card.state = on_table
	new_card.start_rotation = 0
	new_card.target_rotation = 0
	new_card.on_deck_maker = true
	new_card.init(card_name)
	new_card.state = on_table
	new_card.card_earned = true
	add_child(new_card)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
