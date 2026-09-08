extends InteractableBase
## 판자 옆 공기돌 다섯 알 — 순수 플레이버 오브젝트, 상태 변화 없음
## (DESIGN.md §8.1 1단계). 정체는 아직 밝히지 않는다.

func _on_interact() -> void:
	DialogueSystem.start_dialogue([
		"공기돌 다섯 알이 나란히 놓여 있다.",
		"유난히 매끈하게 닳아 있다 — 누군가 오래 손에 쥐고 놀았던 것처럼.",
	])
