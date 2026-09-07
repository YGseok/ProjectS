extends InteractableBase
## 장독대 항아리 — 3단계부터 등장(DESIGN.md §7.1). 표식 새겨진 나무패를
## 발견한다(1회성). 순수 퍼즐 단서로만 쓰고 별도 공포 디테일은 없음.

func _is_visible_now() -> bool:
	return Chapter1Progress.stage >= 3

func _on_interact() -> void:
	if Chapter1Progress.has_stamp:
		DialogueSystem.start_dialogue(["장독 안은 이제 비어 있다."])
		return
	Chapter1Progress.has_stamp = true
	DialogueSystem.start_dialogue([
		"장독 안을 들여다보니 작은 나무패가 가라앉아 있다.",
		"표면에 숫자 같은 표식이 새겨져 있다.",
	])
