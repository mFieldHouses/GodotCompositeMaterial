@tool
extends CompositeMaterialBuilderGraphNode
class_name LayerNode

var represented_layer : CompositeMaterialLayer = CompositeMaterialLayer.new()

var capturing_keyboard : bool = false

var _rename_button : Button
var _confirm_button : Button

func _node_ready() -> void:
	if Engine.is_editor_hint():
		node_selected.connect(EditorInterface.edit_resource.bind(represented_layer))
	
	represented_layer.roughness_value.value = 0.5
	represented_layer.metallic_value.value = 0.5
	
	_rename_button = Button.new()
	_rename_button.flat = true
	_rename_button.icon = EditorInterface.get_base_control().get_theme_icon("Edit", "EditorIcons")
	get_titlebar_hbox().add_child(_rename_button)
	_rename_button.button_down.connect(start_capturing_keyboard)
	
	_confirm_button = Button.new()
	_confirm_button.flat = true
	_confirm_button.icon = EditorInterface.get_base_control().get_theme_icon("ImportCheck", "EditorIcons")
	get_titlebar_hbox().add_child(_confirm_button)
	_confirm_button.button_down.connect(stop_capturing_keyboard)
	_confirm_button.visible = false
	

func start_capturing_keyboard() -> void:
	capturing_keyboard = true
	title = ""
	
	_rename_button.release_focus()
	_rename_button.visible = false
	_confirm_button.visible = true
	selected = false

func stop_capturing_keyboard() -> void:
	capturing_keyboard = false
	
	_confirm_button.release_focus()
	_rename_button.visible = true
	_confirm_button.visible = false
	

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and capturing_keyboard:
		if event.pressed:
			
			var _ignored_keys = [KEY_SHIFT, KEY_CTRL, KEY_TAB, KEY_CAPSLOCK]
			
			if event.keycode in _ignored_keys:
				return
			
			if event.keycode == KEY_ENTER:
				stop_capturing_keyboard()
			elif event.keycode == KEY_SPACE:
				title += " "
			elif event.keycode == KEY_BACKSPACE:
				title = title.left(title.length() - 1)
			else:
				if Input.is_key_pressed(KEY_SHIFT):
					title += event.as_text_key_label().trim_prefix("Shift+")
				else:
					title += event.as_text_key_label().to_lower()

func enable_value(idx : int, state : bool = true) -> void:
	match idx:
		0:
			$roughness_in/value.editable = state
		1:
			$metallic_in/value.editable = state
			
func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_layer.albedo = object
		1:
			represented_layer.normal = object
		2:
			represented_layer.roughness_value = object
		3:
			represented_layer.metallic_value = object
		4:
			represented_layer.mask = object

func get_represented_object() -> Object:
	return represented_layer
