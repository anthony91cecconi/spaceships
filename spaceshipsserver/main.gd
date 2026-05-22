extends Node

const GATEWAY_URL = "http://93.38.52.145:8090/servers/register"
const SERVER_NAME = "Server Alpha"
const SERVER_IP = "93.38.52.145"
const SERVER_PORT = 7777
const PING_PORT = 7778
const MAX_PLAYERS = 100

var tcp_server := TCPServer.new()
var http_request : HTTPRequest

func _ready():
	# Avvia il ping server
	tcp_server.listen(PING_PORT)
	print("Ping server in ascolto sulla porta ", PING_PORT)
	
	# Registrati al gateway
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_register_completed)
	
	var body = JSON.stringify({
		"name": SERVER_NAME,
		"ip": SERVER_IP,
		"port": SERVER_PORT,
		"maxPlayers": MAX_PLAYERS,
		"pingport" : PING_PORT
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(GATEWAY_URL, headers, HTTPClient.METHOD_POST, body)
	D.normal("Registrazione al gateway in corso...")

func _process(_delta):
	# Ascolta le richieste di ping in arrivo
	if tcp_server.is_connection_available():
		var conn = tcp_server.take_connection()
		var risposta = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
		conn.put_data(risposta.to_utf8_buffer())
		conn.disconnect_from_host()

func _on_register_completed(result, response_code, headers, body):
	if response_code == 200:
		D.success("Registrato al gateway con successo!")
	else:
		D.error("Errore registrazione: "+ str(response_code))
