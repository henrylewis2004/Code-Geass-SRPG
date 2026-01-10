class_name BodyAnimationFrames

func getSplit(character:String,emotion: String) -> Vector2:
	match(character):
		"exmaple":
			match(emotion):
				"exmaple": return Vector2(5,1)

				"exmapl2e": return Vector2(1,1)
				
				_: return Vector2(3,1)
				
		_: return Vector2(3,1)
