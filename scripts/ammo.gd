extends Area2D

@onready var GameManager = $"../.."
@onready var respawn_cooldown = $respawn_cooldown

var can_collide = true
var counter = 0.0

func _on_body_entered(body):
	if can_collide:
		if body.is_in_group("Player"):
			GameManager._audio_manager.collect.play()
			Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
			GameManager._player.ammo += 10
			hide()
			can_collide = false
			respawn_cooldown.start()

func _on_respawn_cooldown_timeout():
	can_collide = true
	show()

func _process(delta):
	counter += delta
	scale = Vector2(0.2 + (0.05*(sin(counter*6.0)+PI)), 0.2 + (0.05*(sin(counter*6.0)+PI)))
