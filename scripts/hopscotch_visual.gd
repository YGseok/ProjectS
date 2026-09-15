extends Node2D
## 사방치기(하늘땅 놀이) 칸을 흙바닥에 직접 그린다 — 실제 타일 에셋이
## 없어서(`assets/props/main_tileset_props/README.md` "못 찾은 것" 참고)
## `_draw()`로 사각형 4칸 + 반원(하늘칸)을 그대로 벡터로 그린다(2026-09-15,
## "기능부터 만들고 내용은 나중에" 방침을 캐릭터 스프라이트에 이어 여기도
## 적용). 사람 얼굴/몸처럼 복잡한 형태가 아니라 사각형+반원 조합이라
## 절차적으로 정확하게 그릴 수 있는 소재라서 채택함 — 예전에 중단했던
## 캐릭터 절차적 생성(도형 조합으로 사람을 흉내내려다 한계에 부딪힘)과는
## 성격이 다르다.

const CELL := 26.0
const GAP := 4.0
const LINE_COLOR := Color(0.88, 0.82, 0.68, 0.8)
const LINE_WIDTH := 2.0

func _draw() -> void:
	var row1_y := CELL * 1.5 + GAP
	var row23_y := CELL * 0.5 + GAP * 0.5
	var row4_y := -CELL * 0.5
	var sky_y := -CELL * 1.5 - GAP

	_draw_square(Vector2(0, row1_y))
	_draw_square(Vector2(-CELL / 2.0 - GAP / 2.0, row23_y))
	_draw_square(Vector2(CELL / 2.0 + GAP / 2.0, row23_y))
	_draw_square(Vector2(0, row4_y))
	draw_arc(Vector2(0, sky_y + CELL * 0.2), CELL * 0.62, PI, TAU, 20, LINE_COLOR, LINE_WIDTH, true)

func _draw_square(center: Vector2) -> void:
	var rect := Rect2(center - Vector2(CELL, CELL) / 2.0, Vector2(CELL, CELL))
	draw_rect(rect, LINE_COLOR, false, LINE_WIDTH)
