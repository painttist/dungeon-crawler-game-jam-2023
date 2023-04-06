extends StaticBody3D

@onready var player : Player = get_parent().get_node("player")

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var level : GridMap = get_parent().get_node("level")

const TWEEN_DURATION = 0.3

var tween

func move_forward() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.FORWARD * 2), TWEEN_DURATION)

func move_back() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.BACK * 2), TWEEN_DURATION)

func move_left() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.LEFT * 2), TWEEN_DURATION)

func move_right() -> void:	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.RIGHT * 2), TWEEN_DURATION)

func _physics_process(_delta):
	look_at(player.position)

var health = 6

func take_damage(attacker, damage):
	health -= damage
#	attacker.move_back()
	print("enemy health: ", health, " attacked by ", attacker.name)
	check_death()

func check_death():
	if health <= 0:
		self.queue_free()
		
const FLOAT_EPSILON = 0.00001

func move_towards_player():
	var dist = self.transform.origin.distance_to(player.transform.origin)
	if (dist <= 2.2):
		return
	
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = self.transform.origin
	params.to = player.transform.origin
	params.exclude = [self.get_rid()]
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if (result and dist >= 6) :
		return
#	print("Moving towards player")
#	print(dist)
	var cell = level.get_cell_item(self.transform.origin)
	var cell_f = level.get_cell_item(self.transform.translated(Vector3.FORWARD * 2).origin)
	var cell_b = level.get_cell_item(self.transform.translated(Vector3.BACK * 2).origin)
	var cell_l = level.get_cell_item(self.transform.translated(Vector3.LEFT * 2).origin)
	var cell_r = level.get_cell_item(self.transform.translated(Vector3.RIGHT * 2).origin)
#	print(cell)
#	print(cell_f)
#	print(cell_b)
#	print(cell_l)
#	print(cell_r)
	
#	var dir = self.transform.basis.looking_at(player.transform.origin)
	var dir = self.transform.origin.direction_to(player.transform.origin)
	if dir.x > FLOAT_EPSILON and cell_r >= 0:
#		print("move right")
		move_right()
	elif dir.x < -FLOAT_EPSILON and cell_l >= 0:
#		print("move left")
		move_left()
	elif dir.z < -FLOAT_EPSILON and cell_f >= 0:
#		print("move front")
		move_forward()
	elif dir.z > FLOAT_EPSILON and cell_b >= 0:
#		print("move back")
		move_back()
#		move_forward()
#	print("dir: ", dir)
#	print("dist: ", dist)
#	print("basis: ", self.transform.basis)
	
#	if (abs(dir.x) > abs(dir.z)):
##		move left or right
#		if dir.x > 0:
#			move_right()
#		else:
#			move_left()
#	else:
##		move foward or back
#		if dir.z > 0:
#			print("move back")
#			move_back()
#		else:
#			print("move foward")
#			move_forward()
	
func _ready():
	print(player.name)
	player.acted.connect(move_towards_player)
