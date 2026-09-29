extends Control
## 미니맵 안쪽 지형/NPC 오버레이 — `minimap.gd`가 매 프레임 좌표를
## 미니맵 로컬 좌표로 변환해서 넘겨주면 그대로 그린다(사람 피드백,
## 2026-09-15: "미니맵에 대략적인 배경색 구분이 되도록 한다. 플레이어
## 캐릭터, NPC, 갈 수 없는 벽이 확실히 구분되어야 한다"). 벽돌/얼굴
## 아이콘(2026-09-29 사람 제공 그림)을 타일링/점 찍듯이 그린다.

const NPC_ICON_SIZE := 8.0

var _wall_tex: Texture2D = preload("res://assets/props/ui_icons/mm_wall.png")
var _npc_tex: Texture2D = preload("res://assets/props/ui_icons/mm_npc.png")

var wall_rects: Array[Rect2] = []
var npc_points: Array[Vector2] = []

func _draw() -> void:
	for rect in wall_rects:
		draw_texture_rect(_wall_tex, rect, false)
	for p in npc_points:
		var r := Rect2(p - Vector2.ONE * NPC_ICON_SIZE / 2.0, Vector2.ONE * NPC_ICON_SIZE)
		draw_texture_rect(_npc_tex, r, false)
