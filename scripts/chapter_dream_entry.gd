extends Node2D
class_name ChapterDreamEntry
## 챕터 2 이후 공용 꿈 진입 처리 — 첫 방문에만 "N장" 타이틀 카드를
## 띄우고 미니맵을 켠다. `chapter1_dream_entry.gd`(챕터 1 전용)와 같은
## 역할이지만, 챕터 번호별로 재사용할 수 있게 범용화했다(사람 피드백,
## 2026-09-14, DESIGN.md §11 — 챕터가 늘어나도 새 스크립트 없이 export
## 값만 바꾸면 됨).

@export var chapter_number: int = 2
@export var title_text: String = "2장"
@export var map_bounds: Rect2 = Rect2(Vector2(0, -320), Vector2(1280, 1040))

func _ready() -> void:
	Minimap.show_map(map_bounds)
	if ChapterProgress.is_started(chapter_number):
		return
	ChapterProgress.set_started(chapter_number)
	ChapterTitleCard.show_title(title_text)
