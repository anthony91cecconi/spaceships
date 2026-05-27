extends Node
class_name ServerDataDto
var ip : String 
var server_name : String
var port : int
var currentPlayers :int
var maxPlayers : int

func _init(_ip : String, _server_name : String, _port : int, _currentPlayers : int, _maxPlayers : int = 100 ) -> void:
	ip = _ip
	server_name = _server_name
	port = _port
	currentPlayers = _currentPlayers
	maxPlayers = _maxPlayers

static func from_dictionary(_server_data : Dictionary) -> ServerDataDto:
	return ServerDataDto.new(
		_server_data.get("ip",""),
		_server_data.get("name",""),
		_server_data.get("port"),
		_server_data.get("currentPlayers",0),
		_server_data.get("maxPlayers",100)
	)
