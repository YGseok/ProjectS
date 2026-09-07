extends TileMapLayer
## 챕터 1 꿈 배경 — chapter1_real_background.gd와 같은 타일을 재사용한다.
## 구역별 분위기(색 틴트)는 TileData.modulate가 아니라
## chapter1_dream.tscn의 반투명 ColorRect 오버레이로 표현한다.
##
## 왜 TileData.modulate를 안 쓰는가: 벽/지붕처럼 같은 atlas 타일을 여러
## 구역에서 재사용하면, TileData는 (source_id, atlas_coords)마다 하나뿐이라
## modulate를 바꾸면 그 타일을 쓰는 셀 전부(같은 씬 안에서도, 심지어
## main_tileset.tres를 공유하는 chapter1_real.tscn에서도)에 영향을 준다.
## 실제로 이 때문에 지붕/벽 색 구분이 전혀 작동 안 했고, 꿈에서 돌아왔을
## 때 현실 배경이 안 돌아오는 버그가 있었다(2026-09-07, 사람이 플레이하다
## 발견).

const GRASS := Vector2i(0, 8)
const DIRT := Vector2i(1, 8)
const WOOD_LIGHT := Vector2i(0, 5)
const WOOD_MED := Vector2i(1, 5)
const WALL := Vector2i(2, 10)

func _ready() -> void:
	# 마당(잔디) 전체
	_fill_rect(0, 40, 0, 23, 1, GRASS)

	# 기와집 벽
	_fill_rect(5, 35, 0, 4, 0, WALL)

	# 툇마루
	_fill_rect(5, 35, 4, 6, 1, WOOD_LIGHT)

	# 밭 (피마자밭)
	_fill_rect(6, 18, 9, 19, 1, DIRT)

	# 원두막 지붕
	_fill_rect(26, 35, 11, 13, 0, WALL)

	# 원두막 바닥
	_fill_rect(27, 34, 12, 18, 1, WOOD_MED)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, source_id: int, atlas: Vector2i) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			set_cell(Vector2i(c, r), source_id, atlas)
