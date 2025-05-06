extends Node2D

var knifeScene = preload("res://elements/knife/knife.tscn")

@onready var knife: CharacterBody2D = $Knife
@onready var timer: Timer = $Timer

func create_new_knife():
	knife = knifeScene.instantiate()
	add_child(knife)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed() and timer.time_left <= 0:
		knife.throw()
		timer.start()


func _on_timer_timeout() -> void:
	create_new_knife()
