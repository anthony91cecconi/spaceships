extends Control

@onready var name_label : Label =  $LabelName

var player : PlayerInfoDto

func set_player_info(p:PlayerInfoDto) -> void:
	player = p
	
	
func set_labels() -> void:
	D.debug(str(player.player_name))
	name_label.text =str( player.player_name)
