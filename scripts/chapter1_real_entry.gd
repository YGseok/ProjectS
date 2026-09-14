extends Node2D
## 챕터 1 현실 파트 진입 처리 — 미니맵을 켠다(사람 피드백, 2026-09-14:
## "미니맵도 일단 추가해보자. 우상단에 항상 떠있도록 한다"). 자유 이동이
## 가능한 씬이라 진입하는 즉시 표시한다.

func _ready() -> void:
	Minimap.show_map(Rect2(Vector2.ZERO, Vector2(1280, 720)))
