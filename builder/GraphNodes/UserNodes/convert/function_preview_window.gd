@tool
extends ColorRect

const cells_x : int = 10
const cells_y : int = 10
const HUD_COLOR1 : Color = Color(0.5, 0.5, 0.5) ##Lighter color used for the outer rectangle
const HUD_COLOR2 : Color = Color(0.2, 0.2, 0.2) ##Darker color used for the grid

@export var margin : int = 10:
	set(x):
		margin = x
		queue_redraw()
		
@export var function_args : Array[Variant] = [1.0, 0.0]:
	set(x):
		function_args = x
		queue_redraw()

func _draw() -> void:
	draw_hud()
	draw_function()

func draw_hud() -> void:	
	for i in cells_x - 1:
		draw_line(
			Vector2((get_available_width() / float(cells_x)) * (i + 1) + margin, margin),
			Vector2((get_available_width() / float(cells_x)) * (i + 1) + margin, margin + get_available_height()),
			HUD_COLOR2
		)
	
	for i in cells_y - 1:
		draw_line(
			Vector2(margin, (get_available_height() / float(cells_y)) * (i + 1) + margin),
			Vector2(margin + get_available_width(), (get_available_height() / float(cells_y)) * (i + 1) + margin),
			HUD_COLOR2
		)
	
	draw_rect(
		Rect2(
			Vector2(margin, margin), 
			Vector2(get_available_width(), get_available_height())
		), 
		HUD_COLOR1,
		false
	)
	
func draw_function() -> void:
	match get_parent().represented_config.function:
		0:
			draw_linear()
		1:
			draw_bias_gain()

func get_available_height() -> float:
	return size.y - (2.0 * float(margin))

func get_available_width() -> float:
	return size.x - (2.0 * float(margin))

func draw_linear() -> void:
	for x in get_available_width():
		var x_float : float = float(x)
		x_float = x / get_available_width()
		
		var y : float = (function_args[0] * x_float + function_args[1])
		#print(y)
		
		draw_circle(
			Vector2(x_float * get_available_width(), (1.0 - clamp(y, 0.0, 1.0)) * get_available_height()) + Vector2(margin, margin),
			1.0,
			Color.WHITE
		)

func draw_bias_gain() -> void:
	var expression : Expression = Expression.new()
	
	var err : Error = expression.parse(
		"(((t * x) / (x + (s * (t - x)) + 0.000001)) * (1.0 - bias_gain_cond(x,t))) + ((((1.0 - t) * (x - 1.0)) / ((1.0 - x) - (s * (t - x) + 0.000001)) + 1.0) * bias_gain_cond(x,t))",
		PackedStringArray(["x", "t", "s"])
	)
	
	for x in get_available_width():
		var x_float : float = float(x)
		x_float = x / get_available_width()
		
		var y : float = expression.execute([x_float, function_args[0], function_args[1]], self)
		#print(y)
		
		draw_circle(
			Vector2(x_float * get_available_width(), (1.0 - clamp(y, 0.0, 1.0)) * get_available_height()) + Vector2(margin, margin),
			1.0,
			Color.WHITE
		)

func bias_gain_cond(x : float, t : float) -> float:
	if x < t:
		return 0.0
	else:
		return 1.0
	
