extends Node2D
## 챕터 1 꿈 진입 처리 — 첫 방문에만 "1장 시작" 타이틀 카드를 띄우고
## (사람 피드백, 2026-09-09: "첫 꿈 들어간 후 1챕터 타이틀이 뜨고"),
## 미니맵을 켠다(2026-09-14: "미니맵도 일단 추가해보자"). 자유 이동이
## 가능한 씬이라 미니맵은 매번 켜지만, 타이틀 카드는
## `Chapter1Progress.chapter_started`로 "처음"인지 판단해서 재방문(예:
## 개발자 치트로 되돌아오는 경우)에는 중복으로 뜨지 않게 한다.
##
## 미니맵 범위는 player.gd의 play_area/Camera2D.limit_*와 맞춰야 한다 —
## 2026-09-14 맵 확장(기와집 내부, DESIGN.md §8.3)으로 위쪽 320px가
## 늘어났다.

func _ready() -> void:
	Minimap.show_map(Rect2(Vector2(0, -320), Vector2(1280, 1040)))
	if Chapter1Progress.chapter_started:
		return
	Chapter1Progress.chapter_started = true
	ChapterTitleCard.show_title("1장\n\"여름, 옛집\"")
