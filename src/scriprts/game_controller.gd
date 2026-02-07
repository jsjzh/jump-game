extends Node

signal handle_coin(coin: int)
signal handle_score(score: int)

var coin: int = 0
var score: int = 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('exit'):
		get_tree().quit()
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()

func handle_add_coin(num: int = 1):
	coin += num
	handle_coin.emit(coin)

func handle_add_score(num: int = 1):
	score += num
	handle_score.emit(score)