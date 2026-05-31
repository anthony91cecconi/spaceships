extends VBoxContainer

@onready var player_label: Label = $PlayerLabel
@onready var time_label: Label = $TimeLabel
@onready var content: RichTextLabel = $RichTextLabelCointent

func setup(username: String, text: String, timestamp: String) -> void:
	player_label.text = username
	time_label.text = timestamp
	content.text = text
