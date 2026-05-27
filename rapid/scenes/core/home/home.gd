extends CanvasLayer

const GATEWAY_URL = "http://93.38.52.145:8090/servers"

@onready var http_request = $HTTPRequest
@onready var server_list = $ScrollServerContainer/Control/ServerList
@onready var info_label = $ServerLabel

@onready var edit_name : LineEdit = $Control/Control/LineEdit

const SERVER_UI_SCENE = preload("res://scenes/core/home/assets/components/server/server.tscn")


func _ready():
	info_label.text = "Ricerca server in corso..."
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(GATEWAY_URL)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5.0
	timer.autostart = true
	timer.timeout.connect(_aggiorna_server)
	timer.start()

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		info_label.text = "Errore di connessione al gateway."
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	
	# Il gateway manda {"message": "..."} se non ci sono server
	if data.has("message"):
		info_label.text = data["message"]
		return
	
	# Altrimenti è una lista di server
	info_label.text = ""
	for server in data:
		_crea_scheda(server)

func _crea_scheda(server: Dictionary):
	var scheda = SERVER_UI_SCENE.instantiate() as ServerUI
	scheda.setup(server)
	server_list.add_child(scheda)

func _aggiorna_server():
	if not http_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		return
	for child in server_list.get_children():
		child.queue_free()
	http_request.request(GATEWAY_URL)


func _on_button_pressed() -> void:
	PlayerManager.set_player_name(edit_name.text)
