extends CharacterBody2D

@onready var GameManager = $".."

var speed = 40

func _physics_process(delta):
	position -= transform.y * speed * delta
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collider = collision_info.get_collider()
		if collider.is_in_group("Player"):
			Input.start_joy_vibration(0, 0.1, 0.8, 0.1)
			GameManager._audio_manager.hit.play()
			GameManager._game_camera.apply_shake(1.0)
			GameManager._player.health -= 1
			GameManager._player.hit()
			GameManager.update_ui()
			queue_free()
		if collider.is_in_group("Enemy"):
			queue_free()

func _on_life_time_timeout():
	queue_free()
