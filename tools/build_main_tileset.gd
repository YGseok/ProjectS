extends SceneTree
## 일회성 도구 — assets/tiles/main/(A4, A5) 시트에서 특정 셀을 골라
## Godot TileSet 리소스로 조립한다. 원본은 48px 격자지만 게임 그리드는
## 32px(TILE_SIZE, player.gd)이므로 tile_size=32, texture_region_size=48로
## 줘서 자동 축소 렌더링되게 한다.
##
## source_id 0 = A4.png (벽), source_id 1 = A5.png (바닥/지면)
## 실행: godot4 --headless --script res://tools/build_main_tileset.gd --path <project>

const A4 := "res://assets/tiles/main/A4.png"
const A5 := "res://assets/tiles/main/A5.png"
const OUT := "res://assets/tiles/main/main_tileset.tres"

func _initialize() -> void:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(32, 32)

	var wall_source := _add_source(tileset, A4, [Vector2i(2, 10)])
	var ground_source := _add_source(tileset, A5, [
		Vector2i(0, 8),  # 잔디(마당 기본)
		Vector2i(1, 8),  # 붉은 흙(밭)
		Vector2i(0, 5),  # 밝은 나무 바닥(툇마루/원두막)
		Vector2i(1, 5),  # 중간톤 나무 바닥(원두막 변형)
	])
	print("wall_source=%d ground_source=%d" % [wall_source, ground_source])

	var err := ResourceSaver.save(tileset, OUT)
	if err != OK:
		printerr("[TILESET] 저장 실패: %d" % err)
		quit(1)
		return
	print("[TILESET] 저장 완료: %s" % OUT)
	quit(0)


func _add_source(tileset: TileSet, tex_path: String, coords: Array) -> int:
	var tex := load(tex_path) as Texture2D
	var source := TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(48, 48)
	var source_id := tileset.add_source(source)
	for c in coords:
		source.create_tile(c)
	return source_id
