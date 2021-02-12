extends Control

var username_field
var password_field

# Called when the node enters the scene tree for the first time.
func _ready():
	var login_button = get_node("VBoxContainer/LoginButton")
	var register_button = get_node("VBoxContainer/RegisterButton")
	
	username_field = get_node("VBoxContainer/UsernameField")
	password_field = get_node("VBoxContainer/PasswordField")
	
	login_button.connect("pressed", self, "_on_login_pressed")
	register_button.connect("pressed", self, "_on_register_pressed")
	
func _on_login_pressed():
	var username = str(username_field.get_text())
	var password = str(password_field.get_text())
	var client = get_parent().get_node("./Client")
	client.login(username, password)
	
func _on_register_pressed():
	var username = str(username_field.get_text())
	var password = str(password_field.get_text())
	var client = get_parent().get_node("./Client")
	client.register(username, password)
