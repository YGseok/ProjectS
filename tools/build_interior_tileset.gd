extends SceneTree
## 일회성 도구 — elf_girl_test 팩의 벽/바닥 타일 PNG들로 TileSet 리소스를
## 코드로 조립해서 저장한다 (수기로 .tres를 작성하면 형식 오류 위험이 커서
## Godot API로 안전하게 생성). 소스 추가 순서 = source_id 순서
## (0=floor, 1=wall_straight, 2=corner_tl, 3=corner_tr, 4=bottom, 5=vertical).
## 실행: godot4 --headless --script res://tools/build_interior_tileset.gd --path <project>

const TILE_DIR := "res://assets/tiles/interior_test/"

func _initialize() -> void:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(160, 160)

	var paths := [
		TILE_DIR + "floors/floor_wood_plank.png",
		TILE_DIR + "walls/wall_straight.png",
		TILE_DIR + "walls/wall_corner_tl.png",
		TILE_DIR + "walls/wall_corner_tr.png",
		TILE_DIR + "walls/wall_bottom.png",
		TILE_DIR + "walls/wall_vertical.png",
	]

	for i in range(paths.size()):
		var tex := load(paths[i]) as Texture2D
		if tex == null:
			printerr("[TILESET] 텍스처 로드 실패: %s" % paths[i])
			quit(1)
			return
		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = Vector2i(160, 160)
		var source_id := tileset.add_source(source)
		source.create_tile(Vector2i(0, 0))
		print("[TILESET] source_id=%d <- %s" % [source_id, paths[i]])

	var out_path := TILE_DIR + "interior_test.tres"
	var err := ResourceSaver.save(tileset, out_path)
	if err != OK:
		printerr("[TILESET] 저장 실패: %d" % err)
		quit(1)
		return

	print("[TILESET] 저장 완료: %s" % out_path)
	quit(0)
