extends Node

# Scenes
const GAME_CAMERA = preload("res://scenes/game_camera.tscn")
const PLAYER = preload("res://scenes/player.tscn")
const ENEMY = preload("res://scenes/enemy.tscn")
const UI = preload("res://scenes/ui.tscn")
const AUDIO_MANAGER = preload("res://scenes/audio_manager.tscn")
const POINT_LABEL = preload("res://scenes/point.tscn")
const ENEMY_FIGHTER = preload("res://scenes/enemy_fighter.tscn")

# Variables to store game objects
var _player
var _game_camera
var _ui
var _audio_manager
var _enemy

var player_health

# Global Variables
var score = 0
var difficulty = 1

var is_player_alive = false
var is_game_over = false

func create_point_label(location: Vector2, points: int):
	var _point_label = POINT_LABEL.instantiate()
	var label = _point_label.get_node("point_label")  # Correctly accessing the point_label node
	label.text = "+" + str(points)
	_point_label.position = location
	add_child(_point_label)

func update_ui():
	_ui.update()

func spawn_player():
	_player = PLAYER.instantiate()
	_player.position = Vector2(0.0, 0.0)
	_player.Is_controllable = true
	_player.health = 5.0
	is_player_alive = true
	add_child(_player)
	_player.add_child(_game_camera)
	player_health = _player.health

func spawn_enemy():
	_enemy = ENEMY.instantiate()
	_enemy.position.y = 94
	add_child(_enemy)

func game_over():
	Input.start_joy_vibration(0, 0.1, 1.0, 1.0)
	add_child(_game_camera)
	_audio_manager.explode.play()
	Engine.time_scale = 0.1
	_ui._game_over_text.show()
	is_game_over = false
	
func _ready():
	
	Engine.time_scale = 1.0
	# Add the game camera
	_game_camera = GAME_CAMERA.instantiate()
	
	# Create Player
	spawn_player()
	
	# Initialize the UI
	_ui = UI.instantiate()
	add_child(_ui)
	update_ui()
	
	# Initialize Audio System
	_audio_manager = AUDIO_MANAGER.instantiate()
	add_child(_audio_manager)
	_audio_manager.ambiance.play()

	# Spawn Enemy
	spawn_enemy()

func restart_game():
	if _enemy:
		_enemy.queue_free()
	
	spawn_enemy()
	
	Engine.time_scale = 1.0
	spawn_player()

func _process(_delta):
	
	if is_player_alive:
		
		player_health = _player.health
		
		if player_health <= 0:
			_player.remove_child(_game_camera)
			is_player_alive = false
			_player.queue_free()
			is_game_over = true
			restart_game()
	else:
		if is_game_over:
			game_over()
