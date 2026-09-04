extends TileMapLayer
## 파이프라인 테스트용 — 5x4 타일 방을 코드로 페인트한다.
## source_id: 0=floor_wood_plank, 1=wall_straight, 2=corner_tl, 3=corner_tr,
## 4=wall_bottom, 5=wall_vertical (tools/build_interior_tileset.gd 생성 순서).

const COLS := 5
const ROWS := 4

func _ready() -> void:
	# 위쪽 벽
	set_cell(Vector2i(0, 0), 2, Vector2i(0, 0))
	for c in range(1, COLS - 1):
		set_cell(Vector2i(c, 0), 1, Vector2i(0, 0))
	set_cell(Vector2i(COLS - 1, 0), 3, Vector2i(0, 0))

	# 중간 (좌우 벽 + 바닥) — 오른쪽 벽은 wall_vertical.png이 한쪽 면만
	# 그려져 있어 좌우반전(FLIP_H)해서 사용한다.
	for r in range(1, ROWS - 1):
		set_cell(Vector2i(0, r), 5, Vector2i(0, 0))
		for c in range(1, COLS - 1):
			set_cell(Vector2i(c, r), 0, Vector2i(0, 0))
		set_cell(Vector2i(COLS - 1, r), 5, Vector2i(0, 0), TileSetAtlasSource.TRANSFORM_FLIP_H)

	# 아래쪽 벽
	for c in range(0, COLS):
		set_cell(Vector2i(c, ROWS - 1), 4, Vector2i(0, 0))
