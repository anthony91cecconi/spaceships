extends Node

signal lobby_aggiornata(count: int)

var _peer: ENetMultiplayerPeer = null

func connetti_a_server(ip: String, port: int) -> void:
	_peer = ENetMultiplayerPeer.new()
	var err = _peer.create_client(ip, port)
	if err != OK:
		push_error("Network: impossibile connettersi a %s:%d" % [ip, port])
		return
	multiplayer.multiplayer_peer = _peer
	multiplayer.connected_to_server.connect(_on_connesso)
	multiplayer.connection_failed.connect(_on_fallito)
	multiplayer.server_disconnected.connect(_on_server_disconnesso)

func _on_connesso():
	print("Network: connesso al server")

func _on_fallito():
	print("Network: connessione fallita")

func _on_server_disconnesso():
	print("Network: server disconnesso")

@rpc("authority", "reliable")
func aggiorna_giocatori(count: int):
	lobby_aggiornata.emit(count)
