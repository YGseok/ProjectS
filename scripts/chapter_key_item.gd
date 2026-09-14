extends InteractableBase
class_name ChapterKeyItem
## 챕터 2 이후 공용 "열쇠 조각" 오브젝트 — 챕터 1의 사방치기/장독과 같은
## 역할이지만, 챕터가 늘어나도 재사용할 수 있게 범용화했다(사람 피드백,
## 2026-09-14 "키 아이템 3개를 찾고... 임의 구성한다", DESIGN.md §11).
## `chapter_number`로 어느 챕터 진행 상태(`ChapterProgress`)에 기록할지,
## `item_index`(0~2)로 그 챕터의 아이템 3개 중 어느 슬롯인지 정한다.
##
## 대사/이름은 전부 placeholder — 진짜 스토리 내용이 아니라 "아이템
## 3개를 모으는 구조가 실제로 작동하는지" 확인용 틀이다.

const ITEM_ICON := preload("res://assets/props/ui_icons/key_icon.png")

@export var chapter_number: int = 2
@export var item_index: int = 0
@export var item_name: String = "조각"
@export var found_lines: Array[String] = ["무언가를 찾았다."]
@export var already_found_line: String = "이제 이 자리는 비어 있다."

func _on_interact() -> void:
	if ChapterProgress.has_item(chapter_number, item_index):
		DialogueSystem.start_dialogue([already_found_line])
		return
	ChapterProgress.collect_item(chapter_number, item_index)
	DialogueSystem.dialogue_ended.connect(_on_found_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueSystem.start_dialogue(found_lines)

func _on_found_dialogue_ended() -> void:
	ItemPopup.show_item(item_name, ITEM_ICON)
