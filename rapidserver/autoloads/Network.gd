extends Node

const SERVER_NAME = "Server Alpha"
const SERVER_PORT = 7777
const PING_PORT = 7778
const MAX_PLAYERS = 100

signal giocatori_cambiati(count: int)

var giocatori_connessi := 0

var _tcp_server := TCPServer.new()

func _ready():
	_avvia_ping()
	_avvia_enet()

func _avvia_ping():
	_tcp_server.listen(PING_PORT)
	D.normal("Ping server in ascolto sulla porta " + str(PING_PORT))

func _avvia_enet():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	if err != OK:
		D.error("Impossibile avviare ENet sulla porta " + str(SERVER_PORT))
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	D.success("ENet in ascolto sulla porta " + str(SERVER_PORT))

func _on_player_connected(id: int):
	giocatori_connessi += 1
	D.normal("Connesso id=%d — totale=%d" % [id, giocatori_connessi])
	aggiorna_giocatori.rpc(giocatori_connessi)
	giocatori_cambiati.emit(giocatori_connessi)

func _on_player_disconnected(id: int):
	giocatori_connessi -= 1
	D.normal("Disconnesso id=%d — totale=%d" % [id, giocatori_connessi])
	aggiorna_giocatori.rpc(giocatori_connessi)
	giocatori_cambiati.emit(giocatori_connessi)

@rpc("authority", "reliable")
func aggiorna_giocatori(_count: int):
	pass  # eseguito solo nel client

func _process(_delta):
	if _tcp_server.is_connection_available():
		var conn = _tcp_server.take_connection()
		await get_tree().create_timer(0.1).timeout
		if conn.get_available_bytes() > 0:
			conn.get_data(conn.get_available_bytes())
		var risposta = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\nContent-Length: 2\r\n\r\nOK"
		conn.put_data(risposta.to_utf8_buffer())
		conn.disconnect_from_host()
