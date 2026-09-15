extends Node2D
## 완전히 투명한 상호작용 오브젝트(챕터 2/3의 조각/탈출구)에 붙이는
## 범용 표시 마커 — 실제 아트가 없어 위치를 전혀 알 수 없다는 사람
## 피드백(2026-09-15, "2 챕터 오브젝트가 투명이라 어디서 뭘 먹어야
## 할지 모르겠음")에 대응. 반짝이는 작은 별 모양을 `_draw()`로 직접
## 그린다 — 사방치기(`hopscotch_visual.gd`)와 같은 이유로 기하학적
## 도형이라 절차적 생성이 안정적으로 가능(사람 얼굴/몸과는 다름).

@export var color: Color = Color(0.95, 0.85, 0.35, 0.9)
@export var radius: float = 9.0

var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 0.75 + 0.25 * sin(_t * 3.0)
	var r := radius * pulse
	var points := PackedVector2Array()
	for i in range(9):
		var angle := TAU * i / 8.0
		var rad := r if i % 2 == 0 else r * 0.4
		points.append(Vector2(cos(angle), sin(angle)) * rad)
	draw_polyline(points, color, 2.0, true)
