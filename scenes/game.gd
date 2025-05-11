extends Node2D

@export var max_health: int = 100
@onready var health_bar: ProgressBar = $Hp/ProgressBar

var current_health: int = 0
var dataManager
var user_id
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Создаем и настраиваем таймер
	timer = Timer.new()
	timer.wait_time = 10.0  # Интервал 10 секунд
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	var get_user_id_query = """
		const urlParams = new URLSearchParams(window.location.search);
		urlParams.get('user_id') || '';
	"""
	user_id = JavaScriptBridge.eval(get_user_id_query, true)
	if user_id == null:
		user_id = '0'
	
	dataManager = DataManager.new()
	dataManager.initialize(self)
	
	await make_request()

	health_bar.max_value = max_health
	health_bar.value = current_health

func make_request():
	var userData = await dataManager.get_data("users", user_id)
	if userData != null and userData.has("health"):
		current_health = int(userData['health'])

func _on_timer_timeout():
	await make_request()
	update_health_display()
	print('запрос здоровья...')


func update_health_display():
	health_bar.value = current_health


func add_health(amount: int):
	current_health += amount
	if current_health < 0:
		current_health = 0
		
	if current_health > max_health:
		current_health = max_health

	if current_health != 0 and current_health <= max_health and user_id != '0' and user_id != null:
		await dataManager.update_data("users", user_id, {'health': current_health})

	update_health_display()

func _on_add_health_pressed() -> void:
	add_health(5)
