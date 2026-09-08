extends InteractableBase
## 밭의 사방치기 흔적 — 2단계부터 등장(DESIGN.md §8.1). 하늘칸 자리를
## 파보면 열쇠가 나온다(1회성). 순환 1의 자물쇠엔 안 맞음(floorboard.gd 참고).

func _is_visible_now() -> bool:
	return Chapter1Progress.stage >= 2

func _on_interact() -> void:
	if Chapter1Progress.has_key:
		DialogueSystem.start_dialogue(["다 지워지지 않은 사방치기 칸이 흙바닥에 남아 있다."])
		return
	Chapter1Progress.has_key = true
	DialogueSystem.start_dialogue([
		"흙바닥에 희미하게 사방치기 칸이 남아 있다.",
		"마지막 칸(하늘칸) 자리를 파보니 작은 열쇠가 나온다.",
	])
