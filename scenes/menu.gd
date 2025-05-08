extends Node2D

@onready var user_info: Label = $UserInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var js_code = """
		const urlParams = new URLSearchParams(window.location.search);
		urlParams.get('user_id') || '';
	"""
	var user_id = JavaScriptBridge.eval(js_code, true)
	user_info.text = "Your User_Id: " + str(user_id)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
