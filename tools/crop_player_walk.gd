extends SceneTree
## pc001.jpg(3열×4행 걷기 시트)에서 주인공 12프레임을 잘라
## assets/sprites/characters/player/player_{dir}[_walk1|_walk2].png로 저장한다.
## 행 순서: down, left, right, up / 열 순서: walk1, 정지(가운데), walk2.
## 같은 행의 3프레임은 합집합 bbox 하나로 잘라서 캔버스 크기·발 위치가 같다
## (프레임이 바뀔 때 흔들리지 않게). 높이는 행마다 70px로 맞춘다.
## 원본에 회색 체크무늬(≈195/≈104)가 픽셀로 박혀 있어서, 셀 테두리에서 시작해
## 체크무늬 톤만 따라가는 flood-fill로 배경을 지우고 최대 연결 성분만 남긴다.
## 발밑 그림자(무채색 반투명 회색)도 지운다.
##
## 실행: godot --headless --script res://tools/crop_player_walk.gd --path .
##   (-- --preview 를 붙이면 assets 대신 res://qa/output/walk_*.png에 저장)

const SRC := "res://assets/pc001.jpg"
const OUT_DIR := "res://assets/sprites/characters/player/"
const PREVIEW_DIR := "res://qa/output/"
const COLS := 3
const ROWS := 4
const TARGET_H := 70
const DIRS := ["down", "left", "right", "up"]
const SUFFIX := ["_walk1", "", "_walk2"]

func _init() -> void:
	var preview := "--preview" in OS.get_cmdline_user_args()
	var src := Image.load_from_file(SRC)
	src.convert(Image.FORMAT_RGBA8)
	var cw := src.get_width() / float(COLS)
	var ch := src.get_height() / float(ROWS)
	for r in ROWS:
		var cells: Array[Image] = []
		var union := Rect2i()
		for c in COLS:
			var rect := Rect2i(roundi(c * cw), roundi(r * ch), roundi(cw), roundi(ch))
			var cell := src.get_region(rect)
			_remove_background(cell)
			var bbox := cell.get_used_rect()
			union = bbox if union.size == Vector2i.ZERO else union.merge(bbox)
			cells.append(cell)
		var scale := TARGET_H / float(union.size.y)
		var out_w := maxi(1, roundi(union.size.x * scale))
		for c in COLS:
			var frame := cells[c].get_region(union)
			frame.resize(out_w, TARGET_H, Image.INTERPOLATE_LANCZOS)
			var name := "player_%s%s.png" % [DIRS[r], SUFFIX[c]]
			var path := (PREVIEW_DIR + "walk_" + name) if preview else (OUT_DIR + name)
			frame.save_png(path)
			print("%s %dx%d (src union %s)" % [path, out_w, TARGET_H, union])
	quit()

static func _is_checker(c: Color) -> bool:
	var mx := maxf(c.r, maxf(c.g, c.b))
	var mn := minf(c.r, minf(c.g, c.b))
	if mx - mn > 0.035:
		return false
	var l := (c.r + c.g + c.b) / 3.0
	# 두 톤 사이 경계도 JPG 번짐으로 중간 회색이라 범위를 이어서 본다
	return l > 0.30 and l < 0.88

static func _is_shadow(c: Color) -> bool:
	# 발밑 그림자: 체크무늬 위에 얹힌 어두운 무채색. 머리카락(거의 검정)보다는 밝다.
	var mx := maxf(c.r, maxf(c.g, c.b))
	var mn := minf(c.r, minf(c.g, c.b))
	var l := (c.r + c.g + c.b) / 3.0
	return mx - mn <= 0.035 and l > 0.22 and l < 0.60

func _remove_background(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var bg := PackedByteArray()
	bg.resize(w * h)
	var stack: Array[int] = []
	for x in w:
		stack.append(x); stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w); stack.append(y * w + w - 1)
	while not stack.is_empty():
		var i: int = stack.pop_back()
		if bg[i] == 1:
			continue
		var x := i % w
		var y := i / w
		if not _is_checker(img.get_pixel(x, y)):
			continue
		bg[i] = 1
		if x > 0: stack.append(i - 1)
		if x < w - 1: stack.append(i + 1)
		if y > 0: stack.append(i - w)
		if y < h - 1: stack.append(i + w)
	# 그림자: 배경과 닿아 있는 하단 40% 영역의 무채색 회색을 배경으로 확장
	var changed := true
	while changed:
		changed = false
		for y in range(int(h * 0.6), h):
			for x in w:
				var i := y * w + x
				if bg[i] == 1 or not _is_shadow(img.get_pixel(x, y)):
					continue
				if (x > 0 and bg[i - 1] == 1) or (x < w - 1 and bg[i + 1] == 1) \
						or (y > 0 and bg[i - w] == 1) or (y < h - 1 and bg[i + w] == 1):
					bg[i] = 1
					changed = true
	# 최대 연결 성분만 남김(시트 가장자리 색상 칩, 잔상 점 제거)
	var label := PackedInt32Array()
	label.resize(w * h)
	var best_id := 0
	var best_size := 0
	var next_id := 0
	for s in w * h:
		if bg[s] == 1 or label[s] != 0:
			continue
		next_id += 1
		var size := 0
		var st: Array[int] = [s]
		label[s] = next_id
		while not st.is_empty():
			var i: int = st.pop_back()
			size += 1
			var x := i % w
			for n in [i - 1 if x > 0 else -1, i + 1 if x < w - 1 else -1, i - w, i + w]:
				if n >= 0 and n < w * h and bg[n] == 0 and label[n] == 0:
					label[n] = next_id
					st.append(n)
		if size > best_size:
			best_size = size
			best_id = next_id
	for i in w * h:
		if label[i] != best_id:
			img.set_pixel(i % w, i / w, Color(0, 0, 0, 0))
