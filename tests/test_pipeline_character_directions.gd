extends SceneTree
## 자동 상호작용 테스트 — pipeline_test.tscn의 캐릭터(외부 에셋
## 파이프라인 검증용, scripts/test/pipeline_test_character.gd)가 각
## 방향키를 누를 때마다 해당 방향의 스프라이트로 실제로 바뀌는지 검증한다.
## 지금까지는 QA 스크린샷 한 장(기본 아래쪽 포즈)으로만 확인했었고,
## 방향 전환 자체는 한 번도 자동 검증된 적이 없었다.
##
## 실행: godot4 --headless --script res://tests/test_pipeline_character_directions.gd --path <project>

var _character: Node2D
var _sprite: Sprite2D
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/test/pipeline_test.tscn")
	await process_frame
	await process_frame

	_character = current_scene.get_node_or_null("Character")
	_assert(_character != null, "Character 노드를 찾음")
	if _character == null:
		_finish()
		return
	_sprite = _character.get_node("Sprite2D")

	_assert(_sprite.texture == _character._tex_down, "시작 시 기본 텍스처는 아래쪽, 실제 일치 여부: %s" % [_sprite.texture == _character._tex_down])

	await _check_direction("ui_right", _character._tex_right, "오른쪽")
	await _check_direction("ui_down", _character._tex_down, "아래쪽")
	await _check_direction("ui_left", _character._tex_left, "왼쪽")
	await _check_direction("ui_up", _character._tex_up, "위쪽")

	_finish()


func _check_direction(action: String, expected_tex: Texture2D, label: String) -> void:
	await _move_one_tile(action)
	_assert(_sprite.texture == expected_tex, "%s 이동 시 %s 텍스처로 바뀜" % [label, label])


func _move_one_tile(action: String) -> void:
	_press(action)
	var start_guard := 0
	while not _character._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	_release(action)
	var move_guard := 0
	while _character._moving and move_guard < 60:
		await process_frame
		move_guard += 1


func _press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _release(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = false
	Input.parse_input_event(ev)


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
