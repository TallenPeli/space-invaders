extends CharacterBody2D

var speed = 50
@onready var GameManager = $".."
@onready var sprite = $Sprite2D

var is_flipped = false

func _ready():
	GameManager._audio_manager.player_shoot.play()

func _physics_process(delta):
	position += transform.y * speed * delta
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collider = collision_info.get_collider()
		if collider is TileMap:
			var collision_position = collision_info.get_position()
			GameManager.create_point_label(collision_position, 1)
			var local_position = collider.to_local(collision_position)
			var map_position = collider.local_to_map(local_position)
			collider.erase_cell(0, map_position)
			GameManager._audio_manager.destroy.play()
			GameManager.score += 1
			GameManager.update_ui()
			queue_free()
		if collider.is_in_group("Enemy"):
			GameManager.score += 1
			GameManager.update_ui()
			GameManager.create_point_label(collision_info.get_position(), 1)
			GameManager._audio_manager.hit.play()
			GameManager._enemy.hit()
			GameManager._game_camera.apply_shake(abs(collider.health - 100) / -100.0)
			collider.health -= 1.0
			queue_free()
			
func _on_timer_timeout():
	queue_free()

func _on_flip_timer_timeout():
	is_flipped = !is_flipped
	sprite.flip_h = is_flipped
