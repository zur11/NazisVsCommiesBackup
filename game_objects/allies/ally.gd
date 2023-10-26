class_name Ally extends GameCharacter

signal ally_died(ally:Ally, cell:Cell)

@export_enum("veryLow:10", "low:20", "high:30", "veryHigh:40") var starting_hp : int
@export var ally_name : String
@export var location_in_cell : Vector2
@export var occupies_two_cells : bool
@export_enum("very_slow", "slow", "medium", "fast") var speed : String = "slow"

var assigned_cell : Cell
var _current_hp : int
var _is_dying : bool


var _opponent_at_physical_contact : Object

# VARIABLES FOR ALLY CARD:
@export_enum("slow:40", "medium:20", "fast:8") var ally_card_loading_time: int
@export var normal_btn_texture : Texture
@export var selected_btn_texture : Texture
@export var price : int


func _set_current_hp():
	_current_hp = starting_hp

func receive_damage(damage_points:int, damage_type:String):
	if damage_type == "long_normal":
		$ReceiveDamage.play("_receive_damage_general")
	elif damage_type == "close_normal":
		if not self is ObstructerAlly:
			$ReceiveDamage.play("_receive_damage_general")
		else:
			$ReceiveDamage.play("_receive_damage_from_stab")
			_update_obstructer_texture_state()
			
	$ReceiveDamageSFXPlayer.play_sound()
	_current_hp -= damage_points
	
	if _current_hp <= 0 and not _is_dying:
		_is_dying = true
		_die()

func _die():
	$AnimationPlayer.play("_death")
	$DeathSFXPlayer.play_sound()
	await get_tree().create_timer(1).timeout
	
	self.queue_free()
	self.ally_died.emit(self, assigned_cell)

func auto_destroy():
	_die()

func adjust_location_in_cell():
	self.position = location_in_cell

func _update_obstructer_texture_state():
	pass


func _check_for_opponent_at_physical_contact():
	var last_movement_collider : KinematicCollision2D = self.move_and_collide(Vector2(0.1,0), true) # Test Only Must be true
	if last_movement_collider != null:
		_opponent_at_physical_contact = last_movement_collider.get_collider()
	else:
		_opponent_at_physical_contact = null
	

#func _on_cell_ocuppant_item_destroyed(item:GameCharacterItem):
#	_items.erase(item)
#	cell_occupant_item_destroyed.emit(assigned_cell)

func _update_animations_speed():
	
	match speed:
		"very_slow":
			$AnimationPlayer.speed_scale = 0.5
#			self.position.x -= base_enemy_movement * 0.5
		"slow":
			$AnimationPlayer.speed_scale = 1
#			self.position.x -= base_enemy_movement
		"medium":
			$AnimationPlayer.speed_scale = 1.5
#			self.position.x -= base_enemy_movement * 1.5
		"fast":
			$AnimationPlayer.speed_scale = 2
#			self.position.x -= base_enemy_movement * 2
