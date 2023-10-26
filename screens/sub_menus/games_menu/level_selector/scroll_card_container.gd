class_name ScrollCardContainer extends ScrollContainer

signal user_stopped_scrolling
signal function_stopped_scrolling
signal card_selected(level:Level)
signal card_clicked(level:Level)

var control_paddings_size : float = 722
var _cards_container_separation : int = 32
var _card_label_base_scale : float = 0.55
var _value_to_scale_in_size = 0.5 # ALL CARDS CENTER CONTAINERS SIZE MUST BE = _base_texture_size * _value_to_scale_in_size 
var _base_texture_size : Vector2

var _initial_setup_done : bool = false
var _screen_just_released : bool = false
var _level_card_just_clicked : bool = false
var _card_selection_step : float
var _last_scroll_movement_value : float
var _current_selected_card_step : float
var _last_drag_event : InputEventScreenDrag
var available_card_buttons : Array[CenterContainer]

var _selector_is_moving : bool = false
var _scroll_was_dragged : bool = false
var _selector_moving_left : bool 

var _initial_selected_level : Level
var _current_selected_card : LevelCard

@onready var _level_selector : ScrollContainer = $"."
@onready var _horizontal_scroll : HScrollBar = $"_h_scroll"
@onready var _cards_container : HBoxContainer = $"%CardsContainer"
@onready var _viewport_center_position := self.get_viewport_rect().size.x / 2 



func _ready():
	_level_selector.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER 
	set_physics_process(false)

func _input(event: InputEvent):
	var clicked_on_scroll_container = event.position.y < self.size.y
	var clicked_on_unselected_card = event.position.y < _base_texture_size.y + 120.0
	
	if event.is_action_released("screen_touch") and clicked_on_scroll_container and _scroll_was_dragged:
		_level_card_just_clicked = false
		_screen_just_released = true
		set_physics_process(true)
		await user_stopped_scrolling
		await get_tree().create_timer(0.1).timeout
		_move_to_selected_card_step()
		_scroll_was_dragged = false
	
	if event is InputEventScreenDrag and clicked_on_scroll_container:
		var dragging_left : bool = event.relative.x < 0
		set_physics_process(true)
		_scroll_was_dragged = true
		_level_card_just_clicked = false
		_last_drag_event = event
		if dragging_left == true:
			_selector_moving_left = true
		else:
			_selector_moving_left = false
		_control_card_sizes_on_movement()
		
	elif (event is InputEventScreenTouch or event is InputEventMouseButton) and clicked_on_unselected_card:
		_level_card_just_clicked = true


func _physics_process(_delta):
#	printt("running")
	if !_initial_setup_done:
		_get_card_selection_step()
		_move_cards_to_initial_offset(_initial_selected_level)
		await get_tree().process_frame
		_set_initial_selected_card_size()
		_initial_setup_done = true
		set_physics_process(false)
	
	if _screen_just_released or _level_card_just_clicked:
		if _horizontal_scroll.value == _last_scroll_movement_value and not _selector_is_moving and not _level_card_just_clicked:
			set_physics_process(false)
		if not (_horizontal_scroll.value == _last_scroll_movement_value):
			_selector_is_moving = true
			_control_card_sizes_on_movement()
		if _horizontal_scroll.value == _last_scroll_movement_value and _selector_is_moving:
			user_stopped_scrolling.emit()

			if _last_scroll_movement_value == _current_selected_card_step:
				_update_current_selected_card()
				_reset_cards_to_default_size()
				function_stopped_scrolling.emit()
				_screen_just_released = false
				_level_card_just_clicked = false
				_selector_is_moving = false

		_last_scroll_movement_value = _horizontal_scroll.value 


func populate_card_container(levels:Array[Level]):
	set_physics_process(false)
	_initial_setup_done = false
	
	for child in $%CardsContainer.get_children():
		child.queue_free()
	
	available_card_buttons.clear()
	
	if levels.size() == 0: return
	for level in levels:
		var new_level_card:LevelCard = load("res://screens/sub_menus/games_menu/level_selector/level_card/level_card.tscn").instantiate()	
		new_level_card.level = level
		$%CardsContainer.add_child(new_level_card)
		
		if not level.level_unlocked: # Level Unlocked Textures Check
			new_level_card.enemy_thumbnail.modulate = Color(0,0,0,1)
			new_level_card.level_thumbnail.modulate = Color(0.5,0.5,0.5,1) 
			new_level_card.level_reward_thumbnail.modulate = Color(0,0,0,1)
		new_level_card.get_child(0).pressed.connect(_on_level_card_pressed.bind(new_level_card.level))
	
	var padding_in : Control = $%CardsContainer.add_spacer(true)
	var padding_out : Control = $%CardsContainer.add_spacer(false)
	
	padding_in.custom_minimum_size.x = control_paddings_size
	padding_out.custom_minimum_size.x = control_paddings_size

func start_initial_setup(new_value:Level):
	_add_card_buttons_to_array()
	_initial_selected_level = new_value
	set_physics_process(true)

func _on_level_card_pressed(new_value:Level):
	card_clicked.emit(new_value)

func _move_cards_to_initial_offset(new_value:Level):
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard
#		printt("Initial Offset: ", new_value.level_name)
		
		if card.level == new_value:
			_horizontal_scroll.value = _card_selection_step * ii
			_current_selected_card_step = _card_selection_step * ii
			_update_current_selected_card()

func move_to_clickled_level_card(new_value:Level):
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard
		
		if card.level == new_value:
			_level_card_just_clicked = true
			set_physics_process(true)
			
			var tween = create_tween()
			tween.tween_property(_horizontal_scroll, "value", float(_card_selection_step * ii), 1).set_ease(Tween.EASE_OUT)

			_current_selected_card_step = _card_selection_step * ii
			await function_stopped_scrolling
			set_physics_process(false)
			return


func _control_card_sizes_on_movement():
		var initial_card_growing_position : float 
		var initial_card_reducing_position : float
		var final_card_reducing_position : float
		var scale_value_per_pixel : float
		
		for ii in available_card_buttons.size():
			var card = available_card_buttons[ii] as LevelCard
			var card_right_corner_position : float = card.global_position.x + card.size.x
			
			var card_label : Label = card.title_label
			var card_level_tumbnail : TextureRect = card.level_thumbnail
			var card_enemy_thumbnail : TextureRect = card.enemy_thumbnail
			var card_reward_thumbnail : TextureRect = card.level_reward_thumbnail

			@warning_ignore("integer_division")
			initial_card_growing_position = _viewport_center_position + (card.size.x / 2) + (_cards_container_separation / 2) if _selector_moving_left else _viewport_center_position - ((card.size.x / 2) + (_cards_container_separation / 2))
			@warning_ignore("integer_division")
			initial_card_reducing_position = _viewport_center_position - (card.size.x / 2) - (_cards_container_separation / 2) if _selector_moving_left else _viewport_center_position + (card.size.x / 2) + (_cards_container_separation / 2)
			@warning_ignore("integer_division")
			final_card_reducing_position = initial_card_reducing_position - (card.size.x - (_cards_container_separation/2)) if _selector_moving_left else initial_card_reducing_position + (card.size.x + (_cards_container_separation/2))
			@warning_ignore("integer_division")
			scale_value_per_pixel = _value_to_scale_in_size / (initial_card_growing_position - (initial_card_reducing_position + (_cards_container_separation / 2))) if _selector_moving_left else _value_to_scale_in_size / ((initial_card_reducing_position - (_cards_container_separation / 2)) - initial_card_growing_position ) 


#-------DRAGGING LEFT--------------------
				# CARD BTN TEXTURE GROWING 
			if card.global_position.x < initial_card_growing_position and card.global_position.x >= initial_card_reducing_position + (_cards_container_separation / 2.0):
				var scale_value = (initial_card_growing_position - card.global_position.x) * scale_value_per_pixel
				var tween = create_tween()
				tween.tween_property(card.get_child(0), "custom_minimum_size", Vector2(_base_texture_size.x * (1 + scale_value), _base_texture_size.y* (1 + scale_value)), .2).set_ease(Tween.EASE_IN)

				card_label.scale = Vector2(_card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)), _card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)))

				card_level_tumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_enemy_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_reward_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)

					# CARD BTN TEXTURE REDUCING
			elif card.global_position.x < initial_card_reducing_position and card.global_position.x >= final_card_reducing_position:
				var scale_value = (card.global_position.x - final_card_reducing_position) * scale_value_per_pixel
				var tween = create_tween()
				tween.tween_property(card.get_child(0), "custom_minimum_size", Vector2(_base_texture_size.x * (1 + scale_value), _base_texture_size.y * (1 + scale_value)), .1).set_ease(Tween.EASE_IN)

				card_label.scale = Vector2(_card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)), _card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)))

				card_level_tumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_enemy_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_reward_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)

#-------DRAGGING RIGHT--------------------
			# CARD BTN TEXTURE GROWING 
			if card_right_corner_position > initial_card_growing_position and card_right_corner_position <= initial_card_reducing_position - (_cards_container_separation / 2.0):
				var scale_value = (card_right_corner_position - initial_card_growing_position) * scale_value_per_pixel
				var tween = create_tween()
				tween.tween_property(card.get_child(0), "custom_minimum_size", Vector2(_base_texture_size.x * (1 + scale_value), _base_texture_size.y* (1 + scale_value)), .1).set_ease(Tween.EASE_IN)

				card_label.scale = Vector2(_card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)), _card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)))

				card_level_tumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_enemy_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_reward_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)

			# CARD BTN TEXTURE REDUCING
			elif card_right_corner_position >= initial_card_reducing_position and card_right_corner_position < final_card_reducing_position:
				var scale_value = (final_card_reducing_position - card_right_corner_position) * scale_value_per_pixel
				var tween = create_tween()
				tween.tween_property(card.get_child(0), "custom_minimum_size", Vector2(_base_texture_size.x * (1 + scale_value), _base_texture_size.y* (1 + scale_value)), .1).set_ease(Tween.EASE_IN)

				card_label.scale = Vector2(_card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)), _card_label_base_scale + (scale_value/ (1 + _value_to_scale_in_size)))

				card_level_tumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_enemy_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)
				card_reward_thumbnail.scale = Vector2(1 + scale_value, 1 + scale_value)


func _move_to_selected_card_step():
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard
		var btn_centered_position_x : float
		btn_centered_position_x = card.global_position.x + (card.size.x / 2) - ii # ii because of default HBox separation of 1px
		@warning_ignore("integer_division")
		var initial_position_of_center_card = _viewport_center_position - (card.size.x/2) - (_cards_container_separation / 2) 
		@warning_ignore("integer_division")
		var final_position_of_center_card =  _viewport_center_position + (card.size.x/2) + (_cards_container_separation / 2)

		if btn_centered_position_x > initial_position_of_center_card and btn_centered_position_x < final_position_of_center_card:
			
			# CARD BTN TEXTURE MOVING TO CENTER OF VIEWPORT
			var tween = create_tween()
			tween.tween_property(_horizontal_scroll, "value", float(_card_selection_step * ii), 0.1).set_ease(Tween.EASE_OUT)

			_current_selected_card_step = _card_selection_step * ii
			await function_stopped_scrolling

			set_physics_process(false)

func _add_card_buttons_to_array():
	for child in _cards_container.get_children():
		if child.is_class("CenterContainer"):
			available_card_buttons.append(child)

func _get_card_selection_step():
	_card_selection_step = (_cards_container.size.x - _level_selector.size.x) / (available_card_buttons.size() - 1) 

func _set_initial_selected_card_size():
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard
		var card_center_position_x = (card.global_position.x - 1920) + (card.size.x / 2)
		
		var resizable_button : TextureButton = card.get_child(0)
		var title_label : Label = card.title_label
		var level_thumbnail : TextureRect = card.level_thumbnail
		var enemy_thumbnail : TextureRect = card.enemy_thumbnail
		var reward_thumbnail : TextureRect = card.level_reward_thumbnail

		if card_center_position_x == _viewport_center_position + 0.25 or card_center_position_x == (0.25 - _viewport_center_position):
			
			_base_texture_size = resizable_button.size # Getting Button base size before changing it on next line

			resizable_button.custom_minimum_size = Vector2(card.size.x, card.size.y)
#			resizable_button.scale = Vector2(1 + _value_to_scale_in_size, 1 + _value_to_scale_in_size)
			level_thumbnail.scale = Vector2(1 + _value_to_scale_in_size, 1 + _value_to_scale_in_size)
			enemy_thumbnail.scale = Vector2(1 + _value_to_scale_in_size, 1 + _value_to_scale_in_size)
			reward_thumbnail.scale = Vector2(1 + _value_to_scale_in_size, 1 + _value_to_scale_in_size)
			title_label.scale = Vector2(_card_label_base_scale + (_value_to_scale_in_size / 1.5), _card_label_base_scale + (_value_to_scale_in_size / 1.5))

		else:
			title_label.scale = Vector2(_card_label_base_scale, _card_label_base_scale)

func _update_current_selected_card():
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard 

		if (_current_selected_card_step / _card_selection_step) == ii:
			_current_selected_card = card
			card_selected.emit(card.level)
			return

func _reset_cards_to_default_size():
	for ii in available_card_buttons.size():
		var card = available_card_buttons[ii] as LevelCard 

		if (_current_selected_card_step / _card_selection_step) != ii:
			card.get_child(0).custom_minimum_size = Vector2(_base_texture_size.x, _base_texture_size.y)
			card.title_label.pivot_offset = card.title_label.size / 2 
			card.title_label.scale = Vector2(_card_label_base_scale, _card_label_base_scale)


