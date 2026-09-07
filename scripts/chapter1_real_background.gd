extends TileMapLayer
## 챕터 1 현실 배경 — assets/tiles/main/main_tileset.tres 타일로 채운다.
## 좌표는 기존 그레이박스 ColorRect들과 동일한 위치를 32px 그리드로 옮긴 것
## (scenes/chapter1_real.tscn 참고). source 0 = A4(벽), source 1 = A5(바닥/지면).

const GRASS := Vector2i(0, 8)
const DIRT := Vector2i(1, 8)
const WOOD_LIGHT := Vector2i(0, 5)
const WOOD_MED := Vector2i(1, 5)
const WALL := Vector2i(2, 10)

func _ready() -> void:
	# 마당(잔디) 전체
	for c in range(0, 40):
		for r in range(0, 23):
			set_cell(Vector2i(c, r), 1, GRASS)

	# 기와집 벽 (x160-1120, y0-128 -> col5-34, row0-3)
	for c in range(5, 35):
		for r in range(0, 4):
			set_cell(Vector2i(c, r), 0, WALL)

	# 툇마루 (x160-1120, y128-192 -> col5-34, row4-5)
	for c in range(5, 35):
		for r in range(4, 6):
			set_cell(Vector2i(c, r), 1, WOOD_LIGHT)

	# 밭 (x192-576, y288-608 -> col6-17, row9-18)
	for c in range(6, 18):
		for r in range(9, 19):
			set_cell(Vector2i(c, r), 1, DIRT)

	# 원두막 지붕 (x832-1120, y352-416 -> col26-34, row11-12)
	for c in range(26, 35):
		for r in range(11, 13):
			set_cell(Vector2i(c, r), 0, WALL)

	# 원두막 바닥 (x864-1088, y384-576 -> col27-33, row12-17)
	for c in range(27, 34):
		for r in range(12, 18):
			set_cell(Vector2i(c, r), 1, WOOD_MED)
