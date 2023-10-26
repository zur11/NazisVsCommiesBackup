class_name EnemiesRow extends HBoxContainer

@export var row_number : int
var one_column_occupied : bool
var two_columns_occupied : bool

@onready var _column_one : Marker2D = $Column1
@onready var _column_two : Marker2D = $Column2
@onready var _column_three : Marker2D = $Column3

func add_one_enemy_to_row(enemy_scene:PackedScene):
	var enemy : Enemy = enemy_scene.instantiate() as Enemy
	
	_column_two.add_child(enemy)
	enemy.is_in_preview = true
	
	one_column_occupied = true

func add_two_enemies_to_row(enemies_scenes:Array[PackedScene]):
	var enemies : Array[Enemy] = []
	
	for ii in enemies_scenes.size():
		var enemy : Enemy = enemies_scenes[ii].instantiate() as Enemy
		enemies.append(enemy)
	
	var first_enemy : Enemy = enemies[0]
	var second_enemy : Enemy = enemies[1]
	_column_one.add_child(first_enemy)
	first_enemy.is_in_preview = true
	_column_three.add_child(second_enemy)
	second_enemy.is_in_preview = true
	
	two_columns_occupied = true
	
