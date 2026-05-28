extends Node

const SERVER_NAME = "Server Alpha"
const SERVER_PORT = 7777
const PING_PORT = 7778
const MAX_PLAYERS = 100

signal giocatori_cambiati(count: int)

var connected_players := 0

# Dizionario che mappa enet_id -> PlayerInfoDto
var players: Dictionary = {}

var _tcp_server := TCPServer.new()

func _ready():
	_start_ping()
	_start_enet()

func _start_ping():
	_tcp_server.listen(PING_PORT)
	D.normal("Ping server in ascolto sulla porta " + str(PING_PORT))

func _start_enet():
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
	# Un peer si è connesso — aspettiamo che si presenti con introduce_yourself
	connected_players += 1
	D.normal("Connesso enet_id=%d — totale=%d" % [id, connected_players])
	update_players.rpc(connected_players)
	giocatori_cambiati.emit(connected_players)

func _on_player_disconnected(id: int):
	# Recuperiamo il nome prima di rimuoverlo, utile per il log
	var pname = players[id].player_name if players.has(id) else "sconosciuto"
	players.erase(id)
	connected_players -= 1
	D.normal("Disconnesso enet_id=%d (%s) — totale=%d" % [id, pname, connected_players])
	update_players.rpc(connected_players)
	giocatori_cambiati.emit(connected_players)
	# Notifichiamo tutti della lista aggiornata
	_notify_players_list()

# Il client chiama questa appena connesso per mandarci i suoi dati
# get_remote_sender_id() ci dice quale peer enet l'ha chiamata
@rpc("any_peer", "reliable")
func introduce_yourself(player_data: Dictionary):
	var enet_id = multiplayer.get_remote_sender_id()
	# Ricostruiamo il DTO dal dizionario ricevuto
	var player = PlayerInfoDto.from_dict_to_dto(player_data)
	players[enet_id] = player
	D.normal("Giocatore presentato: %s (player_id=%s, enet_id=%d)" % [player.player_name, player.player_id, enet_id])
	# Aggiorniamo la lista per tutti appena qualcuno si presenta
	_notify_players_list()

# Costruisce la lista e la manda a tutti i client
func _notify_players_list():
	var list = []
	for enet_id in players:
		list.append(players[enet_id].from_dto_to_dict())
	update_players_list.rpc(list)

# Dichiarata anche qui ma eseguita solo nel client
@rpc("authority", "reliable")
func update_players(_count: int):
	pass

# Dichiarata anche qui ma eseguita solo nel client
@rpc("authority", "reliable")
func update_players_list(_list: Array):
	pass

func _process(_delta):
	# Rispondiamo al ping HTTP del gateway
	if _tcp_server.is_connection_available():
		var conn = _tcp_server.take_connection()
		await get_tree().create_timer(0.1).timeout
		if conn.get_available_bytes() > 0:
			conn.get_data(conn.get_available_bytes())
		var response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\nContent-Length: 2\r\n\r\nOK"
		conn.put_data(response.to_utf8_buffer())
		conn.disconnect_from_host()
