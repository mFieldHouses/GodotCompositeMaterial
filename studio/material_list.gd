@tool
extends Control

var _dragging : bool = false
var _dragging_offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/drag.gui_input.connect(_drag_bar_received_input)
	get_tree().get_first_node_in_group("root_control").config_loaded.connect(_load_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _drag_bar_received_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			_toggle_collapse()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_dragging_offset = get_local_mouse_position()
	
	if event is InputEventMouseMotion and _dragging:
		position += event.relative
		#position = clamp(position, Vector2(0.0, 0.0), get_parent().size)

func _toggle_collapse() -> void:
	#custom_minimum_size.x = $VBoxContainer/material_list.size.x
	$VBoxContainer/material_list.visible = !$VBoxContainer/material_list.visible
	
	if $VBoxContainer/material_list.visible:
		$VBoxContainer/drag/Label.text = "Material List"
	else:
		$VBoxContainer/drag/Label.text = "Material List ..."

func _load_scene(scene_config : Dictionary) -> void:
	_update_material_list(scene_config.instance)

func _update_material_list(scene : Node3D) -> void:
	for _child in $VBoxContainer/material_list.get_children():
		_child.queue_free()
	
	var _material_paths : Array[String] = []
	
	for _child in _get_children_recursive(scene):
		if _child is MeshInstance3D:
			var _child_material : Material = _child.mesh.surface_get_material(0)
			if _child_material != null:
				if !_child_material.resource_path.get_file().contains("::") and not _child_material.resource_path in _material_paths: #check whether the material is an internally created one
					var _new_button := Button.new()
					_new_button.text = _child_material.resource_path.get_file()
					_new_button.flat = true
					_new_button.custom_minimum_size.y = 40
					$VBoxContainer/material_list.add_child(_new_button)
					
					_new_button.pressed.connect(func(): EditorInterface.edit_resource(load(_child_material.resource_path)))
					
					_material_paths.append(_child_material.resource_path)
					EditorInterface.get_resource_previewer().queue_resource_preview(_child_material.resource_path, self, "_receive_preview_thumbnail", _new_button)


func _receive_preview_thumbnail(path : String, preview : Texture2D, thumbnail_preview : Texture2D, userdata : Variant) -> void:
	userdata.icon = preview

func _get_children_recursive(node : Node) -> Array[Node]:
	var _result : Array[Node] = []
	var _children_to_be_checked : Array[Node] = []
	
	for _child in node.get_children():
		_children_to_be_checked.append(_child)
	
	while _children_to_be_checked.size() > 0:
		var _child_to_check : Node = _children_to_be_checked[0]
		for _subchild in _child_to_check.get_children():
			_children_to_be_checked.append(_subchild)
		
		_result.append(_child_to_check)
		_children_to_be_checked.erase(_child_to_check)
	
	return _result
