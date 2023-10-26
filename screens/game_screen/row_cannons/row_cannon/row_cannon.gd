class_name RowCannon extends GameCharacter

signal cannon_used(cannon_index:int)

const _CANNON_BULLET_SCENE_PATH : String = "res://game_objects/components/bullet/cannon_bullet/cannon_bullet.tscn"

@export var starting_bullet_position : Vector2
var is_active : bool : set = _set_is_active
var damage_per_hit : int = 100
var _opponent_at_physical_contact : Object
var _is_already_shooting : bool

func _physics_process(_delta):
	if is_active and $AnimationPlayer.current_animation == "_shoot":
		_check_for_opponent_at_physical_contact()
	
		if _opponent_at_physical_contact != null and not _opponent_at_physical_contact.is_dying:
			_opponent_at_physical_contact.auto_destroy()

func _set_is_active(new_value:bool):
	is_active = new_value
	_update_cannon_visibility()

func shoot():
	if not _is_already_shooting:
		_is_already_shooting = true
		$AnimationPlayer.play("_shoot")
		$ShootSoundTimer.start()

func _update_cannon_visibility():
	if is_active:
		self.modulate = Color(1,1,1,1)
		self.visible = true
	else:
		self.visible = false

func _start_bullet_movement_animation():
	var cannon_bullet_scene : PackedScene = load(_CANNON_BULLET_SCENE_PATH)
	var cannon_bullet : CannonBullet = cannon_bullet_scene.instantiate() as CannonBullet
	self.add_child(cannon_bullet)
	cannon_bullet.position = starting_bullet_position
	
	cannon_bullet.bullet_sender = self
	cannon_bullet.start_movement_process()

func _check_for_opponent_at_physical_contact():
	var last_movement_collision : KinematicCollision2D = self.move_and_collide(Vector2(100,0), true) # Test Only Must be true
	if last_movement_collision != null:
		_opponent_at_physical_contact = last_movement_collision.get_collider()
	else:
		_opponent_at_physical_contact = null


func _on_shoot_sound_timer_timeout():
	$SFXPlayer.play_sound()
	_start_bullet_movement_animation()
	$DisappearTimer.start()


func _on_disappear_timer_timeout():
	cannon_used.emit(int(self.name.trim_prefix("RowCannon")))
	self.is_active = false
