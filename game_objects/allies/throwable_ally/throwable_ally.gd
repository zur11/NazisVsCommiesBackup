class_name ThrowableAlly extends Ally

@export var inflicting_damage_points : int

var _is_exploding : bool
var _opponents_at_explosion_contact : Array[Object]

var falling_time : float : set = _set_falling_time
var ally_size : Vector2
var _states_names : Array[String] = ["default", "explosion"]
var _assigned_collision_masks : Array[int]


@onready var background : ColorRect = get_node("Background") as ColorRect
@onready var _throwable_texture : AnimatedSprite2D = $"ThrowableTexture" 
@onready var _falling_timer : Timer = $"FallingTimer"
@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var _explosion_sfx_player : SFXPlayer = $SFXPlayer
@onready var _explosion_blast : Area2D = $ExplosionBlast
@onready var _blast_coll_shape : CollisionShape2D = $%BlastCollShape


func _physics_process(_delta):
	if _is_exploding:
		if _opponents_at_explosion_contact.size() == 0: return
		
		for opponent in _opponents_at_explosion_contact:
			if opponent != null:
				if self is Grenade:
					opponent.auto_destroy("explosion")
				if self is MolotovCocktail:
					opponent.receive_damage(inflicting_damage_points,"close_normal")
		
		_opponents_at_explosion_contact.clear()

func _grenade_initial_setup():
	_set_background_size()
	_connect_explosion_blast()
	_set_explosion_blast_collision_settings()
	_set_initial_state()
	_set_ally_size()
	_set_and_start_falling_timer()

func _connect_explosion_blast():
	_explosion_blast.body_entered.connect(_on_explosion_blast_body_entered)

func set_explosion_blast_collision_masks(collision_masks:Array[int]):
	_assigned_collision_masks = collision_masks

func _set_explosion_blast_collision_settings():
	for mask in _assigned_collision_masks:
		_explosion_blast.set_collision_mask_value(mask, true)

func _set_falling_time(new_value:float):
	falling_time = new_value
	_grenade_initial_setup()

func _set_and_start_falling_timer():
	_falling_timer.wait_time = falling_time
	_falling_timer.start()

func _set_background_size():
	background.global_position = Vector2(0,0)
	#background.size = Vector2(1920,1080)
	background.size = get_viewport_rect().size
#	background.visible = false

func _set_initial_state():
	_throwable_texture.animation = _states_names[0] 

func _set_ally_size():
	var ally_default_texture : Texture2D = _throwable_texture.sprite_frames.get_frame_texture(_states_names[0], 0)

	ally_size = ally_default_texture.get_size()

func _explode():
	background.visible = true
	_throwable_texture.play(_states_names[1])
	_animation_player.play("_exploding")

func _on_falling_timer_timeout():
	_blast_coll_shape.shape.size = Vector2(536, 536)
	_explode()
	_explosion_sfx_player.play_sound()
	_is_exploding = true
#	printt(_opponents_at_explosion_contact)
	
	await get_tree().create_timer(1).timeout
	self.ally_died.emit(self, assigned_cell)
	self.queue_free()

func _on_explosion_blast_body_entered(body:Node2D):
	if body != null and not body is Ally and not body is SovietShield:
		_opponents_at_explosion_contact.append(body)

