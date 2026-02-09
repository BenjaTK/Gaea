shader_type spatial;

// Adapted from https://godotshaders.com/shader/prototype-grid/

// Render
group_uniforms render;
uniform float metalic : hint_range(0.0, 1.0, 0.001) = 0.25;
uniform float roughness : hint_range(0.0, 1.0, 0.001) = 0.75;

// Main grid
group_uniforms grid;
uniform float grid_scale = 1.0;
uniform float grid_width : hint_range(0.0, 1.0, 0.001) = 0.01;
uniform vec4 grid_color : source_color = vec4(vec3(0.8), 1.0);
// Inside grid
group_uniforms inside_grid;
uniform float inside_scale : hint_range(0.0, 10.0, 1) = 1.0;
uniform float inside_width : hint_range(0.0, 1.0, 0.001) = 0.01;
uniform vec4 inside_color : source_color = vec4(0.8);
// Checker grid
group_uniforms checkered_grid;
uniform bool checkered = true;
uniform bool sub_checkered_grid = false;
uniform vec3 checkered_color : source_color = vec3(0.25);
uniform float checkered_blend_color : hint_range(0.0, 1.0, 0.001) = 0.1;

// NOTE - When using texture, enable LOD generation and reimport the texture
group_uniforms albedo_texture;
uniform bool use_inside_uv = false;
uniform bool use_albedo_color = false;
uniform sampler2D albedo_texture : hint_default_transparent, filter_linear_mipmap;
uniform float albedo_alpha : hint_range(0.0, 1.0, 0.001) = 0.5;

const float EPSILON = 0.0001;

varying vec3 vertex_uv;
varying vec3 vertex_normal;

// Fix preset colors, base RAW
vec3 srgb_to_linear(vec3 color) {
	return mix(
		pow((color.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
		color.rgb * (1.0 / 12.92),
		lessThan(color.rgb, vec3(0.04045))
	);
}

float grid_structure(vec3 uv, float width, float mult) {
	vec3 uvDDX = dFdx(uv);
	vec3 uvDDY = dFdy(uv);

	vec3 uv_deriv = vec3(
		length(vec2(uvDDX.x, uvDDY.x)),
		length(vec2(uvDDX.y, uvDDY.y)),
		length(vec2(uvDDX.z, uvDDY.z))
	);
	uv_deriv = max(uv_deriv, EPSILON);
	vec3 line_AA = uv_deriv * 1.5;

	vec3 width_value = 1.0 - vec3(width);

	vec3 target_width = width > 0.5 ? width_value : 1.0 - width_value;
	vec3 draw_width = clamp(target_width, uv_deriv, vec3(0.5));

	vec3 grid_uv = abs(fract(uv * mult) * 2.0 - 1.0);
	grid_uv = width > 0.5 ? 1.0 - grid_uv : grid_uv;
	// Blend normal sides
	float blend_value = 1.0;
	vec3 blend_normal = abs(normalize(cross(dFdy(uv), dFdx(uv))));
	vec3 blend_factor = smoothstep(blend_value - EPSILON, blend_value + EPSILON, blend_normal);
	blend_factor = width > 0.5 ? 1.0 - blend_factor : blend_factor;

	vec3 grid_normal_a = width > 0.5 ? vec3(-1.0) : grid_uv;
	vec3 grid_normal_b = width > 0.5 ? grid_uv : vec3(1.0);

	grid_uv = mix(grid_normal_a, grid_normal_b, blend_factor);

	vec3 grid_base = smoothstep(draw_width + line_AA, draw_width - line_AA, grid_uv);
	grid_base *= clamp(target_width / draw_width, EPSILON, 1.0);
	grid_base = mix(grid_base, target_width, clamp(uv_deriv * 2.0 - 1.0, EPSILON, 1.0));
	grid_base = width > 0.5 ? 1.0 - grid_base : grid_base;

	return mix(mix(grid_base.x, 1.0, grid_base.y), 1.0, grid_base.z);
}

float checkered_grid(vec3 uv, float subdivide) {
	// Checkered grid
	vec3 board_uv = floor(uv - 0.5 - subdivide + EPSILON);
	float board = mod((board_uv.x) + (board_uv.y) + (board_uv.z), 2.0);
	// Blend normal sides
	float blend_value = 1.0;
	vec3 blend_normal = abs(normalize(cross(dFdy(uv), dFdx(uv))));
	vec3 blend_factor = smoothstep(blend_value - EPSILON, blend_value + EPSILON, blend_normal);
	// Filter AA
	vec3 smooth_uv = abs(fract(uv - subdivide) * 2.0 - 1.0);
	smooth_uv = mix(smooth_uv, vec3(1.0), blend_factor);

	vec3 uv_deriv = fwidth(uv);
	uv_deriv = max(uv_deriv, EPSILON);
	vec3 uv_AA = uv_deriv * 4.0;

	float smooth_value = 1.0;
	float smooth_edge = smoothstep(0.0, uv_AA.x * smooth_value, smooth_uv.x);
	smooth_edge *= smoothstep(0.0, uv_AA.y * smooth_value, smooth_uv.y);
	smooth_edge *= smoothstep(0.0, uv_AA.z * smooth_value, smooth_uv.z);

	vec3 moire_step = smoothstep(vec3(1.0), vec3(0.0), uv_deriv);
	float moire_range = (moire_step.x * moire_step.y * moire_step.z);
	// Applay AA/Moire blend color
	board = mix(0.0, board, smooth_edge);
	board = mix(0.05, board, moire_range);

	return board;
}

vec4 triplanar_texture(sampler2D tex, vec3 uv, bool sub) {
	uv = sub ? uv : uv * 0.5 + 0.5;

	vec4 base_albedo = texture(tex, uv.xy);

	vec3 tri_normal = vec3(0.0);
	vec2 blend_normal = abs(normalize(vertex_normal.xz));
	tri_normal.xz = max(vec2(0.0), blend_normal - 0.67);
	tri_normal.xz /= max(0.00001, dot(tri_normal.xz, vec2(1.0)));

	tri_normal.y = clamp((abs(vertex_normal.y) - 0.675) * 80.0, 0.0, 1.0);
	tri_normal.xz *= (1.0 - tri_normal.y);

	vec4 albedo = (
		base_albedo * tri_normal.x +
		base_albedo * tri_normal.y +
		base_albedo * tri_normal.z
	);
	return albedo;
}

void vertex() {
	vertex_normal = NORMAL;

	vertex_uv = mix(VERTEX, (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz, 0.0);
	vertex_uv = mix(vertex_uv, vec3(UV * vec2(3, 2), 0.0), 1.0);
	vertex_uv *= vec3(1.0, -1.0, 1.0);
}

void fragment() {
	vec3 base_uv = vertex_uv * grid_scale;

	// Base Grid
	float base_grid = grid_structure(base_uv, grid_width, 0.5);
	// Inside Grid
	float inside_factor = mod(inside_scale, 2.0) < EPSILON ? 0.5 : 0.0;
	float inside_reduce = floor(inside_scale / 2.0) - (abs(inside_factor - 0.5) < EPSILON ? 1.0 : 0.0);
	vec3 inside_uv = base_uv * (inside_scale - inside_factor - inside_reduce);
	float inside_grid = grid_structure(inside_uv - (0.5 - inside_factor), inside_width, 1.0);
	inside_grid = inside_scale < EPSILON ? 0.0 : inside_grid;
	inside_grid = mix(inside_grid, 0.0, smoothstep(0.0 - EPSILON, 0.5 + EPSILON, base_grid));
	// Checkerboard
	vec3 checker_uv = mix(base_uv / 2.0, base_uv, float(sub_checkered_grid));
	float checkerboard = 0.0;
	checkerboard = checkered ? checkered_grid(checker_uv, sub_checkered_grid ? 0.5 : 0.0) : 0.0;

	// Albedo texture(triplanar)
	vec4 albedo = triplanar_texture(
			albedo_texture,
			use_inside_uv ? inside_uv - 0.5 - (0.5 - inside_factor) : base_uv,
			use_inside_uv
	);

	// Color
	vec3 color = srgb_to_linear(COLOR.rgb);

	// Grayscale
	if (use_albedo_color == false) {
		float gray = dot(albedo.rgb, vec3(0.299, 0.587, 0.114));
		albedo.rgb = vec3(gray);
	}

	// Applay texture/base color/checkered
	vec3 board = mix(color, checkered_color, checkerboard * checkered_blend_color);
	albedo.rgb = use_albedo_color ? albedo.rgb : albedo.rgb * board;

	// Mix Color
	vec3 grid_a = mix(board, mix(board, albedo.rgb, albedo.a), albedo_alpha);
	vec3 grid_b = mix(grid_a, inside_color.rgb, inside_grid * inside_color.a);
	vec3 grid = mix(grid_b, grid_color.rgb, base_grid * grid_color.a);

	ALBEDO = grid;
	METALLIC = metalic;
	ROUGHNESS = roughness;
}