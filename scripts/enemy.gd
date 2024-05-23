extends CharacterBody2D

const SPEED = 300.0

@onready var GameManager = $".."
@onready var cool_down = $CoolDown
@onready var sprite = $Sprite2D

@export var health : float = 200.0

var can_shoot = true
var target_player = true
var is_hit = false
var hit_time = 0.0
var hit_duration = 0.1  # Duration of the hit effect in seconds

var bullet = preload("res://scenes/enemy_bullet.tscn")
var hit_color = 0.0

# Store the original scale of the sprite
var original_scale = Vector2()

func _ready():
	# Initialize the original scale
	original_scale = sprite.scale

func hit():
	Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
	hit_color = 1.0
	is_hit = true
	hit_time = 0.0

func shoot():
	can_shoot = false
	GameManager._audio_manager.enemy_shoot.play()
	var _bullet = bullet.instantiate()
	GameManager.add_child(_bullet)
	cool_down.start()
	_bullet.transform = self.transform
	
func _physics_process(delta):
	if health <= 0:
		Input.start_joy_vibration(0, 0.2, 1.0, 0.6)
		GameManager.create_point_label(position, 200)
		GameManager.score += 200
		GameManager.update_ui()
		GameManager._audio_manager.explode.play()
		GameManager.difficulty += 10
		queue_free()
	
	if target_player:
		if GameManager.is_player_alive:
			if GameManager._player.position.x != self.position.x:
				if GameManager._player.position.x > self.position.x:
					self.position.x += (GameManager._player.position.x - self.position.x) * delta
				elif GameManager._player.position.x < self.position.x:
					self.position.x -= (self.position.x - GameManager._player.position.x) * delta
				
				if self.position.x - GameManager._player.position.x < 6 and GameManager._player.position.x - self.position.x < 6:
					if abs(GameManager._player.position.y - position.y) < 100:
						if can_shoot:
							shoot()
	
	sprite.self_modulate = Color(1, health/100, health/100)
	
	move_and_slide()

	if is_hit:
		hit_time += delta
		var t = hit_time / hit_duration
		if t >= 1.0:
			t = 1.0
			is_hit = false
		# Apply sine function for smooth scalingS
		var scale_factor = 1.0 - 0.1 * sin(t * PI)
		hit_color = hit_color * sin(t * PI)
		sprite.self_modulate = Color(1.0, 1.0 - hit_color, 1.0 - hit_color)
		sprite.scale = original_scale * scale_factor

func _on_cool_down_timeout():
	can_shoot = true
