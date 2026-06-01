extends CanvasLayer

var server_data: ServerDataDto

@onready var player_list: Control = $HBoxContainer/ScrollContainer/PlayerList
@onready var send_message_button: Button = $HBoxContainer/Control/Control2/SendButton
@onready var content_message: LineEdit = $HBoxContainer/Control/Control2/LineEdit
@onready var chat_list: Control = $HBoxContainer/Control/ScrolChat/ContainerChat  # VBoxContainer o ScrollContainer

const PLAYER_CARD_SCENE = preload("res://scenes/core/lobby/assets/components/player_card/player_card.tscn")
const CHAT_TEXT_SCENE = preload("res://scenes/core/lobby/assets/components/chat_text/chat_text.tscn")

func _ready():
	Network.lobby_aggiornata.connect(_on_lobby_aggiornata)
	Network.lobby_lista_aggiornata.connect(_on_lista_aggiornata)
	Network.messaggio_ricevuto.connect(_on_messaggio_ricevuto)
	send_message_button.pressed.connect(_on_send_pressed)
	content_message.text_submitted.connect(_on_text_submitted)
	Network.connetti_a_server(server_data.ip, server_data.port)

func _on_lobby_aggiornata(_count: int):
	pass

func _on_lista_aggiornata(list: Array):
	for child in player_list.get_children():
		child.queue_free()
	for player_dict in list:
		var player = PlayerInfoDto.from_dict_to_dto(player_dict)
		var card = PLAYER_CARD_SCENE.instantiate() as Control
		card.set_player_info(player)
		player_list.add_child(card)
		card.set_labels()

func _on_send_pressed():
	_invia()

func _on_text_submitted(_text: String):
	# Permette di inviare premendo INVIO
	_invia()

func _invia():
	var text = content_message.text.strip_edges()
	if text.is_empty():
		return
	Network.invia_messaggio(text)
	content_message.text = ""

func _on_messaggio_ricevuto(username: String, text: String, timestamp: String):
	var bubble = CHAT_TEXT_SCENE.instantiate()
	chat_list.add_child(bubble)
	bubble.player_label.text = username
	bubble.time_label.text = timestamp
	bubble.content.text = text
