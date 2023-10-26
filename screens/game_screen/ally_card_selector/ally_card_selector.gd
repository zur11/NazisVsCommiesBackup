class_name AllyCardSelector extends VBoxContainer

signal ally_selected(ally_name : String)
signal ally_card_loaded()

var selected_card : AllyCard


func start_initial_display(ally_cards : Array[AllyCard]):
	for card in ally_cards:
		var ally_card : AllyCard = card
		self.add_child(ally_card)
		ally_card.initiate_card()
		ally_card.set_z_index(6)
		ally_card.connect("card_selected", _on_ally_card_selected)
		ally_card.connect("card_loaded", _on_ally_card_loaded)
		ally_card.card_unselected.connect(_on_ally_card_unselected)

func disable_all_ally_card_buttons():
	for child in self.get_children():
		child.disabled = true

func enable_all_ally_card_buttons():
	for child in self.get_children():
		child.disabled = false

func start_selected_card_loading_process():
	selected_card.start_loading_process()

func update_cards_affordability(balance : int):
	for card in self.get_children():
		var ally_card : AllyCard = card as AllyCard
		if ally_card.price <= balance:
			ally_card.is_affordable = true
		else:
			ally_card.is_affordable = false

func _on_ally_card_selected(_selected_card : AllyCard):
	if selected_card == _selected_card and selected_card != null:
		selected_card.is_selected = false
		selected_card = null
		ally_selected.emit("")
		return
		
	if selected_card != null and selected_card.is_selected:
		selected_card.is_selected = false

	selected_card = _selected_card
	ally_selected.emit(selected_card.ally.ally_name)

func _on_ally_card_unselected():
	selected_card = null
	ally_selected.emit("")

func _on_ally_card_loaded():
	ally_card_loaded.emit()

