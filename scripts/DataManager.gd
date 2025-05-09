class_name DataManager extends Node

var _mainNode: Node2D

var _firebaseUrl: String
var _firebaseSecret: String

func initialize(firebaseUrl: String, firebaseSecret: String, mainNode: Node2D):
	_firebaseUrl = firebaseUrl
	_firebaseSecret = firebaseSecret
	_mainNode = mainNode

# Получение данных
func get_data(schema: String, id: String) -> Variant:	
	var http_request = HTTPRequest.new()
	_mainNode.add_child(http_request)
	
	var get_data_url = "%s/%s/%s.json?auth=%s" % [_firebaseUrl, schema, id, _firebaseSecret]
	var error = http_request.request(get_data_url)
	if error != OK:
		return null
	
	# Ждем завершения запроса
	var result = await http_request.request_completed
	var response_code = result[1]
	var body = result[3]
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			return json.get_data()
	
	return null

# Добавление данных
func add_data(schema: String, id: String, data: Dictionary) -> bool:
	var http_request = HTTPRequest.new()
	_mainNode.add_child(http_request)

	var add_data_url = "%s/%s/%s.json?auth=%s" % [_firebaseUrl, schema, id, _firebaseSecret]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	var error = http_request.request(add_data_url, headers, HTTPClient.METHOD_PUT, body)
	if error != OK:
		push_error("Ошибка при добавлении данных: ", error)
		http_request.queue_free()
		return false

	# Ожидаем завершения запроса
	var result = await http_request.request_completed
	http_request.queue_free()

	var response_code = result[1]
	var response_body = result[3]

	if response_code == 200:
		print("Данные успешно добавлены")
		var json = JSON.new()
		if json.parse(response_body.get_string_from_utf8()) == OK:
			print("Ответ сервера: ", json.get_data())
		return true
	else:
		push_error("Ошибка при добавлении данных: ", response_code)
		return false

# Обновление данных
func update_data(schema: String, id: String, updates: Dictionary) -> bool:
	var http_request = HTTPRequest.new()
	_mainNode.add_child(http_request)

	var update_data_url = "%s/%s/%s.json?auth=%s" % [_firebaseUrl, schema, id, _firebaseSecret]
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(updates)

	var error = http_request.request(update_data_url, headers, HTTPClient.METHOD_PATCH, body)
	if error != OK:
		push_error("Ошибка при обновлении данных: ", error)
		http_request.queue_free()
		return false

	# Ожидаем завершения запроса
	var result = await http_request.request_completed
	http_request.queue_free()

	var response_code = result[1]
	var response_body = result[3]

	if response_code == 200:
		print("Данные успешно обновлены")
		var json = JSON.new()
		if json.parse(response_body.get_string_from_utf8()) == OK:
			print("Обновленные данные: ", json.get_data())
		return true
	else:
		push_error("Ошибка при обновлении данных: ", response_code)
		return false
