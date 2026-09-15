extends Control
## 미니맵 안쪽 지형/NPC 오버레이 — `minimap.gd`가 매 프레임 좌표를
## 미니맵 로컬 좌표로 변환해서 넘겨주면 그대로 그린다(사람 피드백,
## 2026-09-15: "미니맵에 대략적인 배경색 구분이 되도록 한다. 플레이어
## 캐릭터, NPC, 갈 수 없는 벽이 확실히 구분되어야 한다"). 정확한 타일별
## 색상까지는 아니고, 벽/장애물(`CollisionMap.blocked_rects`)을 어두운
## 사각형으로, NPC를 점으로 표시하는 수준의 "대략적인" 구분이다.

const WALL_COLOR := Color(0.08, 0.08, 0.09, 0.9)
const NPC_COLOR := Color(0.35, 0.8, 0.85, 1.0)
const NPC_DOT_SIZE := 5.0

var wall_rects: Array[Rect2] = []
var npc_points: Array[Vector2] = []

func _draw() -> void:
	for rect in wall_rects:
		draw_rect(rect, WALL_COLOR)
	for p in npc_points:
		draw_rect(Rect2(p - Vector2.ONE * NPC_DOT_SIZE / 2.0, Vector2.ONE * NPC_DOT_SIZE), NPC_COLOR)
