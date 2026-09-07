extends SceneTree
## 자동 회귀 테스트 — 낮잠→꿈→각성 왕복 후에도 chapter1_real의 지붕 색
## 오버레이(RoofTint)가 항상 같은 값을 유지하는지 검증한다.
##
## 배경: 예전에는 지붕/벽 색 구분을 TileData.modulate로 구현했는데, 이는
## chapter1_real/chapter1_dream이 공유하는 main_tileset.tres 리소스 자체를
## 오염시켜서 (1) 같은 씬 안에서도 벽과 지붕이 같은 색으로 렌더링되고
## (2) 꿈에서 돌아오면 현실 배경에 꿈의 색이 남는 버그가 있었다
## (2026-09-07, 사람이 실제 플레이하다 발견). 지금은 씬마다 독립된
## ColorRect 오버레이 노드로 바뀌어서 애초에 공유 자원이 없다 — 이
## 테스트는 그 사실(매번 새로 로드되는 씬은 항상 같은 값을 가짐)을
## 왕복 후에도 재확인해서 회귀를 잡는다.
##
## 실행: godot4 --headless --script res://tests/test_background_tint_reset.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	var roof_tint: ColorRect = current_scene.get_node("RoofTint")
	var expected_color: Color = roof_tint.color
	_assert(expected_color != Color.WHITE, "RoofTint이 흰색이 아닌 실제 틴트 값을 가짐, 실제: %s" % [expected_color])

	# 낮잠 -> 꿈
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Dream", 3.0)

	var dream_roof_tint: ColorRect = current_scene.get_node("RoofTint")
	_assert(dream_roof_tint.color != expected_color,
		"꿈 씬의 RoofTint는 현실과 다른(더 어두운/붉은) 값, 실제: %s" % [dream_roof_tint.color])

	# 각성 -> 현실
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)

	var roof_tint_after: ColorRect = current_scene.get_node("RoofTint")
	_assert(roof_tint_after.color == expected_color,
		"각성 후 RoofTint가 원래 값으로 돌아옴 (전 %s vs 후 %s)" % [expected_color, roof_tint_after.color])

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


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
