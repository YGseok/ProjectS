extends SceneTree
## 일회성 도구 스크립트 — 주인공 캐릭터 도트 스프라이트 초안(v7).
## 피드백 반영: "얼굴/몸 모양이 구리다" — 완벽한 원(머리)과 일직선 사다리꼴
## (드레스)이 기계적으로 보이는 게 원인으로 보고, 얼굴/머리는 턱쪽으로
## 갸름해지는 계란형으로, 드레스는 상체(핏)+치마(플레어) 2단 곡선으로,
## 팔 끝은 둥글게 바꿈.
## 실행: godot4 --headless --script res://tools/gen_player_sprite.gd --path <project>

const W := 40
const H := 64

var img: Image

var skin := Color(0.96, 0.80, 0.65)
var skin_shadow := Color(0.88, 0.70, 0.56)
var hair := Color(0.13, 0.10, 0.09)
var hair_shadow := Color(0.08, 0.06, 0.055)
var dress := Color(0.97, 0.97, 0.94)
var dress_shadow := Color(0.87, 0.86, 0.82)
var sock := Color(0.98, 0.98, 0.97)
var shoe := Color(0.30, 0.21, 0.14)
var shoe_hi := Color(0.40, 0.29, 0.20)
var shoe_sole := Color(0.18, 0.12, 0.08)
var eye_dark := Color(0.10, 0.08, 0.07)
var eye_light := Color(0.24, 0.18, 0.15)
var eye_hi := Color(1, 1, 1, 1)
var blush := Color(0.90, 0.55, 0.55, 0.35)

var cx := 20.0
var dress_top := 23
var dress_bottom := 50

func _initialize() -> void:
	img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var face_center_y := 13.0
	var face_r := 8.0
	var face_chin_r := 4.0
	var hair_r := 10.0
	var hair_chin_r := 6.0

	# 1) 머리카락 — 위쪽은 둥글게, 아래쪽(턱선)은 갸름하게 좁아지는 실루엣
	_fill_egg_shape(face_center_y, hair_r, hair_chin_r, hair)
	# 살짝 튀는 단발 팁 (좌우 끝이 바깥으로 살짝 삐침)
	_fill_rect(int(cx - hair_chin_r) - 2, int(face_center_y + hair_chin_r) - 1, int(cx - hair_chin_r), int(face_center_y + hair_chin_r) + 1, hair)
	_fill_rect(int(cx + hair_chin_r), int(face_center_y + hair_chin_r) - 1, int(cx + hair_chin_r) + 2, int(face_center_y + hair_chin_r) + 1, hair)

	# 2) 얼굴(피부) — 같은 계란형, 더 작게
	_fill_egg_shape(face_center_y, face_r, face_chin_r, skin)

	# 3) 앞머리 — 물결 지그재그
	for x in range(0, W):
		var local := float(x) - cx
		if absf(local) > face_r:
			continue
		var wave := sin(local * 0.4) * 1.5
		var bang_bottom := face_center_y - 4.0 + wave
		for y in range(0, int(round(bang_bottom)) + 1):
			if _in_egg(x, y, face_center_y, face_r, face_chin_r):
				img.set_pixel(x, y, hair)

	# 4) 가르마
	_fill_rect(int(cx) - 1, 1, int(cx), 7, hair_shadow)

	# 5) 눈썹
	_fill_rect(int(cx) - 7, 10, int(cx) - 4, 11, hair_shadow)
	_fill_rect(int(cx) + 4, 10, int(cx) + 7, 11, hair_shadow)

	# 6) 눈
	_fill_circle(Vector2(cx - 5.0, 13.0), 1.5, eye_dark)
	_fill_circle(Vector2(cx + 5.0, 13.0), 1.5, eye_dark)
	_fill_circle(Vector2(cx - 5.0, 13.6), 0.9, eye_light)
	_fill_circle(Vector2(cx + 5.0, 13.6), 0.9, eye_light)
	_set_px(int(cx - 5.5), 12, eye_hi)
	_set_px(int(cx + 4.5), 12, eye_hi)

	# 7) 볼터치
	_fill_circle(Vector2(cx - 6.5, 15.5), 1.1, blush)
	_fill_circle(Vector2(cx + 6.5, 15.5), 1.1, blush)

	# 8) 입
	_fill_rect(int(cx) - 2, 17, int(cx) + 2, 18, eye_dark)

	# 9) 목
	_fill_rect(int(cx) - 3, 19, int(cx) + 3, 23, skin)
	_fill_rect(int(cx) - 3, 19, int(cx) + 3, 20, skin_shadow)

	# 10) 드레스 — 상체(핏) + 치마(플레어) 2단 곡선
	var bodice_top := dress_top
	var waist_y := dress_top + int(round((dress_bottom - dress_top) * 0.4))
	for y in range(bodice_top, waist_y):
		var t := float(y - bodice_top) / float(max(waist_y - bodice_top, 1))
		var s := smoothstep(0.0, 1.0, t)
		var half_w: float = lerp(4.5, 8.0, s)
		_fill_rect(int(round(cx - half_w)), y, int(round(cx + half_w)), y + 1, dress)
	for y in range(waist_y, dress_bottom):
		var t2 := float(y - waist_y) / float(max(dress_bottom - 1 - waist_y, 1))
		var s2 := smoothstep(0.0, 1.0, t2)
		var half_w2: float = lerp(8.0, 14.0, s2)
		var c := dress
		if y >= dress_bottom - 3:
			c = dress_shadow
		_fill_rect(int(round(cx - half_w2)), y, int(round(cx + half_w2)), y + 1, c)

	# 11) 목선(V넥)
	for y in range(dress_top, dress_top + 3):
		var w: float = lerp(3.0, 0.5, float(y - dress_top) / 2.0)
		_fill_rect(int(round(cx - w)), y, int(round(cx + w)), y + 1, skin)

	# 12) 세로 주름 2줄 (치마 부분에만)
	_fill_rect(int(cx) - 5, waist_y + 2, int(cx) - 4, dress_bottom - 3, dress_shadow)
	_fill_rect(int(cx) + 4, waist_y + 2, int(cx) + 5, dress_bottom - 3, dress_shadow)

	# 13) 팔 — 상체 옆면에 붙이고 손끝은 둥글게
	for y in range(28, 35):
		var t3: float = float(y - bodice_top) / float(max(waist_y - bodice_top, 1))
		var half_w3: float = lerp(4.5, 8.0, smoothstep(0.0, 1.0, t3))
		var left_edge := int(round(cx - half_w3))
		var right_edge := int(round(cx + half_w3))
		_fill_rect(left_edge - 3, y, left_edge, y + 1, skin)
		_fill_rect(right_edge, y, right_edge + 3, y + 1, skin)
	_fill_circle(Vector2(cx - 8.0, 32.0), 1.6, skin)
	_fill_circle(Vector2(cx + 8.0, 32.0), 1.6, skin)

	# 14) 다리
	_fill_rect(int(cx) - 4, 50, int(cx) - 1, 53, skin)
	_fill_rect(int(cx) + 1, 50, int(cx) + 4, 53, skin)

	# 15) 양말
	_fill_rect(int(cx) - 5, 52, int(cx) - 1, 55, sock)
	_fill_rect(int(cx) + 1, 52, int(cx) + 5, 55, sock)

	# 16) 신발 (+ 하이라이트 + 밑창)
	_fill_rect(int(cx) - 7, 55, int(cx), 61, shoe)
	_fill_rect(int(cx), 55, int(cx) + 7, 61, shoe)
	_fill_rect(int(cx) - 7, 55, int(cx) + 7, 56, shoe_hi)
	_fill_rect(int(cx) - 7, 59, int(cx) + 7, 61, shoe_sole)

	var out_dir := ProjectSettings.globalize_path("res://assets/sprites")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var out_path := "res://assets/sprites/player_draft_v7.png"
	var err := img.save_png(out_path)
	if err != OK:
		printerr("[GEN] PNG 저장 실패: %d" % err)
		quit(1)
		return

	print("[GEN] 저장 완료: %s" % out_path)
	quit(0)


func _in_egg(x: int, y: int, center_y: float, r: float, chin_r: float) -> bool:
	var dy := float(y) - center_y
	var dx := float(x) - cx
	var half_w: float
	if dy <= 0.0:
		var t: float = clamp(-dy / r, 0.0, 1.0)
		half_w = r * sqrt(max(0.0, 1.0 - t * t))
	else:
		var t2: float = clamp(dy / r, 0.0, 1.0)
		half_w = lerp(r, chin_r, smoothstep(0.0, 1.0, t2))
	if dy < -r or dy > r:
		return false
	return absf(dx) <= half_w


func _fill_egg_shape(center_y: float, r: float, chin_r: float, c: Color) -> void:
	var top := int(floor(center_y - r))
	var bottom := int(ceil(center_y + r))
	for y in range(max(top, 0), min(bottom + 1, H)):
		for x in range(0, W):
			if _in_egg(x, y, center_y, r, chin_r):
				_set_px(x, y, c)


func _set_px(x: int, y: int, c: Color) -> void:
	if x < 0 or x >= W or y < 0 or y >= H:
		return
	if c.a < 1.0:
		img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, c.a))
	else:
		img.set_pixel(x, y, c)


func _fill_rect(x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for y in range(max(y0, 0), min(y1, H)):
		for x in range(max(x0, 0), min(x1, W)):
			_set_px(x, y, c)


func _fill_circle(center: Vector2, r: float, c: Color) -> void:
	var x0 := int(floor(center.x - r))
	var x1 := int(ceil(center.x + r))
	var y0 := int(floor(center.y - r))
	var y1 := int(ceil(center.y + r))
	for y in range(max(y0, 0), min(y1 + 1, H)):
		for x in range(max(x0, 0), min(x1 + 1, W)):
			if Vector2(x, y).distance_to(center) <= r:
				_set_px(x, y, c)
