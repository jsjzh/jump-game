extends Area2D

var is_shooted: bool = false

func _process(_delta: float) -> void:
	if !is_shooted:
		look_at(get_global_mouse_position())

func handle_shoot(pos: Vector2, vec: Vector2) -> void:
	position = pos
	print(pos)
	print(vec)
	is_shooted = true