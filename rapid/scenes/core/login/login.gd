extends CanvasLayer

var server_data: ServerDataDto

@onready var player_list: Control = $HBoxContainer/ScrollContainer/PlayerList
@onready var label_giocatori: Label = $LabelGiocatori

const PLAYER_CARD_SCENE = preload("res://scenes/core/lobby/assets/components/player_card/player_card.tscn")

func _ready():
	Network.lobby_aggiornata.connect(_on_lobby_aggiornata)
	Network.lobby_lista_aggiornata.connect(_on_lista_aggiornata)
	Network.connetti_a_server(server_data.ip, server_data.port)

func _on_lobby_aggiornata(count: int):
	# Aggiorniamo la label con il conteggio
	label_giocatori.text = "Giocatori: %d/%d" % [count, server_data.maxPlayers]

func _on_lista_aggiornata(list: Array):
	# Svuotiamo la lista e la ricostruiamo con le card aggiornate
	for child in player_list.get_children():
		child.queue_free()
	for player_dict in list:
		var player = PlayerInfoDto.from_dict_to_dto(player_dict)
		var card = PLAYER_CARD_SCENE.instantiate() as Control
		card.set_player_info(player)
		player_list.add_child(card)
