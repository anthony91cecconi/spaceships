extends CanvasLayer

var server_data: ServerDataDto

@onready var label_giocatori: Label = $LabelGiocatori  # es. "Giocatori: 3/100"

func _ready():
	Network.lobby_aggiornata.connect(_on_lobby_aggiornata)
	Network.connetti_a_server(server_data.ip, server_data.port)

func _on_lobby_aggiornata(count: int):
	label_giocatori.text = "Giocatori: %d/%d" % [count, server_data.maxPlayers]
