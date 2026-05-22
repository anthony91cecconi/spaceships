extends Node
class_name DebugCount

var metod :String
var count : int

func _init(_metod : String) -> void:
	metod = _metod
	count = 1
	
func add() -> void: 
	count += 1
