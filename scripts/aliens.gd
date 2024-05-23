extends Path2D

var inc=0
var speed=500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	inc+=delta*speed
	$PathFollow2D.offset=inc
