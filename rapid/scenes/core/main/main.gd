extends CanvasLayer

const CURRENT_VERSION = "0.0.3"
const VERSION_CHECK_URL_GATEWAY = "http://93.38.52.145:8090/servers/version"
const VERSION_CHECK_URL_GITHUB = "https://raw.githubusercontent.com/anthony91cecconi/rapid/refs/heads/main/version.json"

@onready var http_request = $HTTPRequest
@onready var progress_bar = $ProgressBar
@onready var info_label = $Label
@onready var ignore_button : Button = $Button
@onready var upgrade_button : Button = $Button2

var download_url = ""
var is_downloading = false
var using_github = false

func _ready():
	#_start_normal_game()
	progress_bar.visible = false
	ignore_button.visible = false
	upgrade_button.visible = false
	ignore_button.pressed.connect(_start_normal_game)
	upgrade_button.pressed.connect(_start_automatic_download)
	info_label.text = "Verifica aggiornamenti in corso... al gateway 93.38.52.145"
	
	http_request.timeout = 5.0
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request(VERSION_CHECK_URL_GATEWAY)
	if error != OK:
		_fallback_github()

func _fallback_github():
	using_github = true
	info_label.text = "Gateway non raggiungibile. Provo con GitHub..."
	var error = http_request.request(VERSION_CHECK_URL_GITHUB)
	if error != OK:
		_modalita_offline()

func _modalita_offline():
	info_label.text = "Impossibile verificare aggiornamenti. Puoi entrare in modalità offline."
	ignore_button.visible = true

func _process(_delta):
	if is_downloading:
		var body_size = http_request.get_body_size()
		var downloaded_bytes = http_request.get_downloaded_bytes()
		
		if body_size > 0:
			var percentage = (float(downloaded_bytes) / float(body_size)) * 100
			progress_bar.value = percentage
			var downloaded_mb = float(downloaded_bytes) / 1024.0 / 1024.0
			var total_mb = float(body_size) / 1024.0 / 1024.0
			info_label.text = "Aggiornamento obbligatorio in corso: %.2f MB / %.2f MB" % [downloaded_mb, total_mb]

func _on_request_completed(_result, response_code, _headers, body):
	if not is_downloading:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			
			var latest_version = response["latest_version"]
			download_url = response["download_url"]
			
			if has_node("/root/D"):
				get_node("/root/D").call("focus", str(latest_version))
				get_node("/root/D").call("focus", str(CURRENT_VERSION))
			
			if latest_version != CURRENT_VERSION:
				info_label.text = "Nuova versione disponibile: " + latest_version + ". Vuoi aggiornare?"
				upgrade_button.visible = true
				ignore_button.visible = true
			else:
				info_label.text = "Gioco aggiornato! Avvio in corso..."
				_start_normal_game()
		else:
			if not using_github:
				_fallback_github()
			else:
				_modalita_offline()
	else:
		is_downloading = false
		if response_code == 200:
			info_label.text = "Download completato! Apri il file per installare oppure entra offline."
			upgrade_button.visible = false
			ignore_button.visible = true
			
			if OS.get_name() == "Android":
				var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
				var save_path = download_dir + "/rapid_update.apk"
				var native_path = ProjectSettings.globalize_path(save_path)
				var args = ["-a", "android.intent.action.VIEW", "-d", "file://" + native_path, "-t", "application/vnd.android.package-archive"]
				var output = []
				var exit_code = OS.execute("am", args, output, true)
				if exit_code != 0:
					info_label.text = "Aggiornamento pronto! Apri la cartella Download e clicca su rapid_update.apk — oppure entra offline."
					OS.shell_open("content://com.android.externalstorage.documents/document/primary%3ADownload")
			else:
				var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
				var save_path = download_dir + "/rapid_update.apk"
				OS.shell_open(ProjectSettings.globalize_path(save_path))
		else:
			info_label.text = "Errore durante il download. Puoi entrare in modalità offline."
			progress_bar.visible = false
			ignore_button.visible = true

func _start_automatic_download():
	upgrade_button.visible = false
	ignore_button.visible = false
	progress_bar.visible = true
	progress_bar.value = 0
	info_label.text = "Download in corso..."
	
	var download_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var save_path = download_dir + "/rapid_update.apk"
	http_request.set_download_file(save_path)
	
	is_downloading = true
	var error = http_request.request(download_url)
	if error != OK:
		info_label.text = "Errore nell'avviare il download."
		is_downloading = false
		ignore_button.visible = true

func _start_normal_game():
	get_tree().change_scene_to_file("res://scenes/core/home/home.tscn")
