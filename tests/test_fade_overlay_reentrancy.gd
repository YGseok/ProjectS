extends SceneTree
## 자동 유닛 테스트 — FadeOverlay.fade_to_scene() 의 `_busy` 재진입 방지
## 가드를 검증한다. 짧은 시간 안에 두 번 호출하면 두 번째는 무시되고,
## 첫 번째 호출로 지정한 씬으로만 전환돼야 한다.
##
## 실행: godot4 --headless --script res://tests/test_fade_overlay_reentrancy.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	var packed := load("res://scenes/common/FadeOverlay.tscn") as PackedScene
	var overlay := packed.instantiate()
	root.add_child(overlay)
	await process_frame

	# 첫 호출 — 정상적으로 dungeon.tscn 으로 전환되어야 함
	overlay.fade_to_scene("res://scenes/dungeon.tscn")
	# 바로 이어서 재호출 — _busy 가드에 의해 무시되어야 함
	overlay.fade_to_scene("res://scenes/chapter1_real.tscn")

	await _wait_scene_change("Dungeon", 3.0)
	_assert(current_scene != null and current_scene.name == "Dungeon",
		"두 번째 호출은 무시되고 첫 번째 호출(dungeon)만 반영됨, 실제: %s" % [current_scene.name if current_scene else "null"])

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


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
