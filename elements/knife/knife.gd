extends CharacterBody2D

var isFlying = false
var speed = 4500

func throw():
	isFlying = true
	
func _physics_process(delta: float) -> void:
	if isFlying:
		var collision = move_and_collide(Vector2.UP * speed * delta)
		if collision:
			handle_collision(collision)
		
func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	if collider is Target:
		add_knife_to_target(collider)
		isFlying = false

func add_knife_to_target(target: Target):
	get_parent().remove_child(self)
	global_position = Target.KNIFE_POSITION
	rotation = 0
	target.add_object_with_pivot(self, -target.rotation)
