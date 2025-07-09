class_name DrawManager extends Node

signal deleteDrawLine
signal deleteLineText
signal deleteLOS

const accuracyFont: Font = preload("res://assets/fonts/INVASION2000.TTF")
const fontSize: Vector2 = Vector2(0,10)

const defaultTextPos: Vector3 = Vector3(0.5,0.8,0.5)
const defaultLinePos: Vector3 = Vector3(0.5,0.75,0.5)

func drawLosLine(unitPos: Vector3, targetUnitPos: Vector3, colour: Color,offset: Vector3) -> void:
	deleteDrawLine.emit()
	
	var meshInstance: MeshInstance3D = MeshInstance3D.new()
	var immediateMesh: ImmediateMesh = ImmediateMesh.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	
	meshInstance.mesh = immediateMesh
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediateMesh.surface_begin(Mesh.PRIMITIVE_LINES,material)
	immediateMesh.surface_add_vertex(unitPos.floor() + offset)
	immediateMesh.surface_add_vertex(targetUnitPos.floor() + offset)
	immediateMesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = colour
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.6
	
	get_tree().get_root().add_child(meshInstance)
	
	await deleteDrawLine
	get_tree().get_root().remove_child(meshInstance)
	meshInstance.queue_free()
	
func losText(pos: Vector3,colour: Color, text:String) -> void:
	deleteLineText.emit()

	var textPos: Vector2 = get_parent().get_parent().get_node("BattleCam/camPivot/SpringArm3D/Camera3D").unproject_position(pos)
	
	var textLabel: Label = Label.new()
	textLabel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	textLabel.text = text
	textLabel.position = textPos - fontSize
	textLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	textLabel.add_theme_font_override("font",accuracyFont)
	
	get_tree().get_root().add_child(textLabel)

	await deleteLineText
	get_tree().get_root().remove_child(textLabel)
	textLabel.queue_free()


func drawAccText(unitPos: Vector3,targetEnemyPos: Vector3,accuracyText: String,colour: Color,offset:Vector3) -> void:
	var pos: Vector3 = abs(unitPos.floor() + targetEnemyPos.floor()) / 2 + offset
	losText(pos,colour,accuracyText)

	
func cleanLOSLine() -> void:
	deleteDrawLine.emit()
	
func cleanLOSLabel() -> void:
	deleteLineText.emit()
	
func cleanLos() -> void:
	deleteDrawLine.emit()
	deleteLineText.emit()
