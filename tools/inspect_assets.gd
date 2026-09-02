extends SceneTree
## 일회성 도구 — 에셋 이미지들의 픽셀 크기를 출력 (TileSet/AnimatedSprite 설계용).

func _initialize() -> void:
	var paths := [
		"res://assets/sprites/characters/elf_girl_test/elf girl 8 direction sprite sheet.png",
		"res://assets/sprites/characters/elf_girl_test/elf girl current animations1.png",
		"res://assets/tiles/interior_test/walls/wall_straight.png",
		"res://assets/tiles/interior_test/walls/wall_corner_tl.png",
		"res://assets/tiles/interior_test/walls/wall_corner_tr.png",
		"res://assets/tiles/interior_test/walls/wall_bottom.png",
		"res://assets/tiles/interior_test/walls/wall_vertical.png",
		"res://assets/tiles/interior_test/walls/wall_shadow.png",
		"res://assets/tiles/interior_test/floors/floor_carpet.png",
		"res://assets/tiles/interior_test/floors/floor_wood_plank.png",
		"res://assets/tiles/interior_test/dual_grid/dual_full.png",
		"res://assets/tiles/interior_test/dual_grid/dual_edge.png",
		"res://assets/tiles/interior_test/dual_grid/dual_inner.png",
		"res://assets/tiles/interior_test/dual_grid/dual_outer.png",
		"res://assets/tiles/interior_test/dual_grid/dual_diagonal.png",
	]
	for p in paths:
		var img := Image.load_from_file(ProjectSettings.globalize_path(p))
		if img:
			print("%s -> %dx%d" % [p, img.get_width(), img.get_height()])
		else:
			print("%s -> LOAD FAILED" % p)
	quit(0)
