extends Node2D
## 그리드 이동 충돌 맵 — 벽/지붕/나무 밑둥처럼 걸어 들어갈 수 없는
## 영역을 사각형 목록으로 들고 있다가, player.gd가 다음 칸으로 이동해도
## 되는지 물어보면 답해준다.
##
## 이 프로젝트는 물리 엔진(CharacterBody2D 등)을 쓰지 않고 좌표를 직접
## 옮기는 그리드 이동 방식이라, 콜리전도 물리 바디 대신 이 단순한 사각형
## 목록 + 점(point)-포함 검사로 처리한다.
##
## 정적인 blocked_rects 목록(벽/지붕/나무 밑둥)과 별개로, "blocks_movement"
## 그룹에 속한 노드(NPC, InteractableBase 하위 오브젝트 전부)도 동적으로
## 막는다(사람 피드백, 2026-09-09 "NPC 및 대화 가능한 오브젝트에도
## 벽처럼 충돌 판정을 추가한다"). 이 오브젝트들은 전부 정확히 타일
## 중심에 놓여 있어서, 절반 타일(16px) 안이면 "같은 칸"으로 본다.
## visible=false인 동안(아직 등장하지 않은 단계의 사방치기/장독 등)은
## 자동으로 건너뛴다 — 진행 단계 상태와 별도로 관리할 필요가 없다.

const DYNAMIC_BLOCK_DISTANCE := 16.0

@export var blocked_rects: Array[Rect2] = []

func _ready() -> void:
	add_to_group("collision_map")

## next_position(다음 칸 중심 좌표)이 막힌 영역에 들어가면 true.
func is_blocked(next_position: Vector2) -> bool:
	for rect in blocked_rects:
		if rect.has_point(next_position):
			return true
	for node in get_tree().get_nodes_in_group("blocks_movement"):
		if not node.visible:
			continue
		if node.global_position.distance_to(next_position) < DYNAMIC_BLOCK_DISTANCE:
			return true
	return false
