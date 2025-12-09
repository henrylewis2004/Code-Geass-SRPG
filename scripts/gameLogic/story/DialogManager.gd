class_name DialogManager extends Control

signal playNextLine
signal playNextStage
signal endDialoge

@export var playOnStart: bool = true

#dialog text
@export var dialog_script_path: String
var textData: Variant

#timers
@onready var textTimer: Timer = $textTimer
@onready var blinkTimer: Timer = $blinkTimer
var stageFinished: bool = false

#sfx
@onready var musicPlayer : AudioStreamPlayer = $backMusic
@onready var sfxPlayer : AudioStreamPlayer = $sfx

#animation
@onready var animPlayer : AnimationPlayer = get_parent().get_node("AnimationPlayer")

#textBox
@onready var textBox_name: RichTextLabel = $base/textBox/nameLabel
@onready var textBox_text: RichTextLabel = $base/textBox/dialogText
@onready var nextIcon: Label = $base/textBox/nextIcon

const blinkTimerSpeed: float = 3


#scene dictionaries
var sceneImages: Dictionary = {}
var audioDictionary: Dictionary = {}


#character image
var facePlacement : FacePlacement = FacePlacement.new()

@onready var charImg_body: Sprite2D = $base/Control/charImg_bod
@onready var charImg_face: Sprite2D = $base/Control/charImg_face

const body_anim_hFrames: int = 100
const body_anim_vFrames: int = 200

const faceHeight: int = 18
const faceWidth: int = 32
#methods

#helper functions
func getCharImg(charName: String, emotion: String) -> Array:
	var resultArray: Array = []

	var texture: CompressedTexture2D = load("res://assets/2d/characters/story/" + charName.to_lower() + "/body/" + charName.to_lower() + "_"+ emotion.to_lower() + ".png")
	resultArray.append(texture)
	
	texture = load("res://assets/2d/characters/story/"+ charName.to_lower() + "/face/" + charName.to_lower() + "_" + emotion.to_lower() + ".png")
	resultArray.append(texture)

	return resultArray


func getMusicFile(name: String) -> AudioStreamWAV:
	var audioFile: AudioStreamWAV = load("res://assets/sfx/music/" + name.to_lower() + ".wav")
	
	return audioFile

func getSfxFile(name: String) -> AudioStreamWAV:
	var audioFile: AudioStreamWAV = load("res://assets/sfx/sfx/" + name.to_lower() + ".wav")
	
	return audioFile

#text
func parseJson(path: String) -> Variant:
	var jsonText: String = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	var error = json.parse(jsonText)

	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			print("data recieved")
			return data

		else:
			print("Unexpected Data")

	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", dialog_script_path)
		
	return null


#scene play
func getSceneScript(path:String = dialog_script_path) -> void:
	textData = parseJson(path)

	sceneImages = {}
	
	for character in textData["character_dictionary"]:
		sceneImages[character] = {}
		for emotion in textData["character_dictionary"][character]:
			var image: Array = getCharImg(character,emotion)
			sceneImages[character][emotion] = image
			
	audioDictionary = {}

	#need to implement
	for sfx in textData["music_dictionary"]["sfx"]:
		audioDictionary[sfx] = getSfxFile(sfx)
	for sfx in textData["music_dictionary"]["music"]:
		audioDictionary[sfx] = getMusicFile(sfx)
		
	createScene(textData["scene"])
	
func createScene(sceneInfo: Array) -> void:
	set_process(true)
	for stage in range(sceneInfo.size()):
		playStage(sceneInfo[stage])
		await playNextStage
		
	endDialoge.emit()
	set_process(false)
		
	
		

func playStage(stageInfo: Dictionary) -> void:
	stageFinished = false
	$base.set_visible(true)
	
	if stageInfo["animation"] != null:
		animPlayer.play(stageInfo["animation"])

	for line in range(stageInfo["lines"].size()):
		playLine(stageInfo["lines"][line])
		await playNextLine
		
	if stageInfo["animation"] != null && animPlayer.is_playing():
		await animPlayer.animation_finished

	stageFinished = true
	
	if stageInfo["lines"][0]["text"] == null:
		playNextStage.emit()
		

		
func playLine(lineInfo: Dictionary) -> void:

	#sfx
	if lineInfo["music"] != null:
		musicPlayer.stop()
		musicPlayer.stream = audioDictionary[lineInfo["music"]]
		musicPlayer.play()
		
	if lineInfo["sfx"] != null:
		sfxPlayer.stop()
		sfxPlayer.stream = audioDictionary[lineInfo["sfx"]]
		sfxPlayer.play()
	
	#text
	if lineInfo["text"] == null:
		$base.set_visible(false)
		var waitTimer: Timer = Timer.new()
		add_child(waitTimer)

		waitTimer.start(0.0001)
		await waitTimer.timeout
		playNextLine.emit()

		remove_child(waitTimer)
		waitTimer.queue_free()

	else:
		textBox_text.text = lineInfo["text"]
		textBox_name.text = lineInfo["name"]
		nextIcon.set_visible(false)
		
		textBox_text.visible_characters = 0
		
		#character Image
		updateCharImg(sceneImages[lineInfo["name"]][lineInfo["emotion"]][0], sceneImages[lineInfo["name"]][lineInfo["emotion"]][1])
		charImg_face.position = facePlacement.getOffset(lineInfo["name"].to_lower(),lineInfo["emotion"])
		
		blinkTimer.start(blinkTimerSpeed)

		for character in range(lineInfo["text"].length()):
			if textBox_text.visible_ratio >= 1:
				break

			textBox_text.visible_characters += 1
			textTimer.start(lineInfo["text_speed"])

			if character % 2 == 0:
				if charImg_body.frame >= 2:
					charImg_body.frame = 0
				else:
					charImg_body.frame += 1

			await textTimer.timeout

		
	endTextPlay()
	

func endTextPlay() -> void:
	textBox_text.visible_ratio = 1
	nextIcon.set_visible(true)

	charImg_body.frame = 0
	

func updateCharImg(bodyTexture: CompressedTexture2D, faceTexture: CompressedTexture2D) -> void:
	charImg_body.texture = bodyTexture
	charImg_body.hframes = bodyTexture.get_width() / body_anim_hFrames
	charImg_body.vframes = bodyTexture.get_height() / body_anim_vFrames
	charImg_body.frame = 0

	charImg_face.texture = faceTexture
	charImg_face.hframes = bodyTexture.get_width() / body_anim_hFrames
	charImg_face.vframes = bodyTexture.get_height() / body_anim_vFrames
	charImg_face.frame = 0
	
#engine
func input() -> void:
	if Input.is_action_just_pressed("accept"):
		if textBox_text.visible_ratio < 1:
			endTextPlay()
			return
		playNextLine.emit()
		
		if stageFinished:
			playNextStage.emit()

func _ready():
	set_process(false)
	if playOnStart:
		getSceneScript()


func _process(delta):
	input()




func _on_blink_timer_timeout():
	if charImg_face.frame >=2:
		blinkTimer.start(blinkTimerSpeed) 
		charImg_face.frame = 0
		return

	charImg_face.frame += 1
	blinkTimer.start(0.1)
