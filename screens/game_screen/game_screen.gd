class_name GameScreen extends Control

const _ALLY_CARD_SCENE_PATH : String = "res://screens/game_screen/ally_card_selector/ally_card/ally_card.tscn"
const _DEFAULT_TWEEN_ANIMATION_TIME : float = 0.5

@export var level: Level

var _game_screen_user_data : GameScreenUserData = UserDataManager.user_data.game_screen_user_data

var _remove_ally_button_selected : bool
var _selected_ally_scene : PackedScene
var _allies : Array[Ally]
var _remaining_enemies_count : int 
var _allies_scenes : Dictionary
var _available_ally_slots : int

@onready var _background : TextureRect = $Background as TextureRect
@onready var _foreground : TextureRect = $Foreground as TextureRect
@onready var _card_selector : AllyCardSelector = $CardSelector as AllyCardSelector
@onready var _terrain_grid = $TerrainGrid as TerrainGrid
@onready var _balance_displayer = $BalanceDisplayer as BalanceDisplayer
@onready var _enemy_spawners : EnemySpawners = $EnemySpawners
@onready var _allies_selector_popup : AlliesSelectorPopup = $AlliesSelectorPopup
@onready var _game_over_popup : GameOverPopup = $GameOverPopup
@onready var _paused_game_popup : PausedGamePopup = $PausedGamePopup
@onready var _game_won_popup : GameWonPopup = $GameWonPopup
@onready var _remaining_enemies_count_label : Label = $RemainingEnemiesCount
@onready var _game_progress_line : GameProgressLine = $GameProgressLine
@onready var _remove_ally_button : RemoveAllyButton = $RemoveAllyButton
@onready var _last_column_enemy_detectors : LastColumnEnemyDetectors = $LastColumnEnemyDetectors
@onready var _row_cannons : RowCannons = $RowCannons
@onready var _pause_game_button : TextureButton = $PauseGameButton
@onready var _game_start_count_down : GameStartCountDown = $GameStartCountdown
@onready var _preview_enemies_rows : PreviewEnemiesRows = $PreviewEnemiesRows
@onready var _pause_btn_pressed_player : SFXPlayer = $PauseBtnPressedPlayer
@onready var _coin_picked_up_player : SFXPlayer = $CoinPickedUpPlayer
@onready var _ally_card_selected_player : SFXPlayer = $AllyCardSelectedPlayer
@onready var _new_ally_located_player : SFXPlayer = $NewAllyLocatedPlayer
@onready var _enemies_arrived_player : SFXPlayer = $EnemiesArrivedPlayer
@onready var _user_balance_displayer : UserBalanceDisplayer = $UserBalanceDisplayer

func _ready():
	_set_initial_variables()
	_set_game_screen_user_data()
	_set_popups()
	_set_terrain_grid()
	_connect_signals()
	_set_enemy_detectors()
	_set_row_cannons()
	
	_make_initial_transition_right()

func _set_initial_variables():
	var player_user_data : PlayerUserData = UserDataManager.user_data.player_user_data
	
	_background.texture = level.game_background
	_foreground.texture = level.game_foreground
	_foreground.set_z_index(9)
	_set_background_position()

	_balance_displayer.set_z_index(13)
	_user_balance_displayer.set_z_index(13)
	_user_balance_displayer.balance = player_user_data.player_balance

	_card_selector.set_z_index(10)
	_available_ally_slots = player_user_data.unlocked_ally_slots
	_preview_enemies_rows.total_enemies_to_display = level.displayed_preview_enemies
	_preview_enemies_rows.all_level_enemies = level.level_enemies
	
#	_pause_game_button.set_z_index(2)
	_pause_game_button.disabled = true
	_pause_game_button.visible = false
	
#	_remove_ally_button.set_z_index(2)
	_remove_ally_button.disabled = true
	_remove_ally_button.visible = false
	
	_balance_displayer.visible = false
	_row_cannons.visible = false
	
#	_game_progress_line.set_z_index(2)
	_game_progress_line.visible = false
	_add_value_to_balance(level.starting_balance)
	
	
func _set_background_position():
	match level.game_background_position:
		"left":
			_background.position.x = 0
		"center":
			_background.position.x = -1920
		"right":
			_background.position.x = -3840
	
func _set_popups():
	_game_over_popup.set_z_index(10)
	_game_over_popup.visible = false
	_game_over_popup.level_to_replay = level.duplicate(true)
	
	_paused_game_popup.set_z_index(10)
	_paused_game_popup.visible = false
	_paused_game_popup.level_to_replay = level.duplicate(true)
	
	_game_won_popup.set_z_index(10)
	_game_won_popup.visible = false
	_game_won_popup.level_to_replay = level.duplicate(true)

func _set_game_screen_user_data():
	_game_screen_user_data.playable_rows = level.playable_rows

func _set_row_cannons():
	_row_cannons.set_z_index(10)
	_row_cannons.initial_setup(level.playable_rows)

func _set_terrain_grid():
	_terrain_grid.set_enabled_cells(level.playable_rows)
	
func _connect_signals():
	_enemy_spawners.wave_finished.connect(_on_enemy_spawners_wave_finished)
	_enemy_spawners.wave_started.connect(_on_enemy_spawners_wave_started)
	_enemy_spawners.enemy_died.connect(_on_enemy_spawners_enemy_died)
	_enemy_spawners.enemy_spawned.connect(_on_enemy_spawners_enemy_spawned)
	_enemy_spawners.wave_flagged.connect(_on_enemy_spawners_wave_flagged)
	_enemy_spawners.total_spawning_time_calculated.connect(_on_enemy_spawners_total_spawning_time_calculated)

	_allies_selector_popup.allies_chosen.connect(_on_allies_selector_allies_chosen)
	_last_column_enemy_detectors.enemy_reached_last_column.connect(_on_enemy_detector_enemy_reached_last_column)
	_terrain_grid.cell_pressed.connect(_on_terrain_grid_cell_pressed)
	_terrain_grid.coin_picked_up.connect(_on_terrain_grid_coin_picked_up)
	_terrain_grid.coin_for_cell_requested.connect(_on_terrain_grid_coin_for_cell_requested)
	_terrain_grid.ally_for_cell_requested.connect(_on_terrain_grid_ally_for_cell_requested)
	_card_selector.connect("ally_selected", _on_card_selector_ally_selected)
	_card_selector.ally_card_loaded.connect(_on_card_selector_card_loaded)
	_game_start_count_down.count_down_finished.connect(_on_game_start_count_down_finished)

func _start_initial_cards_display():
	var ally_cards : Array[AllyCard] = []
	var all_allies_scenes : Array[PackedScene] = []
	
	for ii in level.level_allies.size():
		var ally_scene = level.level_allies[ii]
		var ally : Ally = ally_scene.instantiate() as Ally
		
		if level.level_allies.size() <= _available_ally_slots:
			var ally_card : AllyCard = load(_ALLY_CARD_SCENE_PATH).instantiate() as AllyCard
			_allies.append(ally)
			ally_cards.append(ally_card)
			ally_card.set_initial_variables(ally)
		else:
			all_allies_scenes.append(ally_scene)
		
		_allies_scenes[ally.ally_name] = ally_scene
		
	if level.level_allies.size() <= _available_ally_slots:
		_card_selector.start_initial_display(ally_cards)
		_update_cards_affordability()
		_card_selector.visible = true
		
	else:
		_allies_selector_popup.maximum_choosable_allies = _available_ally_slots
		_allies_selector_popup.start_initial_display(all_allies_scenes)

func _disable_all_ally_card_buttons():
	_card_selector.disable_all_ally_card_buttons()

func _enable_all_ally_card_buttons():
	_card_selector.enable_all_ally_card_buttons()

func _update_cards_affordability():
	_card_selector.update_cards_affordability(_balance_displayer.balance)
	
func _set_terrain_grid_coin_dropping_rate():
	_terrain_grid.coin_dropping_rate = level.coin_dropping_rate
	
func _set_enemy_spawners():
	_enemy_spawners.unsorted_enemy_scenes = level.level_enemies
	_enemy_spawners.initial_setup(level.playable_rows)

func _set_enemy_detectors():
	_last_column_enemy_detectors.playable_rows = level.playable_rows

func _set_remaining_enemies_count():
	_remaining_enemies_count = _enemy_spawners.total_enemies_to_spawn
	_remaining_enemies_count_label.text = str(_remaining_enemies_count)

func _get_allies_selector_popup_display() -> bool:
	if level.level_allies.size() > _available_ally_slots:
		return true
	else:
		return false

func _make_initial_transition_right():
	var display_allies_selector_popup : bool = _get_allies_selector_popup_display()
	
	if display_allies_selector_popup:
		MusicManager.play_allies_selector_popup_stream()
	else:
		MusicManager.play_game_stream(level)
		
	await get_tree().create_timer(2).timeout
	
	_move_screen_to_right_side()
	await get_tree().create_timer(2).timeout

	if display_allies_selector_popup:
		_start_initial_cards_display()
		_allies_selector_popup.visible = true
	else:
		_pause_game_button.disabled = true
		_row_cannons.visible = true
		_move_screen_to_left_side()
		
		await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME + 1).timeout
		_preview_enemies_rows.queue_free()
		
		_game_start_count_down.start_count_down()

		_start_initial_cards_display()
		_disable_all_ally_card_buttons()
		await get_tree().create_timer(_game_start_count_down.total_count_down_time * 2).timeout
		_enable_all_ally_card_buttons()

func _move_screen_to_right_side():
	var tween = create_tween()
	tween.tween_property($".", "position", Vector2(-565, 0), _DEFAULT_TWEEN_ANIMATION_TIME)

func _move_screen_to_left_side():
	var tween = create_tween()
	var card_selector_is_active : bool = _card_selector.get_child_count() != 0
	
	tween.tween_property($".", "position", Vector2(0, 0), _DEFAULT_TWEEN_ANIMATION_TIME)
	
	if card_selector_is_active:
		var tween2 = create_tween()
		
		tween2.tween_property(_card_selector, "position", Vector2(0,155), _DEFAULT_TWEEN_ANIMATION_TIME)
		

func _add_value_to_balance(value_to_add : int):
	_balance_displayer.add_value_to_balance(value_to_add)

func _substract_value_from_balance(value_to_substract : int):
	_balance_displayer.substract_value_from_balance(value_to_substract)

func _get_ally_from_scene(ally_scene:PackedScene) -> Ally:
	var returned_ally : Ally
	
	for ally in _allies:
		if _allies_scenes[ally.ally_name] == ally_scene:
			returned_ally = ally
			return returned_ally
	
	return returned_ally

func _add_ally(cell: Cell):
	if _selected_ally_scene != null:
		var selected_ally : Ally = _get_ally_from_scene(_selected_ally_scene)

		if _terrain_grid.cell_is_available_for_selected_ally(cell, _selected_ally_scene) == true:
			_new_ally_located_player.play_sound()
			_card_selector.start_selected_card_loading_process() # Enable for Card Loading Process
			_substract_value_from_balance(_card_selector.selected_card.price)
			
			if selected_ally is ThrowableAlly:
				_terrain_grid.place_falling_ally_in_cell(cell, _selected_ally_scene)
			
			if selected_ally is SpecialAlly:
				_terrain_grid.place_special_ally_in_cell(cell, _selected_ally_scene)
			
			if not selected_ally is ThrowableAlly and not selected_ally is SpecialAlly:
				_terrain_grid.place_ally_in_cell(cell, _selected_ally_scene)
			
			_update_cards_affordability()
		
			_selected_ally_scene = null
			if _card_selector.selected_card:
				_card_selector.selected_card.is_selected = false
			_card_selector.selected_card = null
		
	else:
#		printt("ally not added")
		pass

func _calculate_element_falling_time(cell_name : String) -> float:
	var element_falling_time : float
	if cell_name.begins_with("Row1"):
		element_falling_time = 1
	elif cell_name.begins_with("Row2"):
		element_falling_time = 1.2
	elif cell_name.begins_with("Row3"):
		element_falling_time = 1.4
	elif cell_name.begins_with("Row4"):
		element_falling_time = 1.6
	elif cell_name.begins_with("Row5"):
		element_falling_time = 1.8
	return element_falling_time

func _calculate_coin_falling_time(cell_name : String) -> float:
	var coin_falling_time : float
	if cell_name.begins_with("Row1"):
		coin_falling_time = 3
	elif cell_name.begins_with("Row2"):
		coin_falling_time = 4
	elif cell_name.begins_with("Row3"):
		coin_falling_time = 5
	elif cell_name.begins_with("Row4"):
		coin_falling_time = 6
	elif cell_name.begins_with("Row5"):
		coin_falling_time = 7
	return coin_falling_time

func _update_remaining_enemies_count():
	_remaining_enemies_count -= 1
	_remaining_enemies_count_label.text = str(_remaining_enemies_count)
	if _remaining_enemies_count == 0:
		await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME).timeout
		_display_game_won_popup()

func _get_element_z_index(cell_name:String) -> int:
	var element_z_index : int
	if cell_name.begins_with("Row1"):
		element_z_index = 1
	if cell_name.begins_with("Row2"):
		element_z_index = 3
	if cell_name.begins_with("Row3"):
		element_z_index = 5
	elif cell_name.begins_with("Row4"):
		element_z_index = 7
	elif cell_name.begins_with("Row5"):
		element_z_index = 9
	
	return element_z_index

func _display_game_won_popup():
	if _game_won_popup.level_reward_ally_already_adquired:
		_show_user_balance_displayer(level.level_coins_reward)
	elif _game_won_popup.special_coin_reward_activated:
		_show_user_balance_displayer(level.special_coin_reward)
		
		
	if level.background_transitioning_level:
		if level is LevelSnowstorm:
			
			_move_screen_to_left_side()
			await get_tree().create_timer(2).timeout
			
			_card_selector.visible = false
			_balance_displayer.visible = false
			_pause_game_button.visible = false
#			_game_progress_line.visible = false
			_row_cannons.position.x -= 1920
			_row_cannons.display_all_row_cannons()
			
			_move_screen_to_right_side()
			await get_tree().create_timer(2).timeout
			
			_move_screen_to_next_level_position(true)
			
			await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME * 4).timeout
			
		elif level is LevelTrenches:
			var terrain_tween = create_tween()
			var cannons_tween = create_tween()

		
			terrain_tween.tween_property(_terrain_grid, "position", Vector2(_terrain_grid.position.x + 1920, _terrain_grid.position.y), _DEFAULT_TWEEN_ANIMATION_TIME * 4)
			cannons_tween.tween_property(_row_cannons, "position", Vector2(_row_cannons.position.x + 1920, _row_cannons.position.y), _DEFAULT_TWEEN_ANIMATION_TIME * 4)
			
			_move_screen_to_next_level_position(false)
			await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME * 6).timeout
	
	
	get_tree().paused = true
	_game_won_popup.visible = true


func _move_screen_to_next_level_position(moving_left:bool):
	if moving_left:
		var tween = create_tween()
	
		tween.tween_property($".", "position", Vector2(self.position.x + 2484, 0), _DEFAULT_TWEEN_ANIMATION_TIME * 4)
		_game_won_popup.position.x -= 1920
	else:
		var first_tween = create_tween()
	
		first_tween.tween_property($".", "position", Vector2(self.position.x - 2484, 0), _DEFAULT_TWEEN_ANIMATION_TIME * 4)
		
		await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME * 4).timeout
		var second_tween = create_tween()
		
		second_tween.tween_property($".", "position", Vector2(self.position.x + 564, 0), _DEFAULT_TWEEN_ANIMATION_TIME)
		_game_won_popup.position.x += 1920

func _show_user_balance_displayer(coins_to_add:int):
	_user_balance_displayer.position.y += _user_balance_displayer.displayer_texture.size.y
	_user_balance_displayer.add_coins_to_balance(coins_to_add)

func _on_terrain_grid_cell_pressed(cell:Cell):
	if not cell.is_occupied:
		
		_add_ally(cell)
	elif cell.is_occupied and _remove_ally_button_selected:
		_terrain_grid.remove_ally_from_cell(cell)
		_remove_ally_button.is_selected = false
		
func _on_terrain_grid_coin_for_cell_requested(coin:RubleCoin, cell:Cell):
	var coin_falling_time : float = _calculate_coin_falling_time(cell.name)
	var coin_z_index : int = _get_element_z_index(cell.name)

	self.add_child(coin)
	coin.set_z_index(coin_z_index)
	coin.picked_up.connect(_on_terrain_grid_coin_picked_up.bind(level.falling_coin_value))
	coin.timer_wait_time = 14.5
	coin.global_position.x = cell.global_position.x + (cell.size.x / 4)
	coin.global_position.y = -(coin.size.y / 2) 
	
	var tween = create_tween()
	tween.tween_property(coin, "global_position", Vector2(cell.global_position.x + (cell.size.x / 4), cell.global_position.y + (cell.size.y / 4)), coin_falling_time)

func _on_terrain_grid_ally_for_cell_requested(ally:Ally, cell:Cell):
	var ally_falling_time : float = _calculate_element_falling_time(cell.name)
	var ally_z_index : int = _get_element_z_index(cell.name)
	
	self.add_child(ally)
	
	ally.falling_time = ally_falling_time
	ally.set_z_index(ally_z_index)
	ally.global_position.x = cell.global_position.x + (cell.size.x / 2)
	ally.global_position.y = -ally.ally_size.y
	
	var tween = create_tween()
	
	tween.tween_property(ally, "global_position", Vector2(ally.global_position.x, cell.global_position.y + (cell.size.y/2.5)), ally_falling_time)
	
	ally.background.global_position = self.global_position
	
func _on_terrain_grid_coin_picked_up(coin_value : int):
	_coin_picked_up_player.play_sound()
	_balance_displayer.add_value_to_balance(coin_value)
	_update_cards_affordability()

func _on_card_selector_ally_selected(selected_ally_name : String):
	if selected_ally_name != "":
		for ii in _allies.size():
			var ally = _allies[ii]
			if ally.ally_name == selected_ally_name:
				_ally_card_selected_player.play_sound()
				_selected_ally_scene = _allies_scenes[ally.ally_name]
	else:
		_selected_ally_scene = null
		
	if _remove_ally_button_selected:
		_remove_ally_button_selected = false
		_remove_ally_button.is_selected = false

func _on_enemy_spawners_enemy_died():
	_update_remaining_enemies_count()
	
func _on_enemy_spawners_total_spawning_time_calculated(total_spawning_time:float):
	_game_progress_line.total_spawning_time = total_spawning_time

func _on_enemy_spawners_enemy_spawned(wait_time:float):
	_game_progress_line.make_head_advance(wait_time)

func _on_enemy_spawners_wave_flagged(wave_time_position:float):
	_game_progress_line.add_flagged_wave(wave_time_position)

func _on_enemy_spawners_wave_started(wave_index:int):
	if wave_index == 0:
		_enemies_arrived_player.play_sound()
		_game_progress_line.visible = true

func _on_enemy_spawners_wave_finished(_wave_index:int):
	pass
#		print("Game Screen Wave Finished: ", wave_index)

func _on_allies_selector_allies_chosen(chosen_level_allies : Array[Ally]):
	var ally_cards : Array[AllyCard] = []
	
	MusicManager.play_game_stream(level)
	
	for ii in chosen_level_allies.size():
		var ally : Ally = chosen_level_allies[ii]
		var ally_card : AllyCard = load(_ALLY_CARD_SCENE_PATH).instantiate() as AllyCard
		_allies.append(ally)
		ally_cards.append(ally_card)
		ally_card.set_initial_variables(ally)

	_allies = chosen_level_allies
	
	_card_selector.position = Vector2(565,155)
	_card_selector.start_initial_display(ally_cards)
	_card_selector.visible = true
	_update_cards_affordability()
	_allies_selector_popup.queue_free()
	
	_pause_game_button.disabled = true
	_row_cannons.visible = true
	
	_move_screen_to_left_side()
	await get_tree().create_timer(_DEFAULT_TWEEN_ANIMATION_TIME + 1).timeout
	
	_preview_enemies_rows.queue_free()
	
	_game_start_count_down.start_count_down()

func _on_game_start_count_down_finished():
	_set_terrain_grid_coin_dropping_rate()
	_set_enemy_spawners()
	_set_remaining_enemies_count()
	_pause_game_button.disabled = false
	_pause_game_button.visible = true
	_remove_ally_button.disabled = false
	_remove_ally_button.visible = true
	_balance_displayer.visible = true
	
	await get_tree().create_timer(2).timeout
	_game_start_count_down.queue_free()

func _on_card_selector_card_loaded():
	_update_cards_affordability()

func _on_go_back_button_pressed():
	var menus_screen : Node = load("res://screens/menus/menus.tscn").instantiate()
	
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)

func _on_enemy_detector_enemy_reached_last_column(row_number:int):
	_row_cannons.shoot_in_row(row_number)
	
func _on_game_over_detector_body_entered(body):
	if body is Enemy:
		get_tree().paused = true
		_game_over_popup.visible = true

func _on_pause_game_button_pressed():
	_pause_btn_pressed_player.play_sound()
	_paused_game_popup.visible = true
	get_tree().paused = true

func _on_remove_ally_button_pressed():
	if not _remove_ally_button_selected:
		_remove_ally_button.is_selected = true
		_remove_ally_button_selected = true
	else:
		_remove_ally_button.is_selected = false
		_remove_ally_button_selected = false
		
	if _selected_ally_scene != null:
		_selected_ally_scene = null
		_card_selector.selected_card.is_selected = false
		_card_selector.selected_card = null
