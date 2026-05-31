extends Node

signal lobby_aggiornata(count: int)
signal lobby_lista_aggiornata(list: Array)

var _peer: ENetMultiplayerPeer = null

func connetti_a_server(ip: String, port: int) -> void:
	D.normal("Network: tento connessione a %s:%d" % [ip, port])
	_peer = ENetMultiplayerPeer.new()
	var err = _peer.create_client(ip, port)
	D.debug("Network: create_client err=%d" % err)
	if err != OK:
		D.error("Network: impossibile connettersi a %s:%d" % [ip, port])
		return
	multiplayer.multiplayer_peer = _peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected():
	# Connessione riuscita — ci presentiamo al server mandando il nostro DTO come dizionario
	D.success("Network: connesso al server")
	introduce_yourself.rpc_id(1, PlayerManager.player_info.from_dto_to_dict())

func _on_failed():
	D.error("Network: connessione fallita")

func _on_server_disconnected():
	D.debug("Network: server disconnesso")

# Dichiarata anche qui ma non fa nulla sul client — serve a Godot per sapere che esiste
@rpc("any_peer", "reliable")
func introduce_yourself(_player_data: Dictionary):
	pass

# Il server chiama questa su tutti i client quando il numero cambia
@rpc("authority", "reliable")
func update_players(count: int):
	lobby_aggiornata.emit(count)

# Il server chiama questa su tutti i client quando la lista cambia
@rpc("authority", "reliable")
func update_players_list(list: Array):
	lobby_lista_aggiornata.emit(list)


func log_off() -> void:
	if _peer:
		multiplayer.multiplayer_peer = null
		_peer = null
		D.normal("Network: disconnesso dal server")

signal messaggio_ricevuto(username: String, text: String, timestamp: String)

# Chiamata dal client per mandare un messaggio
func invia_messaggio(text: String) -> void:
	send_message.rpc_id(1, text)

# Dichiarata qui ma non fa nulla — serve a Godot per sapere che esiste
@rpc("any_peer", "reliable")
func send_message(_text: String):
	pass

# Il server chiama questa su tutti i client
@rpc("authority", "reliable")
func receive_message(username: String, text: String, timestamp: String):
	messaggio_ricevuto.emit(username, text, timestamp)
