extends Node

var player_info : PlayerInfoDto

func create_custom_player(new_name: String) -> void:	
	player_info = PlayerInfoDto.create_custom_player(new_name)
