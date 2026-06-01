extends Node

const AUTH_URL = "http://93.38.52.145:8089/auth"
const SESSION_FILE = "user://session.dat"

signal login_riuscito
signal login_fallito(error: String)
signal register_riuscito
signal register_fallito(error: String)
signal auto_login_riuscito
signal auto_login_fallito

var _http: HTTPRequest
var _last_action: String = ""

func _ready():
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

# --- Azioni pubbliche ---

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

func refresh() -> void:
	# Tenta il refresh usando il token salvato su disco
	var session = _load_session()
	if session.is_empty() or not session.has("refresh_token"):
		auto_login_fallito.emit()
		return
	_last_action = "refresh"
	var body = JSON.stringify({ "refreshToken": session["refresh_token"] })
	_http.request(AUTH_URL + "/refresh", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)

func logout() -> void:
	var session = _load_session()
	if session.has("refresh_token"):
		_last_action = "logout"
		var body = JSON.stringify({ "refreshToken": session["refresh_token"] })
		_http.request(AUTH_URL + "/logout", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	_clear_session()
	PlayerManager.jwt_token = ""
	PlayerManager.player_info = null

# --- Sessione su disco ---

func salva_sessione(jwt: String, refresh_token: String) -> void:
	var data = JSON.stringify({ "jwt": jwt, "refresh_token": refresh_token })
	var file = FileAccess.open(SESSION_FILE, FileAccess.WRITE)
	file.store_string(data)
	file.close()

func _load_session() -> Dictionary:
	if not FileAccess.file_exists(SESSION_FILE):
		return {}
	var file = FileAccess.open(SESSION_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return {}
	return data

func _clear_session() -> void:
	if FileAccess.file_exists(SESSION_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SESSION_FILE))

# --- Gestione risposte ---

func _on_request_completed(_result, response_code, _headers, body):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data == null:
		data = {}

	match _last_action:
		"login":
			if response_code == 200:
				_salva_e_autentica(data)
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

		"refresh":
			if response_code == 200:
				# Il refresh può restituire un nuovo refresh token (sliding expiration)
				_salva_e_autentica(data)
				D.success("Auto login riuscito: " + PlayerManager.player_info.player_name)
				auto_login_riuscito.emit()
			else:
				# Refresh token scaduto — login obbligatorio
				_clear_session()
				D.normal("Sessione scaduta, login necessario")
				auto_login_fallito.emit()

		"logout":
			D.normal("Logout completato")

func _salva_e_autentica(data: Dictionary) -> void:
	var jwt = data.get("token", "")
	var refresh_token = data.get("refreshToken", "")
	PlayerManager.create_authenticated_player(
		data["user"]["username"],
		str(data["user"]["id"]),
		jwt
	)
	salva_sessione(jwt, refresh_token)
