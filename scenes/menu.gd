extends Node2D

@onready var user_info: Label = $UserInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var get_user_id_query = """
		const urlParams = new URLSearchParams(window.location.search);
		urlParams.get('user_id') || '';
	"""
	var user_id = JavaScriptBridge.eval(get_user_id_query, true)
	if(user_id == null):
		user_info.text = 'User_id ' + str(user_id) +  ' не найден.'
		return

	var firebaseUrl = Marshalls.base64_to_raw(ProjectSettings.get_setting("application/config/firebase_url")).get_string_from_utf8()
	var firebaseSecret = Marshalls.base64_to_raw(ProjectSettings.get_setting("application/config/firebase_secret")).get_string_from_utf8()
	
	var dataManager = DataManager.new()
	dataManager.initialize(firebaseUrl, firebaseSecret, self)
	
	var userData = await dataManager.get_data("users", user_id)
	if(userData == null):
		dataManager.add_data("users", user_id, {'health': 100})
	
	user_info.text = "Your user_id: " + str(user_id) + "\n data: " + str(userData)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
