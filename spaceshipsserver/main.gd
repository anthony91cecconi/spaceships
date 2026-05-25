extends Node
const GATEWAY_URL = "http://93.38.52.145:8090/servers/register"
const IP_SERVICE_URL = "https://api.ipify.org"
const SERVER_NAME = "Server Alpha"
const SERVER_PORT = 7777
const PING_PORT = 7778
const MAX_PLAYERS = 100
const MAX_RETRIES = 10
const RETRY_INTERVAL = 5.0
var retry_count = 0
var public_ip = ""
var tcp_server := TCPServer.new()
var http_ip : HTTPRequest
var http_register : HTTPRequest

func _ready():
	tcp_server.listen(PING_PORT)
	D.normal("Ping server in ascolto sulla porta " + str(PING_PORT))
	http_ip = HTTPRequest.new()
	add_child(http_ip)
	http_ip.request_completed.connect(_on_ip_completed)
	http_register = HTTPRequest.new()
	add_child(http_register)
	http_register.request_completed.connect(_on_register_completed)
	D.normal("Recupero IP pubblico...")
	http_ip.request(IP_SERVICE_URL)

func _on_ip_completed(result, response_code, headers, body):
	if response_code == 200:
		public_ip = body.get_string_from_utf8().strip_edges()
		D.success("IP pubblico rilevato: " + public_ip)
		_registrati()
	else:
		D.error("Impossibile ottenere IP pubblico, riprovo tra " + str(RETRY_INTERVAL) + "s")
		await get_tree().create_timer(RETRY_INTERVAL).timeout
		http_ip.request(IP_SERVICE_URL)

func _registrati():
	D.normal("Registro con: ip=" + public_ip + " port=" + str(SERVER_PORT) + " pingport=" + str(PING_PORT))
	var body = JSON.stringify({
		"name": SERVER_NAME,
		"ip": public_ip,
		"port": SERVER_PORT,
		"maxPlayers": MAX_PLAYERS,
		"pingport": PING_PORT
	})
	var headers = ["Content-Type: application/json"]
	http_register.request(GATEWAY_URL, headers, HTTPClient.METHOD_POST, body)
	D.normal("Tentativo registrazione " + str(retry_count + 1) + "/" + str(MAX_RETRIES))

func _on_register_completed(result, response_code, headers, body):
	if response_code == 200:
		D.success("Registrato al gateway con successo!")
		retry_count = 0
	else:
		retry_count += 1
		if retry_count < MAX_RETRIES:
			D.error("Registrazione fallita, riprovo tra " + str(RETRY_INTERVAL) + "s")
			await get_tree().create_timer(RETRY_INTERVAL).timeout
			_registrati()
		else:
			D.error("Gateway irraggiungibile dopo " + str(MAX_RETRIES) + " tentativi.")

func _process(_delta):
	if tcp_server.is_connection_available():
		var conn = tcp_server.take_connection()
		var risposta = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
		conn.put_data(risposta.to_utf8_buffer())
		conn.disconnect_from_host()
