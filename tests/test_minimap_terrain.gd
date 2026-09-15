extends SceneTree
## 자동 테스트 — 미니맵이 벽(CollisionMap.blocked_rects)과 NPC
## (minimap_npc 그룹)를 실제로 표시하는지 검증한다(사람 피드백,
## 2026-09-15: "미니맵에 대략적인 배경색 구분이 되도록 한다. 플레이어
## 캐릭터, NPC, 갈 수 없는 벽이 확실히 구분되어야 한다").
##
## 실행: godot4 --headless --script res://tests/test_minimap_terrain.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame
	await process_frame

	var minimap: Node = root.get_node_or_null("Minimap")
	_assert(minimap != null, "Minimap 오토로드를 찾음")
	if minimap == null:
		_finish()
		return
	_assert(minimap.is_showing(), "챕터 1 현실에서는 미니맵이 보임")

	var terrain: Control = minimap.get_node("Panel/Terrain")
	_assert(terrain != null, "Panel/Terrain 노드를 찾음")

	var collision_map: Node = get_first_node_in_group("collision_map")
	_assert(collision_map != null, "CollisionMap 노드를 찾음")

	_assert(terrain.wall_rects.size() == collision_map.blocked_rects.size(),
		"벽 사각형 개수가 CollisionMap.blocked_rects와 일치, 실제: %d (기대: %d)" %
			[terrain.wall_rects.size(), collision_map.blocked_rects.size()])
	_assert(terrain.wall_rects.size() > 0, "벽 사각형이 실제로 그려짐(0개 아님)")

	var npc_nodes := get_nodes_in_group("minimap_npc")
	_assert(npc_nodes.size() >= 4,
		"chapter1_real에 minimap_npc 그룹 노드가 4개 이상(그림자+A/B/C), 실제: %d" % npc_nodes.size())
	_assert(terrain.npc_points.size() == npc_nodes.size(),
		"미니맵 NPC 점 개수가 minimap_npc 그룹 노드 수와 일치, 실제: %d (기대: %d)" %
			[terrain.npc_points.size(), npc_nodes.size()])

	# 벽 사각형은 미니맵 패널(160x90) 좌표계 안에 있어야 한다(월드 좌표를
	# 그대로 쓰는 실수 방지).
	var in_bounds := true
	for rect: Rect2 in terrain.wall_rects:
		if rect.position.x < -1.0 or rect.position.y < -1.0 or rect.end.x > 161.0 or rect.end.y > 91.0:
			in_bounds = false
			break
	_assert(in_bounds, "벽 사각형이 미니맵 패널(160x90) 좌표 범위 안에 그려짐")

	_finish()


func _assert(condition: bool, description: String) -> void:
	if condition:
		print("[TEST] PASS - %s" % description)
	else:
		printerr("[TEST] FAIL - %s" % description)
		_all_passed = false


func _finish() -> void:
	if _all_passed:
		print("[TEST] ALL PASSED")
		quit(0)
	else:
		printerr("[TEST] SOME FAILED")
		quit(1)
