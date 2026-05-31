extends Node

var player_info: PlayerInfoDto
var jwt_token: String = ""

# Per i giocatori senza account (guest)
func create_custom_player(new_name: String) -> void:
	player_info = PlayerInfoDto.create_custom_player(new_name)

# Per i giocatori autenticati tramite auth-service
func create_authenticated_player(username: String, user_id: String, token: String) -> void:
	player_info = PlayerInfoDto.new(username, user_id)
	jwt_token = token
	D.success("Giocatore autenticato: " + username + " id=" + user_id)
