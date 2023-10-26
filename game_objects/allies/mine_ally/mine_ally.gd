class_name MineAlly extends Ally


@export var activation_time : int

var _is_activated : bool
var _states_names : Array[String] = ["_charging", "_activated", "_exploding"]

var _opponent_at_shoot_reach : Object
#var _shooting_timer_timeout : bool

@onready var _background :ColorRect = get_node("Background") as ColorRect
@onready var _land_mine_texture : AnimatedSprite2D = $"LandMineTexture"
@onready var _explosion_textures : AnimatedSprite2D = $Explosion 
@onready var _activation_timer : Timer = $"ActivationTimer"
@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var _explosion_sfx_player : SFXPlayer = $SFXPlayer
@onready var _death_sfx_player : SFXPlayer = $DeathSFXPlayer
@onready var _default_texture : Sprite2D = $DefaultTexture


func _ready():
#	_connect_shooting_timer()
	_set_initial_state()
	_set_background_size()
	_connect_activation_timer()
	_start_activation_timer()

func _physics_process(_delta):
	_opponent_at_shoot_reach = $ShootingRange.get_collider() as Object
	
	if _opponent_at_shoot_reach != null:
		_at_opponent_touched()
		
	if _is_dying:
		set_physics_process(false)
		return

func _set_initial_state():
	_land_mine_texture.animation = _states_names[0] 

func _set_background_size():
	_background.global_position = Vector2(0,0)
	#background.size = Vector2(1920,1080)
	_background.size = get_viewport_rect().size
	_background.visible = false

func set_shooting_range(ally_collision_mask:int):
	var shooting_range : RayCast2D = $ShootingRange
	shooting_range.set_collision_mask_value(ally_collision_mask, true)

func _connect_activation_timer():
	_activation_timer.timeout.connect(_on_activation_timer_timeout)

func _start_activation_timer():
	_activation_timer.wait_time = activation_time
	_activation_timer.start()

func _at_opponent_touched():
	_default_texture.visible = false
	if _is_activated:
		_background.visible = true
		_explode()
		_is_dying = true
		_opponent_at_shoot_reach.auto_destroy("explosion")
		await get_tree().create_timer(0.2).timeout
		_explosion_sfx_player.play_sound()
		await get_tree().create_timer(0.6).timeout
		self.ally_died.emit(self, assigned_cell)
		self.queue_free()
	else:
		_get_destroyed()
		_death_sfx_player.play_sound() 
		_is_dying = true
		await get_tree().create_timer(1.2).timeout
		self.ally_died.emit(self, assigned_cell)
		self.queue_free()

func _explode():
	_animation_player.play("_exploding")
	_land_mine_texture.visible = false
	_explosion_textures.play(_states_names[2])
#	self.offset = Vector2(-3,-168)

func _get_destroyed():
	_land_mine_texture.animation = _states_names[0]
	_animation_player.play("_death")

func _on_activation_timer_timeout():
	if not _is_dying: 
		_is_activated = true
		_default_texture.visible = false
		_land_mine_texture.animation = _states_names[1]

#func _connect_shooting_timer():
#	$ShootingTimer.timeout.connect(_on_shooting_timer_timeout)

#func _on_shooting_timer_timeout():
#	_shooting_timer_timeout = true
