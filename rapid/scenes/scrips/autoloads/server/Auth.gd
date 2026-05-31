extends Node

const AUTH_URL = "http://93.38.52.145:8089/auth"

signal login_riuscito
signal login_fallito(error: String)
signal register_riuscito
signal register_fallito(error: String)

var _http: HTTPRequest

func _ready():
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

var _last_action: String = ""

func login(email: String, password: String) -> void:
	_last_action = "login"
	var body = JSON.stringify({ "email": email, "password": password })
	_http.request(AUTH_URL + "/login", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)

func register(username: String, email: String, password: String) -> void:
	_last_action = "register"
	var body = JSON.stringify({ "username": username, "email": email, "password": password })
	_http.request(AUTH_URL + "/register", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)

func validate(token: String) -> void:
	_last_action = "validate"
	_http.request(AUTH_URL + "/validate", ["Authorization: Bearer " + token], HTTPClient.METHOD_GET)

func _on_request_completed(_result, response_code, _headers, body):
	var data = JSON.parse_string(body.get_string_from_utf8())

	match _last_action:
		"login":
			if response_code == 200:
				PlayerManager.create_authenticated_player(
					data["user"]["username"],
					str(data["user"]["id"]),
					data.get("token", "")
				)
				login_riuscito.emit()
			else:
				var error = data.get("message", "Errore sconosciuto")
				D.error("Login fallito: " + error)
				login_fallito.emit(error)

		"register":
			if response_code == 201:
				D.success("Registrazione riuscita")
				register_riuscito.emit()
			else:
				var error = data.get("message", "Errore sconosciuto")
				D.error("Registrazione fallita: " + error)
				register_fallito.emit(error)

		"validate":
			if response_code == 200 and data.get("valid", false):
				D.success("Token valido: " + data.get("username", ""))
			else:
				D.error("Token non valido")
