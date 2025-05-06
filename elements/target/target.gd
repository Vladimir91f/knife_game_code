class_name Target extends CharacterBody2D

const KNIFE_POSITION = Vector2(0, 180)
var speed = PI

@onready var items_container: Node2D = $ItemsContainer


func _physics_process(delta: float) -> void:
	rotation += speed * delta

func add_object_with_pivot(object: Node2D, objectRotation: float):
	var pivot = Node2D.new()
	pivot.rotation = objectRotation
	pivot.add_child(object)
	items_container.add_child(pivot)
