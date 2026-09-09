extends InteractableBase
## 밭의 사방치기 흔적(DESIGN.md §8.1) — 꿈 안에서 처음부터 상시 등장
## (2026-09-09부터: 퍼즐이 순환마다 하나씩이 아니라 꿈 방문 한 번 안에서
## 전부 진행되므로 더 이상 "N단계부터 등장" 게이팅이 없음). 하늘칸
## 자리를 파보면 열쇠가 나온다(1회성). 획득 시 아이템 팝업을 띄운다
## (사람 피드백, 2026-09-08 — "아이템 획득 피드백이 부족함").

const KEY_ICON := preload("res://assets/props/ui_icons/key_icon.png")

func _on_interact() -> void:
	if Chapter1Progress.has_key:
		DialogueSystem.start_dialogue(["다 지워지지 않은 사방치기 칸이 흙바닥에 남아 있다."])
		return
	Chapter1Progress.has_key = true
	DialogueSystem.dialogue_ended.connect(_on_found_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueSystem.start_dialogue([
		"흙바닥에 희미하게 사방치기 칸이 남아 있다.",
		"마지막 칸(하늘칸) 자리를 파보니 작은 열쇠가 나온다.",
	])

func _on_found_dialogue_ended() -> void:
	ItemPopup.show_item("열쇠", KEY_ICON)
