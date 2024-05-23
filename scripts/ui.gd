extends CanvasLayer

@onready var _game_over_text = $Control/MarginContainer/VBoxContainer2/Label
@onready var _score = $Control/MarginContainer/VBoxContainer/HBoxContainer/score
@onready var GameManager = $".."
@onready var player_health_bar = $Control/MarginContainer/VBoxContainer3/ProgressBar
@onready var enemy_health_bar = $"Control/MarginContainer/enemy-indicator/ProgressBar"
@onready var enemy_indicator = $"Control/MarginContainer/enemy-indicator"
@onready var touch_spot = $Control/touch_spot
@onready var current_touch_spot = $Control/current_touch_spot

var counter = 1.0

func update():		
	_score.text = "Score : " + str(GameManager.score)

func _ready():
	update()
	_game_over_text.hide()

func update_ui() : get

func _process(_delta):
	player_health_bar.value = GameManager.player_health
	if GameManager._enemy:
		enemy_indicator.show()
		enemy_health_bar.value = GameManager._enemy.health
	else:
		enemy_indicator.hide()

func _on_button_pressed():
	GameManager._player.is_shooting = true


func _on_button_button_up():
	GameManager._player.is_shooting = false
