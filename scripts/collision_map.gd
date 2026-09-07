extends Node2D
## 그리드 이동 충돌 맵 — 벽/지붕/나무 밑둥처럼 걸어 들어갈 수 없는
## 영역을 사각형 목록으로 들고 있다가, player.gd가 다음 칸으로 이동해도
## 되는지 물어보면 답해준다.
##
## 이 프로젝트는 물리 엔진(CharacterBody2D 등)을 쓰지 않고 좌표를 직접
## 옮기는 그리드 이동 방식이라, 콜리전도 물리 바디 대신 이 단순한 사각형
## 목록 + 점(point)-포함 검사로 처리한다.

@export var blocked_rects: Array[Rect2] = []

func _ready() -> void:
	add_to_group("collision_map")

## next_position(다음 칸 중심 좌표)이 막힌 영역에 들어가면 true.
func is_blocked(next_position: Vector2) -> bool:
	for rect in blocked_rects:
		if rect.has_point(next_position):
			return true
	return false
