extends SceneTree
## 일회성 도구 — 에셋 이미지들의 픽셀 크기를 출력 (TileSet/AnimatedSprite 설계용).

func _initialize() -> void:
	var paths := [
		"res://assets/tiles/main/A4.png",
		"res://assets/tiles/main/A5.png",
		"res://assets/tiles/main/Outside.png",
		"res://assets/tiles/main/Inside_C.png",
		"res://assets/tiles/main/Inside_C_2.png",
		"res://assets/tiles/main/Inside_D.png",
		"res://assets/tiles/main/Inside_E.png",
	]
	for p in paths:
		var img := Image.load_from_file(ProjectSettings.globalize_path(p))
		if img:
			print("%s -> %dx%d" % [p, img.get_width(), img.get_height()])
		else:
			print("%s -> LOAD FAILED" % p)
	quit(0)
