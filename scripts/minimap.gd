extends CanvasLayer
## 미니맵 — 화면 우상단에 떠서 플레이어 위치를 보여준다(사람 피드백,
## 2026-09-14: "미니맵도 일단 추가해보자. 우상단에 항상 떠있도록 한다.
## 챕터 전환이나 나레이션 같이, 플레이 불가능한 시점에서는 표시되지
## 않는다.").
##
## 자유 이동이 가능한 씬(chapter1_real.tscn/chapter1_dream.tscn)이 자기
## 진입 스크립트의 _ready()에서 show_map(map_bounds)를 호출해서 켜고,
## 맵 크기(map_bounds)에 맞춰 플레이어 점의 상대 위치를 계산한다.
## 프롤로그/챕터 종료 화면처럼 자유 이동이 없는 씬은 hide_map()을
## 불러서 끈다 — 오토로드라 안 그러면 이전 씬에서 켠 상태가 그대로
## 남는다. `ChapterTitleCard`가 떠 있는 동안(챕터 시작/종료 전환
## 순간)도 "플레이 불가능한 시점"이라 자동으로 같이 숨긴다.

## 배경(패널 바탕색)은 대략적인 "걸어다닐 수 있는 땅" 톤이고, 그 위에
## `CollisionMap.blocked_rects`(벽/지붕/나무 밑둥 등 갈 수 없는 곳)를
## 어두운 사각형으로, "minimap_npc" 그룹 노드를 점으로 그려서 플레이어/
## NPC/벽이 구분되게 한다(사람 피드백, 2026-09-15) — 실제 그리기는
## `Panel/Terrain`(`minimap_terrain.gd`)이 맡는다.

const MAP_SIZE := Vector2(160.0, 90.0)
const DOT_SIZE := Vector2(6.0, 6.0)

@onready var _panel: Panel = $Panel
@onready var _dot: ColorRect = $Panel/PlayerDot
@onready var _terrain: Control = $Panel/Terrain

var _map_bounds := Rect2(Vector2.ZERO, Vector2(1280, 720))
var _showing := false

func _ready() -> void:
	_panel.visible = false

func show_map(map_bounds: Rect2) -> void:
	_map_bounds = map_bounds
	_showing = true

func hide_map() -> void:
	_showing = false

func is_showing() -> bool:
	return _panel.visible

func _process(_delta: float) -> void:
	var should_show := _showing and not ChapterTitleCard.is_active()
	_panel.visible = should_show
	if not should_show:
		return
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var size: Vector2 = _map_bounds.size if _map_bounds.size != Vector2.ZERO else Vector2.ONE
	var rel: Vector2 = (player.global_position - _map_bounds.position) / size
	rel.x = clampf(rel.x, 0.0, 1.0)
	rel.y = clampf(rel.y, 0.0, 1.0)
	_dot.position = rel * MAP_SIZE - DOT_SIZE * 0.5

	# 벽/장애물(갈 수 없는 곳)과 NPC도 대략적인 위치로 함께 표시한다
	# (사람 피드백, 2026-09-15 "배경색 구분... 플레이어, NPC, 갈 수 없는
	# 벽이 확실히 구분되어야 한다").
	var world_to_map := func(world_pos: Vector2) -> Vector2:
		return (world_pos - _map_bounds.position) / size * MAP_SIZE

	var wall_rects: Array[Rect2] = []
	var collision_map: Node = get_tree().get_first_node_in_group("collision_map")
	if collision_map:
		for rect: Rect2 in collision_map.blocked_rects:
			var top_left: Vector2 = world_to_map.call(rect.position)
			var bottom_right: Vector2 = world_to_map.call(rect.position + rect.size)
			wall_rects.append(Rect2(top_left, bottom_right - top_left))
	_terrain.wall_rects = wall_rects

	var npc_points: Array[Vector2] = []
	for npc: Node2D in get_tree().get_nodes_in_group("minimap_npc"):
		npc_points.append(world_to_map.call(npc.global_position))
	_terrain.npc_points = npc_points

	_terrain.queue_redraw()
