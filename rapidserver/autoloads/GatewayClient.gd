extends Node

const IP_SERVICE_URL = "https://api.ipify.org"
const GATEWAY_BASE = "http://93.38.52.145:8090/servers"
const MAX_RETRIES = 10
const RETRY_INTERVAL = 5.0

var public_ip := ""
var server_id := ""
var retry_count := 0

var _http_ip: HTTPRequest
var _http_register: HTTPRequest
var _http_update: HTTPRequest

func _ready():
	_http_ip = HTTPRequest.new(); add_child(_http_ip)
	_http_ip.request_completed.connect(_on_ip_completed)

	_http_register = HTTPRequest.new(); add_child(_http_register)
	_http_register.request_completed.connect(_on_register_completed)

	_http_update = HTTPRequest.new(); add_child(_http_update)

	# Ascolta il segnale di Network quando i giocatori cambiano
	Network.giocatori_cambiati.connect(_aggiorna_gateway)

	D.normal("Recupero IP pubblico...")
	_http_ip.request(IP_SERVICE_URL)

func _on_ip_completed(_result, response_code, _headers, body):
	if response_code == 200:
		public_ip = body.get_string_from_utf8().strip_edges()
		D.success("IP pubblico: " + public_ip)
		_registrati()
	else:
		D.error("IP non ottenuto, riprovo...")
		await get_tree().create_timer(RETRY_INTERVAL).timeout
		_http_ip.request(IP_SERVICE_URL)

func _registrati():
	var body = JSON.stringify({
		"name": Network.SERVER_NAME,
		"ip": public_ip,
		"port": Network.SERVER_PORT,
		"maxPlayers": Network.MAX_PLAYERS,
		"pingport": Network.PING_PORT
	})
	_http_register.request(
		GATEWAY_BASE + "/register",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST, body
	)
	D.normal("Tentativo registrazione %d/%d" % [retry_count + 1, MAX_RETRIES])

func _on_register_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		server_id = data.get("id", "")
		retry_count = 0
		D.success("Registrato! id=" + server_id)
	else:
		retry_count += 1
		if retry_count < MAX_RETRIES:
			await get_tree().create_timer(RETRY_INTERVAL).timeout
			_registrati()
		else:
			D.error("Gateway irraggiungibile dopo %d tentativi." % MAX_RETRIES)

func _aggiorna_gateway(count: int):
	if server_id == "":
		return
	var url = GATEWAY_BASE + "/" + server_id + "/players"
	var body = JSON.stringify({ "currentPlayers": count })
	_http_update.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_PATCH, body)
