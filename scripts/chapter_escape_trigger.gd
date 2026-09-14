extends InteractableBase
class_name ChapterEscapeTrigger
## 챕터 2 이후 공용 탈출 트리거 — 챕터 1의 마루 밑 판자와 같은 역할.
## 아이템 3개를 모두 모아야 실제로 상호작용이 탈출로 이어진다(사람
## 피드백, 2026-09-14 "탈출 트리거를 수행하면 나오는 식으로 임의
## 구성한다", DESIGN.md §11). 탈출하면 "N장 종료" 타이틀 카드를 띄운 뒤
## `next_scene`으로 전환한다 — 마지막 챕터가 아니면 다시 일상
## (`chapter1_real.tscn`)으로, 마지막 챕터면 임시 엔딩 화면으로.
## `advances_story`가 true면 탈출 성공 시 `ChapterProgress.current_chapter`
## 를 1 올려서 `NapTrigger`가 다음 챕터로 분기하게 한다.
##
## 대사는 전부 placeholder — 진짜 스토리 내용이 아니라 "아이템 3개 +
## 탈출 구조가 실제로 작동하는지" 확인용 틀이다.

@export var chapter_number: int = 2
@export var locked_line: String = "아직 뭔가 부족한 느낌이다."
@export var already_escaped_line: String = "이미 지나온 곳이다."
@export var escape_lines: Array[String] = ["마지막 조각을 맞추자, 문이 스르르 열린다."]
@export var title_text: String = "2장 종료"
@export var next_scene: String = ""
@export var advances_story: bool = true

func _on_interact() -> void:
	if ChapterProgress.is_escaped(chapter_number):
		DialogueSystem.start_dialogue([already_escaped_line])
		return
	if not ChapterProgress.all_items_collected(chapter_number):
		DialogueSystem.start_dialogue([locked_line])
		return
	ChapterProgress.set_escaped(chapter_number)
	if advances_story:
		ChapterProgress.current_chapter = chapter_number + 1
	DialogueSystem.dialogue_ended.connect(_on_escape_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueSystem.start_dialogue(escape_lines)

func _on_escape_dialogue_ended() -> void:
	await ChapterTitleCard.show_title(title_text)
	var fade := get_tree().get_first_node_in_group("fade_overlay")
	if fade:
		fade.fade_to_scene(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)
