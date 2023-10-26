class_name AllyCard extends TextureButton

signal card_selected(selected_card:AllyCard)
signal card_unselected
signal card_loaded()

var ally : Ally
var is_affordable : bool : set = _set_is_affordable
var is_selected : bool = false : set = _set_is_selected
var is_loading : bool = false
var price : int
var has_been_choosen : bool 

var _loading_time: int
var _normal_btn_texture : Texture
var _selected_btn_texture : Texture

@onready var _price_label : Label = $PriceLabel
@onready var _loading_veil : ColorRect = $LoadingVeil
@onready var _loading_timer : Timer = $LoadingTimer

func _ready():
	pass
#	_set_initial_loading_variables()

#func _set_initial_loading_variables():
#	var initial_loading_time : int
#
#	match  loading_time:
#		40: # Slow
#			initial_loading_time = 26
#		20: # Medium
#			initial_loading_time = 10
#		8:  # Fast 
#			initial_loading_time = 0
#
#	_loading_timer.timeout.connect(_on_loading_timer_timeout)
#
#	if initial_loading_time == 0: # Enable for Card Loading Process
#		_loading_veil.visible = false
#		return
#
#	#_loading_veil.visible = false # Disable for Card Loading Process
#
#	start_loading_process(initial_loading_time) # Enable for Card Loading Process

func set_initial_variables(ally_arg:Ally):
	ally = ally_arg
	price = ally.price
	_loading_time = ally_arg.ally_card_loading_time
	_normal_btn_texture = ally.normal_btn_texture
	_selected_btn_texture = ally.selected_btn_texture

func initiate_card():
	_update_card_texture()
	_connect_signals()
	_set_price_label()

#func initiate_selectable_ally_card():
#	self.texture_normal = _normal_btn_texture
#	_set_price_label()

func start_loading_process(_loading_time_arg : int = _loading_time):
	var tween = create_tween()
	
	is_loading = true
	self.modulate = Color(1,1,1,0.6)
	_loading_veil.size = self.size
	_loading_veil.visible = true
	_loading_timer.wait_time = _loading_time_arg
	_loading_timer.start()
	
	tween.tween_property(_loading_veil,"size", Vector2(_loading_veil.size.x, 0), _loading_time_arg)

func _connect_signals():
	self.connect("pressed", _on_card_pressed)
	_loading_timer.timeout.connect(_on_loading_timer_timeout)

func _set_price_label():
	_price_label.text = str(price)

func _set_is_affordable(new_value:bool):
	is_affordable = new_value
#	if not is_affordable:
#		is_selected = false
	_update_card_texture()

func _set_is_selected(new_value:bool):
	is_selected = new_value
	if is_selected:
		card_selected.emit(self)
	else:
		card_unselected.emit()
	_update_card_texture()
	
func _update_card_texture():
	if is_loading: 
		return
	
	if is_selected:
		self.texture_normal = _selected_btn_texture
		return

	self.texture_normal = _normal_btn_texture
	
	if is_affordable:
		self.modulate = Color(1,1,1,1)
	else:
		self.modulate = Color(1,1,1,0.6)
		

func _on_loading_timer_timeout():
	is_loading = false
	card_loaded.emit()

func _on_card_pressed():
	if is_selected:
		is_selected = false
		return
		
	if is_affordable and not is_loading and not is_selected:
		is_selected = true
