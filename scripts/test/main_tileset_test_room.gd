extends TileMapLayer
## 파이프라인 테스트 — assets/tiles/main 타일이 32px 게임 그리드에서
## 올바르게 축소 렌더링되는지 확인.
## source 0 = A4(벽), source 1 = A5(바닥/지면)

func _ready() -> void:
	# 벽 한 줄
	for c in range(0, 8):
		set_cell(Vector2i(c, 0), 0, Vector2i(2, 10))
	# 잔디
	for c in range(0, 8):
		set_cell(Vector2i(c, 1), 1, Vector2i(0, 8))
	# 붉은 흙(밭)
	for c in range(0, 8):
		set_cell(Vector2i(c, 2), 1, Vector2i(1, 8))
	# 밝은 나무 바닥(툇마루)
	for c in range(0, 8):
		set_cell(Vector2i(c, 3), 1, Vector2i(0, 5))
	# 중간톤 나무 바닥(원두막)
	for c in range(0, 8):
		set_cell(Vector2i(c, 4), 1, Vector2i(1, 5))
