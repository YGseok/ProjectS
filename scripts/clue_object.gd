extends InteractableBase
class_name ClueObject
## 챕터 탈출 후 일상 파트에서 얻을 수 있는 "단서" 오브젝트(INBOX.md
## 2026-09-09: "탈출한 후, 바깥을 돌아다니며 NPC와 대화하거나 단서를
## 얻을 수 있는 일상 플레이가 가능하다"). 어떤 단서를 누구에게서 어떻게
## 얻는지는 원래 스토리 결정이 필요해서 보류돼 있었지만, 사람 확인
## (2026-09-15: "기능부터 만들고 내용은 나중에 붙인다")에 따라 구조부터
## 임의 콘텐츠로 채워 넣는다 — 실제 단서 내용은 사람 확인 후 갈아끼울
## 것을 전제로 한 placeholder다.
##
## `required_chapter`를 탈출해야 나타난다. `ChapterProgress.current_chapter`
## 하나로 챕터 1/2/3 전부를 판단할 수 있는 이유: 챕터 1의 완료(floorboard.gd)
## 도 이 값을 2로 올려서 챕터 2/3과 같은 방식으로 편입되기 때문
## (DESIGN.md §11 참고) — 별도로 Chapter1Progress를 확인할 필요가 없다.

@export var required_chapter: int = 1
@export var lines: Array[String] = ["..."]

func _is_visible_now() -> bool:
	return ChapterProgress.current_chapter > required_chapter

func _on_interact() -> void:
	DialogueSystem.start_dialogue(lines)
