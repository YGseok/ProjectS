extends SceneTree
## 일회성 도구 — 에셋 이미지들의 픽셀 크기를 출력 (TileSet/AnimatedSprite 설계용).

func _initialize() -> void:
	var paths := [
		"res://assets/sprites/characters/bonus_pack/Bonus.png",
		"res://assets/sprites/characters/bonus_pack/Cute_Yui.png",
		"res://assets/sprites/characters/bonus_pack/femaleIdle.png",
		"res://assets/props/bonus_pack/Door1.png",
		"res://assets/props/bonus_pack/RejectedAssets1.png",
	]
	for p in paths:
		var img := Image.load_from_file(ProjectSettings.globalize_path(p))
		if img:
			print("%s -> %dx%d" % [p, img.get_width(), img.get_height()])
		else:
			print("%s -> LOAD FAILED" % p)
	quit(0)
