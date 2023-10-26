class_name AlliesSelectorScrollContainer extends ScrollContainer

signal grid_card_chosen(chosen_card:ChoosableAllyCard)

const _SCROLL_CONTAINER_THEME_PATH : String = "res://screens/game_screen/allies_selector_popup/allies_selector_scroll_container/scroll_container_theme.tres"

@export var vertical_scroll_grabber : Texture

@onready var _vertical_scroll_bar : VScrollBar = $"_v_scroll" #self.get_v_scroll_bar()
@onready var _choosable_cards_grid : ChoosableCardsGrid = $"%ChoosableCardsGrid"

func _ready():
	_set_initial_variables()
	_connect_signals() 

func add_card_to_choosable_cards_grid(ally_card:ChoosableAllyCard):
	_choosable_cards_grid.add_and_connect_grid_card(ally_card)

func get_card_from_choosable_cards_grid(ally:Ally) -> ChoosableAllyCard:
	var requested_card : ChoosableAllyCard = _choosable_cards_grid.get_ally_card(ally)
	
	return requested_card

func _set_initial_variables():
	self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var scroll_container_theme : Theme = load(_SCROLL_CONTAINER_THEME_PATH)
	
	_vertical_scroll_bar.theme = scroll_container_theme
	_vertical_scroll_bar.set_z_index(100)

func _connect_signals():
	_choosable_cards_grid.connect("grid_card_pressed", _on_cards_grid_card_pressed)

func _on_cards_grid_card_pressed(pressed_card:ChoosableAllyCard):
	grid_card_chosen.emit(pressed_card)
