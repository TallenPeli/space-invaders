extends Area2D

@onready var point_label = $point_label

var transparency = 1.0
@export var fade_duration = 0.5  # Duration for the fade-out effect

func _ready():
	set_process(true)
	await get_tree().create_timer(fade_duration).timeout
	queue_free()

func _process(delta):
	if point_label:
		transparency -= delta / fade_duration
		transparency = clamp(transparency, 0.0, 1.0)
		point_label.modulate.a = transparency
		
		position += Vector2(delta * 20 * transparency, -delta * 20 * transparency)

func _on_timer_timeout():
	queue_free()
