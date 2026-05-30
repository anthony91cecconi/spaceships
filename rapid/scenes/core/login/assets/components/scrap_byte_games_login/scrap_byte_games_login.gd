extends Control

@onready var nick_name: LineEdit = $Control/VBoxContainer/LineEditsContainer/HBoxContainer/LineEditUser
@onready var email: LineEdit = $Control/VBoxContainer/LineEditsContainer/HBoxContainer2/LineEditEmail
@onready var password: LineEdit = $Control/VBoxContainer/LineEditsContainer/HBoxContainer3/LineEditPassword
@onready var repit_password: LineEdit = $Control/VBoxContainer/LineEditsContainer/HBoxContainer4/LineEditRepeatPassword

# Contenitori interi così li nascondi con un solo comando
@onready var nick_name_container: Control = $Control/VBoxContainer/LineEditsContainer/HBoxContainer
@onready var repit_password_container: Control = $Control/VBoxContainer/LineEditsContainer/HBoxContainer4
@onready var error_laberl : Label = $Control/VBoxContainer/LineEditsContainer/ErrorLabel


var is_register_mode: bool = false

func _ready():
	_apply_mode()
	Auth.login_riuscito.connect(_on_login_riuscito)
	Auth.login_fallito.connect(_on_login_fallito)
	Auth.register_riuscito.connect(_on_register_riuscito)

func _on_login_button_pressed() -> void:
	is_register_mode = false
	_apply_mode()

func _on_register_button_pressed() -> void:
	is_register_mode = true
	_apply_mode()

func _apply_mode() -> void:
	# Mostra i campi extra solo in modalità register
	nick_name_container.visible = is_register_mode
	repit_password_container.visible = is_register_mode

func _on_save_button_pressed() -> void:
	if not _validate():
		return

	if is_register_mode:
		Auth.register(nick_name.text, email.text, password.text)
	else:
		Auth.login(email.text, password.text)

func _validate() -> bool:
	if email.text.is_empty() or password.text.is_empty():
		D.error("Email e password obbligatori")
		return false

	if is_register_mode:
		if nick_name.text.is_empty():
			D.error("Nickname obbligatorio")
			return false
		if password.text != repit_password.text:
			D.error("Le password non coincidono")
			return false

	return true


func _on_login_riuscito():
	get_tree().change_scene_to_file(SceneManager.HOME)

func _on_login_fallito(error: String):
	D.error(error)
	error_laberl.text = str(error)

func _on_register_riuscito():
	Auth.login(email.text, password.text)
