extends SceneTree
## 자동 상호작용 테스트 — 플레이어 걷기 애니메이션(player.gd, CH-102).
## 한 칸 이동을 시작하면 보폭 프레임(walk1/walk2)이 보이고, 도착하면 정지
## 프레임으로 돌아오며, 연속 이동 시 왼발/오른발 프레임이 번갈아 나오는지 확인.
## 4방향 × 3프레임 텍스처가 전부 로드되는지(캔버스 크기 동일)도 같이 본다.
##
## 실행: godot4 --headless --script res://tests/test_player_walk_animation.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	for dir in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		var frames: Array = _player._frames[dir]
		var ok: bool = frames.size() == 3 and frames.all(func(t): return t != null)
		_assert(ok, "%s 방향 3프레임 로드" % [dir])
		if ok:
			_assert(frames[1].get_size() == frames[0].get_size() and frames[2].get_size() == frames[0].get_size(),
				"%s 방향 3프레임 캔버스 크기 동일(발 위치 고정), 실제: %s %s %s" %
					[dir, frames[0].get_size(), frames[1].get_size(), frames[2].get_size()])

	# 콜리전 없는 줄(y=192, test_movement_bounds.gd 참고)에서 왼쪽으로 걷는다.
	await _step("ui_down")
	var left: Array = _player._frames[Vector2.LEFT]
	var stride_a := await _step("ui_left")
	_assert(stride_a == left[1] or stride_a == left[2], "이동 시작 시 왼쪽 보폭 프레임 표시")
	_assert(_player.get_node("Sprite").texture == left[0], "도착 후 왼쪽 정지 프레임으로 복귀")
	var stride_b := await _step("ui_left")
	_assert(stride_b != stride_a and (stride_b == left[1] or stride_b == left[2]),
		"다음 걸음은 반대 발 보폭 프레임")
	_finish()


## 한 칸 이동시키고, 이동이 시작된 직후의 텍스처를 돌려준다.
func _step(action: String) -> Texture2D:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var guard := 0
	while not _player._moving and guard < 10:
		await process_frame
		guard += 1
	var tex: Texture2D = _player.get_node("Sprite").texture
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	guard = 0
	while _player._moving and guard < 60:
		await process_frame
		guard += 1
	await process_frame
	return tex


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
