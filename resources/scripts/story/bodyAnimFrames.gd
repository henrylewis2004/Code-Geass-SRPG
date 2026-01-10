class_name BodyAnimationFrames

func getSplit(character:String,emotion: String) -> Vector2:
	match(character):
		"lelouch":
			match(emotion):
				"default": return Vector2(3,1)

				"thinking": return Vector2(3,1)
				
		"rivalz":
			match(emotion):
				"default": return Vector2(3,1)
				
				"happy": return Vector2(3,1)
				
		_: return Vector2(3,1)



	return Vector2.ZERO
