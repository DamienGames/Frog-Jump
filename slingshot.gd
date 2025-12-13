extends Node

@export var max_force := 1200.0
@export var min_force := 200.0
@export var max_drag := 150.0
@onready var camera: Camera2D = $"../Camera2D"

var dragging := false
var drag_start: Vector2
var drag_current: Vector2
@export var preview_points := 16
@export var preview_ratio := 0.1 # 60%
@export var gravity := 2500.0

@onready var frog: CharacterBody2D = $".."
@onready var line := $"../Line2D"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if _clicked_on_frog(event.position):
				dragging = true
				drag_start = get_viewport().get_mouse_position()
				line.visible = true
		else:
			if dragging:
				_release()


func _clicked_on_frog(pos: Vector2) -> bool:
	return frog.get_viewport_rect().has_point(pos)

func _process(_delta):
	if dragging:
		drag_current = get_viewport().get_mouse_position()
		_update_line()


func _update_line():
	line.clear_points()

	var mouse_now = camera.get_global_mouse_position()
	var drag = drag_start - mouse_now
	drag = drag.limit_length(max_drag)

	var strength = drag.length() / max_drag
	var force = lerp(min_force, max_force, strength)

	var velocity = drag.normalized() * force

	var start_global := frog.global_position

	var total_time := 0.8
	var preview_time := total_time * preview_ratio

	for i in range(preview_points):
		var t := preview_time * float(i) / float(preview_points - 1)
		var global_pos: Vector2 = start_global + velocity * t + Vector2(0, gravity) * t * t * 0.5
		var local_pos: Vector2 = line.to_local(global_pos)
		line.add_point(local_pos)


func _release():
	dragging = false
	line.visible = false

	var drag = drag_start - drag_current
	drag = drag.limit_length(max_drag)

	var strength = drag.length() / max_drag
	var force = lerp(min_force, max_force, strength)

	var direction = drag.normalized()
	frog.velocity = direction * force
	animated_sprite_2d.play("jump")

	
