extends CanvasLayer

@onready var tab_container = $HBoxContainer/Custom/TabContainer
@onready var custom_player = $HBoxContainer/Custom/TabContainer/CustomPlayer
@onready var scrap_byte_games_login = $HBoxContainer/Custom/TabContainer/ScrapByteGamesLogin
@onready var scrap_byte_btn : TextureButton = $HBoxContainer/Login/VBoxContainer/Control/HBoxContainer/ScrapByteGames
@onready var custom_player_btn : TextureButton = $HBoxContainer/Login/VBoxContainer/Control/HBoxContainer/CustomPlayerButton

func _ready() -> void:
	tab_container.tabs_visible = false
	_on_custom_player_button_pressed()

func _release_all_focus() -> void:
	scrap_byte_btn.release_focus()
	custom_player_btn.release_focus()

func _on_scrap_byte_games_pressed() -> void:
	tab_container.current_tab = 1
	_release_all_focus()
	scrap_byte_btn.grab_focus() 

# Pulsante Custom Player / Guest (Va al Tab 0)
func _on_custom_player_button_pressed() -> void:
	tab_container.current_tab = 0
	_release_all_focus()
	custom_player_btn.grab_focus() 
