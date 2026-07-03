extends Control
class_name FreeDrawCanvas

## Future feature: lets a player draw directly on their ragdoll body shape.
## Stores strokes as an array of point arrays + colors, which can be
## serialized to PNG (via a SubViewport + get_texture().get_image()) and
## sent over the network as compressed bytes, or kept purely client-side
## as a cosmetic-only local preference.

var strokes: Array[Dictionary] = []  # [{points: PackedVector2Array, color: Color, width: float}]
var current_stroke: PackedVector2Array = PackedVector2Array()
var draw_color: Color = Color.BLACK
var draw_width: float = 4.0
var is_drawing: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_drawing = true
			current_stroke = PackedVector2Array([event.position])
		else:
			is_drawing = false
			if current_stroke.size() > 1:
				strokes.append({"points": current_stroke, "color": draw_color, "width": draw_width})
			current_stroke = PackedVector2Array()
			queue_redraw()
	elif event is InputEventMouseMotion and is_drawing:
		current_stroke.append(event.position)
		queue_redraw()

func _draw() -> void:
	for stroke in strokes:
		_draw_stroke(stroke["points"], stroke["color"], stroke["width"])
	if current_stroke.size() > 1:
		_draw_stroke(current_stroke, draw_color, draw_width)

func _draw_stroke(points: PackedVector2Array, color: Color, width: float) -> void:
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, width, true)

func clear() -> void:
	strokes.clear()
	queue_redraw()
