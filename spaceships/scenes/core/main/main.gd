extends CanvasLayer

# La versione attuale di questo specifico APK installato
const CURRENT_VERSION = "0.0.1"
const VERSION_CHECK_URL = "https://raw.githubusercontent.com/anthony91cecconi/spaceships/refs/heads/main/version.json"

@onready var http_request = $HTTPRequest
@onready var progress_bar = $ProgressBar
@onready var info_label = $Label

var download_url = ""
var sta_scaricando = false

func _ready():
	progress_bar.visible = false
	info_label.text = "Verifica aggiornamenti in corso..."
	
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request(VERSION_CHECK_URL)
	if error != OK:
		info_label.text = "Errore di connessione. Impossibile avviare il gioco."

func _process(_delta):
	if sta_scaricando:
		var body_size = http_request.get_body_size()
		var downloaded_bytes = http_request.get_downloaded_bytes()
		
		if body_size > 0:
			var percentuale = (float(downloaded_bytes) / float(body_size)) * 100
			progress_bar.value = percentuale
			info_label.text = "Aggiornamento obbligatorio in corso: " + str(int(percentuale)) + "%"

func _on_request_completed(result, response_code, headers, body):
	if not sta_scaricando:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			
			var latest_version = response["latest_version"]
			download_url = response["download_url"]
			
			if latest_version != CURRENT_VERSION:
				_avvia_download_automatico()
			else:
				info_label.text = "Gioco aggiornato! Avvio in corso..."
				_avvia_gioco_normale()
		else:
			info_label.text = "Errore di rete. Impossibile verificare gli aggiornamenti."

	else:
		sta_scaricando = false
		if response_code == 200:
			info_label.text = "Download completato! Apertura installatore..."
			
			var percorso_salvataggio = OS.get_user_data_dir() + "/update.apk"
			
			OS.shell_open(ProjectSettings.globalize_path(percorso_salvataggio))
		else:
			info_label.text = "Errore durante il download dell'aggiornamento. Riprova più tardi."
			progress_bar.visible = false

func _avvia_download_automatico():
	progress_bar.visible = true
	progress_bar.value = 0
	info_label.text = "Nuova versione trovata. Download dell'aggiornamento..."
	
	var percorso_salvataggio = OS.get_user_data_dir() + "/update.apk"
	
	http_request.set_download_file(percorso_salvataggio)
	
	sta_scaricando = true
	var error = http_request.request(download_url)
	if error != OK:
		info_label.text = "Errore nell'avviare il download automatico."
		sta_scaricando = false

func _avvia_gioco_normale():
	# Inserisci qui il codice per far partire il tuo gioco 
	# Ad esempio il cambio scena verso il menu principale:
	# get_tree().change_scene_to_file("res://MenuPrincipale.tscn")
	pass
