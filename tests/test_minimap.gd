extends SceneTree
## 자동 테스트 — 미니맵(scripts/minimap.gd, 2026-09-14 사람 피드백
## "미니맵도 일단 추가해보자. 우상단에 항상 떠있도록 한다. 챕터 전환이나
## 나레이션 같이, 플레이 불가능한 시점에서는 표시되지 않는다")이
## 자유 이동 씬에서는 보이고, 나레이션/챕터 종료 화면에서는 숨겨지고,
## 플레이어 위치에 따라 점이 움직이는지 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_minimap.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	# 프롤로그(나레이션) — 미니맵이 꺼져 있어야 한다.
	change_scene_to_file("res://scenes/chapter1_intro.tscn")
	await process_frame
	await process_frame

	var minimap: Node = root.get_node_or_null("Minimap")
	_assert(minimap != null, "Minimap 오토로드를 찾음")
	if minimap == null:
		_finish()
		return
	_assert(not minimap.is_showing(), "프롤로그(나레이션)에서는 미니맵이 숨겨짐")

	# 챕터 1 현실(자유 이동) — 미니맵이 보여야 한다.
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame
	_assert(minimap.is_showing(), "챕터 1 현실(자유 이동)에서는 미니맵이 보임")

	var player: Node2D = get_first_node_in_group("player")
	_assert(player != null, "player 그룹 노드를 찾음")
	if player != null:
		var dot: ColorRect = minimap.get_node("Panel/PlayerDot")
		var pos_before: Vector2 = dot.position
		await _move_one_tile("ui_right")
		await _move_one_tile("ui_right")
		await _move_one_tile("ui_right")
		await process_frame
		_assert(dot.position != pos_before,
			"플레이어가 이동하면 미니맵의 점 위치도 바뀜, 전: %s 후: %s" % [pos_before, dot.position])

	# 챕터 1 꿈(자유 이동) — 단, 처음 들어가는 방문이라 "1장" 챕터 시작
	# 타이틀 카드가 곧바로 뜨므로("챕터 전환" 순간), 그동안은 미니맵도
	# 같이 숨겨져 있는 게 맞는 동작이다(스크린샷이 아니라 아래에서 확인).
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	var title_card: Node = root.get_node_or_null("ChapterTitleCard")
	_assert(title_card != null and title_card.is_active(), "첫 꿈 방문이라 타이틀 카드가 떠 있음")
	_assert(not minimap.is_showing(), "타이틀 카드가 떠 있는 동안은 미니맵도 같이 숨겨짐")

	# 타이틀이 사라지면 다시 보여야 한다.
	await _send_action("ui_accept")
	await process_frame
	await process_frame
	_assert(not title_card.is_active(), "타이틀 카드가 닫힘")
	_assert(minimap.is_showing(), "타이틀 카드가 닫히면 미니맵이 다시 보임")

	# 챕터 종료 화면 — 다시 숨겨져야 한다.
	change_scene_to_file("res://scenes/chapter1_end.tscn")
	await process_frame
	await process_frame
	_assert(not minimap.is_showing(), "챕터 종료 화면에서는 미니맵이 숨겨짐")

	_finish()


func _move_one_tile(action: String) -> void:
	var player: Node2D = get_first_node_in_group("player")
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var start_guard := 0
	while not player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	var move_guard := 0
	while player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


func _send_action(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	await process_frame


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
