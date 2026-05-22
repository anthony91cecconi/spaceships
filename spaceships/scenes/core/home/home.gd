extends CanvasLayer

const GATEWAY_URL = "http://93.38.52.145:8090/servers"

@onready var http_request = $HTTPRequest
@onready var server_list = $ScrollServerContainer/ServerList
@onready var info_label = $ServerLabel

func _ready():
	info_label.text = "Ricerca server in corso..."
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(GATEWAY_URL)

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
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	var nome = Label.new()
	nome.text = server["name"]
	
	var indirizzo = Label.new()
	indirizzo.text = server["ip"] + ":" + str(server["port"])
	
	var giocatori = Label.new()
	giocatori.text = "Giocatori: " + str(server["currentPlayers"]) + "/" + str(server["maxPlayers"])
	
	vbox.add_child(nome)
	vbox.add_child(indirizzo)
	vbox.add_child(giocatori)
	panel.add_child(vbox)
	server_list.add_child(panel)
