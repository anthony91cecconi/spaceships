extends TextureButton
class_name ServerUI

@onready var labelName: Label = $LabelName
@onready var labelAddress: Label = $LabelAddress
@onready var labelPlayers: Label = $LabelPlayers
var server_data : ServerDataDto 

var color : Color
	

# Questa funzione riceve i dati e aggiorna la grafica in modo sicuro
func setup(_server_data: Dictionary) -> void:
	server_data = ServerDataDto.from_dictionary(_server_data)
	if not is_inside_tree():
		await ready
	set_color()
	labelName.text = server_data.name
	labelAddress.text = server_data.ip + ":" + str(server_data.port)
	labelPlayers.text = str(server_data.currentPlayers) + "/" + str(server_data.maxPlayers)
	labelPlayers.add_theme_color_override("font_color",color)

func set_color() -> void:
	if server_data.currentPlayers < server_data.maxPlayers: 
		color = Color.GREEN
	else:
		color = Color.RED
		disabled = true


func _on_pressed() -> void:
	var lobby = preload("res://scenes/core/lobby/lobby.tscn").instantiate()
	
	lobby.server_data = server_data
	get_tree().root.add_child(lobby)
	get_tree().current_scene.queue_free()
