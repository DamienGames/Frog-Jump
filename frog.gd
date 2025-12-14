extends CharacterBody2D

@export var gravity := 980.0
@export var ground_friction := 4000.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	if is_on_floor():
		# freio horizontal (fricção)
		velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
	else:
		velocity.y += gravity * delta
	move_and_slide()

func _on_dead_zone_body_entered(body: CharacterBody2D) -> void:
	animated_sprite_2d.play("dead")
	velocity.y -= 500
	await animated_sprite_2d.animation_finished
	queue_free()
