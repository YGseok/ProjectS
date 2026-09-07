extends TileMapLayer
## 챕터 1 현실 배경 — assets/tiles/main/main_tileset.tres 타일로 채운다.
## 좌표는 기존 그레이박스 ColorRect들과 동일한 위치를 32px 그리드로 옮긴 것
## (scenes/chapter1_real.tscn 참고). source 0 = A4(벽), source 1 = A5(바닥/지면).

const GRASS := Vector2i(0, 8)
const DIRT := Vector2i(1, 8)
const WOOD_LIGHT := Vector2i(0, 5)
const WOOD_MED := Vector2i(1, 5)
const WALL := Vector2i(2, 10)

# 원두막 지붕은 벽과 같은 타일을 재사용하되(A4 시트에 지붕 전용 타일이
# 마땅치 않았음, STATUS.md 참고) 살짝 어둡게 틴트해서 벽과 구분되게 한다.
const ROOF_TINT := Color(0.7, 0.62, 0.6, 1)

func _ready() -> void:
	# 마당(잔디) 전체
	_fill_rect(0, 40, 0, 23, 1, GRASS)

	# 기와집 벽 (x160-1120, y0-128 -> col5-34, row0-3)
	_fill_rect(5, 35, 0, 4, 0, WALL)

	# 툇마루 (x160-1120, y128-192 -> col5-34, row4-5)
	_fill_rect(5, 35, 4, 6, 1, WOOD_LIGHT)

	# 밭 (x192-576, y288-608 -> col6-17, row9-18)
	_fill_rect(6, 18, 9, 19, 1, DIRT)

	# 원두막 지붕 (x832-1120, y352-416 -> col26-34, row11-12)
	_fill_rect(26, 35, 11, 13, 0, WALL, ROOF_TINT)

	# 원두막 바닥 (x864-1088, y384-576 -> col27-33, row12-17)
	_fill_rect(27, 34, 12, 18, 1, WOOD_MED)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, source_id: int, atlas: Vector2i, tint: Color = Color.WHITE) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			var coords := Vector2i(c, r)
			set_cell(coords, source_id, atlas)
			if tint != Color.WHITE:
				var data := get_cell_tile_data(coords)
				if data:
					data.modulate = tint
