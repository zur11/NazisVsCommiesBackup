class_name ChoosableCardsGrid extends GridContainer

signal grid_card_pressed(ally_card:ChoosableAllyCard)

const _CHOOSABLE_ALLY_CARD_SCENE_PATH : String = "res://screens/game_screen/allies_selector_popup/choosable_ally_card/choosable_ally_card.tscn"

func _ready():
	connect_added_test_cards()

func get_ally_card(ally:Ally) -> ChoosableAllyCard:
	var ally_card : ChoosableAllyCard 
	if self.get_child_count() != 0:
		for card in self.get_children() as Array[ChoosableAllyCard]:
			if card.ally == ally:
				ally_card = card
	
	return ally_card

func connect_added_test_cards():
	for card in self.get_children() as Array[ChoosableAllyCard]:
		set_and_connect_test_grid_card(card)

func set_and_connect_test_grid_card(ally_card:ChoosableAllyCard):
	ally_card.set_z_index(6)
	ally_card.connect("pressed", _on_grid_card_pressed.bind(ally_card))

func add_and_connect_grid_card(ally_card:ChoosableAllyCard):
	self.add_child(ally_card)
	ally_card.initialize_card()
	ally_card.set_z_index(6)
	ally_card.connect("pressed", _on_grid_card_pressed.bind(ally_card))

func _on_grid_card_pressed(pressed_card:ChoosableAllyCard):
	grid_card_pressed.emit(pressed_card)
