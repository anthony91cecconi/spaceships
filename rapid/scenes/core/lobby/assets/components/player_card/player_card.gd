extends Control

@onready var name_label : Label =  $LabelName
@onready var exit_button : Button = $Button


var is_player : bool = false
var player : PlayerInfoDto

func _ready() -> void:
	set_player_functions()

func set_player_info(p:PlayerInfoDto) -> void:
	player = p
	
	
func set_labels() -> void:
	D.debug(str(player.player_name))
	name_label.text =str( player.player_name)
	if player.player_id == PlayerManager.player_info.player_id:
		D.debug("è il player")
		is_player = true
		set_player_functions()
		
func set_player_functions() -> void:
	if is_player:
		D.focus("set show")
		exit_button.show()
		return
		
	D.focus("set hide")
	exit_button.hide()
		


func _on_button_pressed() -> void:
	Network.log_off()
	get_tree().change_scene_to_file(SceneManager.HOME)
