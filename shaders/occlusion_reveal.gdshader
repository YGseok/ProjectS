shader_type canvas_item;

// 플레이어가 이 스프라이트(나무 등) 뒤로 가려질 때, 플레이어 주변 원형
// 범위만 반투명하게 "구멍"을 내서 캐릭터가 비쳐 보이게 한다.
// reveal_center는 월드(글로벌) 좌표 — occlusion_reveal_manager.gd가
// 매 프레임 플레이어의 global_position으로 갱신한다.

uniform vec2 reveal_center = vec2(-9999.0, -9999.0);
uniform float reveal_radius = 34.0;
uniform float reveal_softness = 18.0;
uniform float reveal_min_alpha = 0.35;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float dist = distance(world_pos, reveal_center);
	float reveal = smoothstep(reveal_radius, reveal_radius + reveal_softness, dist);
	float alpha_mult = mix(reveal_min_alpha, 1.0, reveal);
	COLOR = vec4(tex_color.rgb, tex_color.a * alpha_mult);
}
