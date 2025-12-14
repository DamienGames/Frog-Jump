extends Node

@export var min_force := 250.0
@export var max_force := 1000.0
@export var max_drag := 200.0

@export var gravity := 2500.0

@export var preview_points := 22
@export var preview_ratio := 0.4

var dragging := false
var drag_start: Vector2
@onready var line: Line2D = $"../Line2D"

@onready var frog := owner as CharacterBody2D
@onready var camera := frog.get_viewport().get_camera_2d()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and frog.is_on_floor():
				dragging = true
				line.visible = true
				drag_start = camera.get_global_mouse_position()
			elif not event.pressed and dragging:
				_release()

func _process(_delta):
	if dragging:
		_update_preview()


func _update_preview():
	line.clear_points()

	var mouse_now = camera.get_global_mouse_position()

	# vetor REAL do arrasto
	var raw_drag = drag_start - mouse_now
	var drag_len = raw_drag.length()

	# força normalizada
	var strength = clamp(drag_len / max_drag, 0.0, 1.0)

	# drag limitado
	var drag = raw_drag.limit_length(max_drag)

	# velocidade inicial REAL
	var force = lerp(min_force, max_force, strength)
	var velocity = drag.normalized() * force

	# cor da linha (verde → vermelho)
	line.default_color = Color.from_hsv(
		lerp(0.33, 0.0, strength),
		1.0,
		1.0
	)

	var start_global = frog.global_position

	var total_time := 0.9
	var preview_time := total_time * preview_ratio

	for i in range(preview_points):
		var t = preview_time * float(i) / float(preview_points - 1)

		var global_pos =			start_global			+ velocity * t			+ Vector2(0, gravity) * t * t * 0.5

		# GLOBAL → LOCAL
		line.add_point(line.to_local(global_pos))
		# pontilhado simples (remove pontos intermediários)


func _release():
	
	$"../AnimatedSprite2D".play("jump")
	dragging = false
	line.visible = false

	var mouse_now = camera.get_global_mouse_position()
	var raw_drag = drag_start - mouse_now
	var strength = clamp(raw_drag.length() / max_drag, 0.0, 1.0)
	var drag = raw_drag.limit_length(max_drag)

	var force = lerp(min_force, max_force, strength)
	frog.velocity = drag.normalized() * force
