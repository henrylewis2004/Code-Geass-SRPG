class_name FacePlacement

func getOffset(character:String,emotion: String) -> Vector2:
	match(character):
		"lelouch":
			match(emotion):
				"default": return Vector2(112,-62)
				
				"default2": return Vector2(113,-53)

				"thinking": return Vector2(112,-55)
				
				"happy": return Vector2(95,-57)
				
				"default_happy": return Vector2(88,-56)
				
				"angry": return Vector2(118,-49)
				
				"angry2": return Vector2(108,-57)
				
				"annoyed": return Vector2(102,-49)
				
				"geass": return Vector2(93,-57)
				
				"gun": return Vector2(83,-54)
				
				"phone": return Vector2(103,-57)
				
				"shocked": return Vector2(104,-59)
				
				"shouting_angry": return Vector2(150,-48)
				
				"smirking": return Vector2(107,-58)
				
				"smirking2": return Vector2(103,-49)
				
				"tired": return Vector2(108,-49)
				
				"typing": return Vector2(84,-41)
				
		"rivalz":
			match(emotion):
				"default": return Vector2(98,-41)
				
				"happy": return Vector2(98,-41)
				
				"confused": return Vector2(99,-40)
				
				"shocked": return Vector2(73,-25)
				
				"default_question": return Vector2(111,-57)
				
		"prince clovis":
			match(emotion):
				"emotional": return Vector2(108,-65)
				
				"angry": return Vector2(95,-73)
				
				"default": return Vector2(110,-66)
				
		"diethard":
			match(emotion):
				"sulk": return Vector2(100,-77)
				
				"happy": return Vector2(103,-73)
				
		"bartley":
			match(emotion):
				"default": return Vector2(117,-65)
				
				"sad": return Vector2(122,-51)
				
		"kallen":
			match(emotion):
				"default_angry": return Vector2(92,-34)
				
		"naoto":
			return Vector2(89,-69)
				
		"mysterious voice":
			match(emotion):
				"kallen": return Vector2(92,-34)
				
				"naoto": return Vector2(89,-69)


	return Vector2.ZERO
