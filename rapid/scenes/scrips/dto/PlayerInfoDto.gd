extends Node
class_name PlayerInfoDto

var player_name: String
var player_id: String

func _init(_player_name: String, _player_id: String) -> void:
	player_name = _player_name
	player_id = _player_id 

static func create_custom_player(new_name: String, new_id: String = "") -> PlayerInfoDto:
	if new_id == "":
		new_id = generate_new_id()
	var player = PlayerInfoDto.new(new_name, new_id)
	D.debug("nome utente salvato: " + player.player_name + " id: " + player.player_id)
	return player

static func generate_new_id() -> String:
	const CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"
	var id = ""
	for i in 8:
		id += CHARS[randi() % CHARS.length()]
	return id
	
func from_dto_to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"player_id": player_id
	}

static func from_dict_to_dto(data: Dictionary) -> PlayerInfoDto:
	return PlayerInfoDto.new(
		data.get("player_name", ""),
		data.get("player_id", "")
	)
