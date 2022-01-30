extends KinematicBody2D

	
const EVENT_START_DRAG = 0
const EVENT_END_DRAG = 1
const EVENT_DRAGGING = 2

const ALPHA = 0.1
const EPSILON = 0.0005
const SCALE_FACTOR = 25
const STATE_EXPIRATION_TIME = 1.0 / 20.0

var dragging = false
var host = true;
var packet_peer = null
var move = 0

var state = null
var state_timer = 0

func _ready():
	set_process_input(true)

func _process(_delta):
	if (not host && state_timer < STATE_EXPIRATION_TIME):

		# Apply lerp
		var rot = slerp_rot(transform.get_rotation(), state[1], ALPHA)
		var pos = lerp_pos(transform.get_origin(), state[0], 1.0 - ALPHA)

		# Apply body transforms
		rotation = rot
		position = pos
		# s.set_linear_velocity(state[2])
		# s.set_angular_velocity(state[3])

func broadcast(packet):
	if (host):
		get_node("/root/demo").broadcast(packet)
	else:
		packet_peer.put_var(packet)

func set_state(p_state):
	self.state = p_state
	self.state_timer = 0

# Lerp vector
func lerp_pos(v1, v2, alpha):
	return v1 * alpha + v2 * (1.0 - alpha)

# Spherically linear interpolation of rotation
func slerp_rot(r1, r2, alpha):
	var v1 = Vector2(cos(r1), sin(r1))
	var v2 = Vector2(cos(r2), sin(r2))
	var v = slerp(v1, v2, alpha)
	return atan2(v.y, v.x)

# Spherical linear interpolation of two 2D vectors
func slerp(v1, v2, alpha):
	var cos_angle = clamp(v1.dot(v2), -1.0, 1.0)

	if (cos_angle > 1.0 - EPSILON):
		return lerp_pos(v1, v2, alpha).normalized()

	var angle = acos(cos_angle)
	var angle_alpha = angle * alpha
	var v3 = (v2 - (cos_angle * v1)).normalized()
	return v1 * cos(angle_alpha) + v3 * sin(angle_alpha)

func _physics_process(_delta):
	move_and_slide(Vector2(move * 200, 200), Vector2(0, 1))


func _input(ev):
	move = 0
	if Input.is_key_pressed(KEY_A):
		move -= 1
	if Input.is_key_pressed(KEY_D):
		move += 1


func get_linear_velocity():
	return Vector2()

func get_angular_velocity():
	return 0
	
