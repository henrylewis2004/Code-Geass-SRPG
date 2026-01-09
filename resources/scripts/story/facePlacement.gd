class_name FacePlacement

func getOffset(character:String,emotion: String) -> Vector2:
	match(character):
		"lelouch":
			match(emotion):
				"default": return Vector2(112,-62)

				"thinking": return Vector2(112,-55)
				
		"rivalz":
			match(emotion):
				"default": return Vector2(98.5,-41)
				
				"happy": return Vector2(98,-41)
		"prince clovis":
			match(emotion):
				"emotional": return Vector2(108,-65)



	return Vector2.ZERO
