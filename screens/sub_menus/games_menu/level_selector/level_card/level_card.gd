@tool
class_name LevelCard extends CenterContainer

@export var level: Level : set = _set_level

@onready var title_label : Label = $"%TitleLabel"
@onready var level_thumbnail : TextureRect = $"%LevelThumbnail"
@onready var level_reward_thumbnail : TextureRect = $"%RewardThumbnail"
@onready var enemy_thumbnail : TextureRect = $"%EnemyThumbnail"

func _set_level(new_value: Level) -> void:	
	level = new_value	
	_set_card()

func _set_card()-> void:
	$"%LevelThumbnail".texture = level.level_thumbnail
	$"%EnemyThumbnail".texture = level.enemy_thumbnail
	$"%RewardThumbnail".texture = GlobalConstants.ally_thumbnails_list[level.ally_presentation.ally_thumbnail] 
	$"%TitleLabel".text = level.level_name


