extends CharacterBody2D

var bullet = preload("res://scenes/bullet.tscn")

@export var health : float = 5.0
@export var Is_controllable = true
@onready var GameManager = $".."
@onready var sprite = $AnimatedSprite2D
@onready var ammo_bar = $VBoxContainer/ProgressBar

const SPEED = 200.0
const MAX_SPEED = 50.0
const DECELERATION = 0.9
const MAX_SHAKE = 10.0

var shrink_time = 0.0
var shrink_duration = 0.1  # Duration of the hit effect in seconds
var hit_color = 0
var max_distance: float = 200.0

var can_shrink = false
var can_shoot = true
var is_first_click = true
var is_screen_touched = false
var is_shooting = false

var ammo = 10

# Store the original scale of the sprite
var original_scale = Vector2()
var touch_origin = Vector2()
var input_vector = Vector2()

var down = []

func _ready():
	# Initialize the original scale
	original_scale = sprite.scale

func shrink_effect():
	can_shrink = true
	shrink_time = 0.0
	
func hit():
	hit_color = 1.0
	shrink_effect()

func shoot():
	Input.start_joy_vibration(0, 0.1, 0.2, 0.1)
	ammo -= 1
	can_shoot = false
	var _bullet = bullet.instantiate()
	get_parent().add_child(_bullet)
	_bullet.position = self.position

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch and event.pressed:
			if event.index == 0:
				is_first_click = false
				is_screen_touched = true
				touch_origin = event.position
				GameManager._ui.touch_spot.show()
				GameManager._ui.current_touch_spot.show()
				GameManager._ui.touch_spot.position = touch_origin
				GameManager._ui.current_touch_spot.position = touch_origin
				
		elif event is InputEventScreenTouch and not event.pressed:
			if event.index == 0:
				is_first_click = true
				is_screen_touched = false
				GameManager._ui.touch_spot.hide()
				GameManager._ui.current_touch_spot.hide()

		if is_screen_touched:
			if event.index == 0:
				var current_touch_position = event.position
				var direction = current_touch_position - touch_origin
				var distance = direction.length()
				if distance > max_distance:
					direction = direction.normalized() * max_distance
					
				GameManager._ui.current_touch_spot.position = touch_origin + direction
				var scale_factor = clamp(distance / max_distance, 0.0, 4.0)
				GameManager._ui.current_touch_spot.scale = Vector2(scale_factor, scale_factor)
				GameManager._ui.current_touch_spot.look_at(GameManager._ui.touch_spot.position)
				GameManager._ui.current_touch_spot.rotation -= PI / 2
				input_vector = direction.normalized()

func _physics_process(delta):
	if Is_controllable:
		if !is_screen_touched and !Input.is_action_pressed("click"):
			input_vector = Vector2(
				Input.get_axis("left", "right"),
				Input.get_axis("up", "down")
			)
		
		if Input.is_action_pressed("shoot"):
			is_shooting = true
		else:
			is_shooting = false
		
		if can_shoot and is_shooting:
			if ammo > 0:
				GameManager._game_camera.apply_shake(0.3)
				shrink_effect()
				shoot()
				velocity.y -= 5
				if ammo > 50:
					ammo = 50
		
		ammo_bar.value = ammo
		
		if input_vector.length() > 0:
			input_vector = input_vector.normalized() * SPEED * delta
			velocity += input_vector
		else:
			# Apply deceleration
			velocity = velocity * DECELERATION
		
		rotation = velocity.x / 360

		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)

	# Move the player
	move_and_slide()

	if can_shrink:
		shrink_time += delta
		var t = shrink_time / shrink_duration
		if t >= 1.0:
			t = 1.0
			can_shrink = false
		# Apply sine function for smooth scaling
		var scale_factor = 1.0 - 0.1 * sin(t * PI)
		
		hit_color = hit_color * sin(t * PI)
		sprite.self_modulate = Color(1.0, 1.0-hit_color, 1.0-hit_color)
		sprite.scale = original_scale * scale_factor

func _on_cooldown_timeout():
	can_shoot = true
