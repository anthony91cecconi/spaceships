extends Node
class_name Debugger

# =================================================
# CONFIG COLORI ANSI
# =================================================
var configs := {
	"focus":   35,
	"progres":   30,
	"normal":  37,
	"debug":   36,
	"success": 32,
	"warn":    33,
	"error":   31
}

var counter_logs : Array[DebugCount] = []

# =================================================
# PUBLIC API
# =================================================
func debug(t: String) -> void:
	log_msg("debug", t)
	pass

func error(t: String) -> void:
	log_msg("error", t)

func progres(t: String) -> void:
	log_msg("progres", t)

func warn(t: String) -> void:
	log_msg("warn", t)

func success(t: String) -> void:
	log_msg("success", t)

func focus(t: String) -> void:
	log_msg("focus", t)

func normal(t: String) -> void:
	log_msg("normal", t)


# =================================================
# CORE LOGGER
# =================================================
func log_msg(level: String, text: String) -> void:
	if not OS.is_debug_build():
		return

	var color_code = configs.get(level, 37)

	print(
		#"\u001b[" + str(color_code) + "m" +
		pad_with_dashes("[" + level.to_upper() + "]--" +_get_header(),60)+
		"MESSAGE: " +text
		#"\u001b" 
	)


# =================================================
# HEADER
# =================================================
func _get_header() -> String:
	var now = Time.get_time_dict_from_system()
	var time_str := "%02d:%02d:%02d" % [
		now.hour, now.minute, now.second
	]

	var context = _get_debug_context()

	if context.is_empty():
		return time_str

	var caller_info := "file:%s line:%d " % [
		context["file"],
		context["line"]
	]
	var info = get_or_create_by_name(caller_info)
	return "["+time_str+"]" + caller_info + "(use: " + str(info.count) + ")"


# =================================================
# STACK ANALYSIS INTELLIGENTE
# =================================================
func _get_debug_context() -> Dictionary:
	var stack = get_stack()

	for frame in stack:
		if not frame.has("source"):
			continue

		var file :String= frame["source"].get_file()

		# Ignora questo file (il logger)
		if file.ends_with("Debugger.gd"):
			continue

		return {
			"file": file.get_file(),
			"line": frame["line"],
			"function": frame["function"]
		}

	return {}


func get_or_create_by_name(target_name: String) -> DebugCount:
	for obj in counter_logs:
		if obj.metod == target_name:
			obj.add()
			return obj

	# non trovato → lo creo
	var new_obj = DebugCount.new(target_name)
	counter_logs.append(new_obj)
	return new_obj

func get_caller_info(ignore_files: Array[String] = []) -> Dictionary:
	var stack = get_stack()

	for frame in stack:
		if not frame.has("source"):
			continue

		var file: String = frame["source"].get_file()

		# ignora sempre il debugger
		if file.ends_with("Debugger.gd"):
			continue

		var ignore := false
		for f in ignore_files:
			if file.ends_with(f):
				ignore = true
				break

		if ignore:
			continue

		return {
			"file": file.get_file(),
			"line": frame["line"],
			"function": frame["function"]
		}

	return {}

#esempio di uso : D.get_caller_header(["HumansManager.gd"])
func get_caller_header(ignore_files: Array[String] = []) -> String:
	var context = get_caller_info(ignore_files)

	if context.is_empty():
		return ""

	return "file:%s line:%d " % [
		context["file"],
		context["line"]
	]
	
	
func pad_with_dashes(text: String, total_length: int) -> String:
	if text.length() >= total_length:
		return text
	
	var missing := total_length - text.length()
	return text + "-".repeat(missing)

var count_order : int = 0
func debug_order(t: String) -> void:
	count_order += 1
	log_msg("debug-order", t)
