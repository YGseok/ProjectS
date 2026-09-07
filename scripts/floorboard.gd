extends InteractableBase
## 마루 밑 판자 — 챕터 1 메인 퍼즐 "닫힌 일기장"의 최종 오브젝트
## (DESIGN.md §7.1). 상시 보임(1단계부터). 소지품(열쇠/나무패)과 진행
## 단계에 따라 다른 대사를 보여주다가, 4단계 + 열쇠/나무패를 모두 가진
## 상태에서만 실제로 열리며 일기 시퀀스가 재생된다.

@export var wall_mark_path: NodePath

func _on_interact() -> void:
	var p := Chapter1Progress
	if p.diary_opened:
		DialogueSystem.start_dialogue(["떼어낸 페이지를 다시 읽어본다.", "\"미워.\"", "...그 외엔 아무것도 알아볼 수 없다."])
		return
	if p.has_key and p.has_stamp:
		if p.stage >= Chapter1Progress.MAX_STAGE:
			_open_diary()
		else:
			DialogueSystem.start_dialogue(["열쇠와 나무패를 함께 넣어본다.", "...아직 뭔가 맞지 않는 느낌이다."])
		return
	if p.has_key:
		DialogueSystem.start_dialogue(["주머니 속 열쇠를 자물쇠에 넣어본다.", "...맞지 않는다.", "뭔가 하나가 더 필요할 것 같다."])
		return
	DialogueSystem.start_dialogue(["마루 판자 하나가 살짝 들떠 있다.", "밑에 뭔가 있는 것 같은데, 자물쇠가 걸려 있어 꿈쩍도 안 한다."])

func _open_diary() -> void:
	Chapter1Progress.diary_opened = true
	DialogueSystem.dialogue_ended.connect(_on_diary_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueSystem.start_dialogue([
		"열쇠와 나무패를 함께 넣자, 딸깍 소리와 함께 자물쇠가 풀린다.",
		"판자를 들어올리자 눅눅한 일기장이 나온다.",
		"습기로 페이지들이 서로 들러붙어 있다.",
		"조심스레 한 장을 떼어내는 순간, 방 안 벽 쪽에서 언뜻 무언가 스친 것 같았다.",
		"겨우 떨어진 페이지엔 단 한 단어만 겨우 읽힌다.",
		"\"미워.\"",
		"...이거, 누구 일기지?",
	])
	if not wall_mark_path.is_empty():
		var mark := get_node_or_null(wall_mark_path)
		if mark:
			mark.flash()

## DESIGN.md §7.1 "트리거(챕터 종료)": 일기 페이지를 다 읽고 나면 그
## 자체로 각성(챕터 종료)이 일어나야 한다 — 별도로 WakeTrigger까지 걸어가
## Enter를 또 누를 필요 없이, 대화가 끝나는 순간 자동으로 전환한다.
func _on_diary_dialogue_ended() -> void:
	var fade := get_tree().get_first_node_in_group("fade_overlay")
	if fade:
		fade.fade_to_scene("res://scenes/chapter1_end.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/chapter1_end.tscn")
