extends CanvasLayer
@onready var new_name : LineEdit = $HBoxContainer/Custom/VBoxContainer/LineEdit
@onready var error_label_1 : Label = $HBoxContainer/Custom/VBoxContainer/ErrorLabel1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	error_label_1.text = ""
	

func _on_button_pressed() -> void:
	if new_name.text.is_empty():
		error_label_1.show()
		error_label_1.text = "nessun nome inserito"
		return
	PlayerManager.create_custom_player(new_name.text)
	get_tree().change_scene_to_file(SceneManager.HOME)

func _on_line_edit_text_change_rejected(rejected_substring: String) -> void:
		error_label_1.show()
		error_label_1.text = "nome troppo lungo"


func _on_line_edit_text_changed(new_text: String) -> void:
	error_label_1.text = ""
