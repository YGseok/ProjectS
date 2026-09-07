extends Node
## 나무 등 오클루전 오브젝트에 붙인 occlusion_reveal.gdshader의
## reveal_center를 매 프레임 플레이어 위치로 갱신한다. 씬마다 하나만
## 두면 되고, 셰이더 머티리얼을 공유하는 오브젝트 전부에 한 번에 적용된다
## (같은 ShaderMaterial 리소스를 여러 Sprite2D가 공유하는 구조).

@export var shader_material: ShaderMaterial

var _player: Node2D

func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	if _player == null or shader_material == null:
		return
	shader_material.set_shader_parameter("reveal_center", _player.global_position)
