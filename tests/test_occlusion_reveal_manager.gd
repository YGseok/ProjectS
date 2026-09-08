extends SceneTree
## 자동 테스트 — occlusion_reveal_manager.gd가 매 프레임 셰이더 파라미터
## reveal_center를 실제 플레이어 위치로 갱신하는지 검증한다. 지금까지는
## 나무 뒤로 지나갈 때 시야가 트이는 걸 QA 스크린샷으로 눈으로만
## 확인했고(occlusion_check.png), 이 갱신 로직 자체에 대한 자동 회귀
## 테스트는 없었다.
##
## 실행: godot4 --headless --script res://tests/test_occlusion_reveal_manager.gd --path <project>

var _player: Node2D
var _manager: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_manager = current_scene.get_node_or_null("OcclusionRevealManager")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_manager != null, "OcclusionRevealManager 노드를 찾음")
	if _player == null or _manager == null:
		_finish()
		return

	var mat: ShaderMaterial = _manager.shader_material
	_assert(mat != null, "shader_material이 인스펙터에서 지정돼 있음")
	if mat == null:
		_finish()
		return

	await process_frame
	var center0: Vector2 = mat.get_shader_parameter("reveal_center")
	_assert(center0.is_equal_approx(_player.global_position),
		"초기 상태에서 reveal_center == 플레이어 위치, 실제: %s (플레이어: %s)" % [center0, _player.global_position])

	await _move_one_tile("ui_right")
	await _move_one_tile("ui_down")
	await process_frame
	var center1: Vector2 = mat.get_shader_parameter("reveal_center")
	_assert(center1.is_equal_approx(_player.global_position),
		"이동 후에도 reveal_center가 새 플레이어 위치로 갱신됨, 실제: %s (플레이어: %s)" % [center1, _player.global_position])
	_assert(not center1.is_equal_approx(center0),
		"이동 후 reveal_center 값이 실제로 바뀜(정적 초기값이 아님), 실제: %s (이전: %s)" % [center1, center0])

	_finish()


func _move_one_tile(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var start_guard := 0
	while not _player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	var move_guard := 0
	while _player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


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
