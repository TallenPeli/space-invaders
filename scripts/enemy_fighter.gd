extends CharacterBody2D

@onready var GameManager = $".."
const FIGHTER_BULLET = preload("res://scenes/fighter_bullet.tscn")
@onready var cooldown = $cooldown

var SPEED = 20.0
var health = 10

var can_shoot = true

func _process(delta):
	if health <= 0:
		Input.start_joy_vibration(0, 0.2, 1.0, 0.6)
		GameManager.create_point_label(position, 10)
		GameManager.score += 10
		GameManager.update_ui()
		GameManager._audio_manager.explode.play()
		GameManager.difficulty += 10
		queue_free()
	
	if GameManager._player:
		var direction = Vector2(cos(rotation), sin(rotation))
		position += direction * 20 * delta

		# Calculate the angle to the player
		var angle_to_player = (GameManager._player.position - position).angle()
		
		# Check if the angle to the player is greater than the enemy's current rotation
		if angle_to_player > rotation:
			rotation += 1 * delta
		else:
			rotation -= 1 * delta
		
		# Shoot bullet if within range
		if position.distance_to(GameManager._player.position) < 100:
			if can_shoot:
				cooldown.start()
				can_shoot = false
				var _bullet = FIGHTER_BULLET.instantiate()
				GameManager.add_child(_bullet)
				_bullet.scale = Vector2(1, 1)
				
				# Set the bullet's position first
				_bullet.position = position
				_bullet.speed += SPEED
				
				# Then orient it towards the player
				_bullet.rotation = rotation + PI/2
	else:
		position.x += SPEED * delta

func _on_cooldown_timeout():
	can_shoot = true
