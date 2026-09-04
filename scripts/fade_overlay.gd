extends CanvasLayer
## 씬 전환용 검은 페이드. 씬 시작 시 검은 화면에서 자동으로 밝아지고,
## fade_to_scene() 호출 시 어두워진 뒤 다음 씬으로 전환한다.
## "감각이 하나씩 지워진다"(DESIGN.md §4) 연출의 최소 구현 — 사운드는 §9 미정.

@onready var _rect: ColorRect = $FadeRect

var _busy := false

func _ready() -> void:
	_rect.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 0.0, 0.5)

func fade_to_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(path)
