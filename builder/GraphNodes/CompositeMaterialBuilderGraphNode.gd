@tool
extends GraphNode
class_name CompositeMaterialBuilderGraphNode

@export var represented_resource_variable_name : String = ""
@export var set_represented_resource_map : Dictionary[String, String] = {}

@export var title_bar_color : Color = Color.DARK_KHAKI

signal request_disconnect_self

var _rename_button : Button
var _confirm_button : Button
signal request_edit_title
signal request_stop_editing_title

func _node_ready() -> void: ##Called after _ready() by [CompositeMaterialBuilderGraphNode] to allow extending classes to extend _ready() functionality without overriding base behavior.
	pass

func _ready() -> void:
	theme = preload("res://addons/CompositeMaterial/builder/graph_node_default_theme.tres")
	
	if self is not CompositeMaterialOutputNode:
		_rename_button = Button.new()
		_rename_button.flat = true
		_rename_button.icon = EditorInterface.get_base_control().get_theme_icon("Edit", "EditorIcons")
		get_titlebar_hbox().add_child(_rename_button)
		
		_confirm_button = Button.new()
		_confirm_button.flat = true
		_confirm_button.icon = EditorInterface.get_base_control().get_theme_icon("ImportCheck", "EditorIcons")
		get_titlebar_hbox().add_child(_confirm_button)
		_confirm_button.visible = false
		
		if !_confirm_button.is_connected("button_down", request_stop_editing_title.emit): #just for preventing errors when the template page gets loaded in
			_confirm_button.button_down.connect(request_stop_editing_title.emit)
			_rename_button.button_down.connect(start_capturing_keyboard)
	
	_node_ready()


func start_capturing_keyboard() -> void:
	print("start_capturing_keyboard()")
	title = ""
	
	_rename_button.release_focus()
	_rename_button.visible = false
	_confirm_button.visible = true
	selected = false
	
	
	print("emit signal")
	request_edit_title.emit()

func stop_capturing_keyboard() -> void:
	print("stop_capturing_keyboard()")
	_confirm_button.release_focus()
	_rename_button.visible = true
	_confirm_button.visible = false

func update_title(new_title : String) -> void:
	title = new_title
	get(represented_resource_variable_name).variable_name = new_title

func connect_and_pass_object(input_port_id : int, object : Object) -> void: ##Override this method to be able to process connections.
	pass

func get_represented_object(port_idx : int) -> Object: ##This method must be overridden to provide values in the case of connections.
	printerr("get_represented_object has not been overridden yet: ", self)
	return null

func set_represented_object(object : Object) -> void:
	printerr("set_represented_object has not been overridden yet: ", self)
	pass
	#set(represented_resource_variable_name, object)

func disconnected(input_port_id : int) -> void:
	get(represented_resource_variable_name).initialise_value(input_port_id)
