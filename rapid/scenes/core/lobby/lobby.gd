extends CanvasLayer

var server_data: ServerDataDto

@onready var player_list : Control = $HBoxContainer/ScrollContainer/PlayerList
@onready var label_giocatori: Label = $LabelGiocatori
var player_card : String = "res://scenes/core/lobby/assets/components/player_card/player_card.tscn"


func _ready():
	Network.lobby_aggiornata.connect(_on_lobby_aggiornata)
	Network.connetti_a_server(server_data.ip, server_data.port)

func _on_lobby_aggiornata(count: int):
	label_giocatori.text = "Giocatori: %d/%d" % [count, server_data.maxPlayers]
