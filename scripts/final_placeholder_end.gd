extends Node2D
## 임시 최종 화면(마지막 챕터 종료 후, DESIGN.md §11.1) — 진짜 엔딩
## 연출은 아직 미정이라 정적 화면만 보여준다. 자유 이동이 없으니
## 미니맵만 꺼서 깔끔하게 마무리한다.

func _ready() -> void:
	Minimap.hide_map()
