extends Control

@onready var name_label : Label =  $LabelName

var player : PlayerInfoDto

func set_player_info(p:PlayerInfoDto) -> void:
	player = p
	set_labels()
	
	
func set_labels() -> void:
	name_label.text = player.player_name
