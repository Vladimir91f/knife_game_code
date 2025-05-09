extends Node2D

@onready var info: Label = $Info
@onready var user_info: Label = $UserInfo
@onready var firebase_info: Label = $FirebaseInfo
@onready var http_request: HTTPRequest = $HTTPRequest

var _firebaseUrl: String
var _firebaseSecret: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var js_code = """
		const urlParams = new URLSearchParams(window.location.search);
		urlParams.get('user_id') || '';
	"""
	var user_id = JavaScriptBridge.eval(js_code, true)
	user_info.text = "Your user_id: " + str(user_id)
	
	#проба HTTP request
	http_request.request_completed.connect(_on_request_completed)
	http_request.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	
	_firebaseUrl = Marshalls.base64_to_raw(ProjectSettings.get_setting("application/config/firebase_url")).get_string_from_utf8()
	_firebaseSecret = Marshalls.base64_to_raw(ProjectSettings.get_setting("application/config/firebase_secret")).get_string_from_utf8()
	
	get_user_data("user1")
	#add_user("user2", "Мария", 120)
	#update_user("user1", {"health": 150, "level": 5})

# Получение данных пользователя
func get_user_data(user_id: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_user_data_received)

	# Формируем URL запроса к конкретному пользователю
	var url = "%s%s.json?auth=%s" % [_firebaseUrl, user_id, _firebaseSecret]
	
	var error = http_request.request(url)
	if error != OK:
		firebase_info.text = "Ошибка при отправке запроса: " + error

func _on_user_data_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())  
		if parse_result == OK:
			var user_data = json.get_data()
			firebase_info.text = str(user_data)
		else:
			firebase_info.text = "Ошибка парсинга JSON: " + json.get_error_message()
	else:
		firebase_info.text = "Ошибка HTTP запроса: " + str(response_code)


# Добавление нового пользователя
func add_user(user_id: String, name: String, health: int):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_add_user_completed)

	var url = "%s%s.json?auth=%s" % [_firebaseUrl, user_id, _firebaseSecret]
	var headers = ["Content-Type: application/json"]
	var data = {
		"name": name,
		"health": health
	}
	var body = JSON.stringify(data)

	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, body)
	if error != OK:
		push_error("Ошибка при добавлении пользователя: ", error)

func _on_add_user_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		print("Пользователь успешно добавлен")
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			print("Ответ сервера: ", json.get_data())
	else:
		push_error("Ошибка при добавлении пользователя: ", response_code)


# Обновление данных пользователя
func update_user(user_id: String, updates: Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_user_completed)

	var url = "%s%s.json?auth=%s" % [_firebaseUrl, user_id, _firebaseSecret]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(updates)

	var error = http_request.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if error != OK:
		push_error("Ошибка при обновлении пользователя: ", error)

func _on_update_user_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		print("Данные пользователя успешно обновлены")
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			print("Обновленные данные: ", json.get_data())
	else:
		push_error("Ошибка при обновлении пользователя: ", response_code)


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var name = json["name"]
	print(name)
	info.text = "код: " + str(response_code) + ", name = " + name

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
