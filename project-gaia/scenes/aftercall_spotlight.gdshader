shader_type canvas_item;
render_mode blend_add, unshaded;

void fragment() {
	vec2 uv = (floor(UV * vec2(120.0, 162.0)) + 0.5) / vec2(120.0, 162.0);
	float y = uv.y;
	float distance_from_center = abs(uv.x - 0.5);
	float width = mix(0.055, 0.40, y);
	float cone = 1.0 - smoothstep(width * 0.70, width, distance_from_center);
	float core = 1.0 - smoothstep(width * 0.14, width * 0.56, distance_from_center);
	float rays = pow(max(0.0, cos((uv.x - 0.5) / width * 24.0 + TIME * 0.7)), 4.0);
	float fade_at_floor = 1.0 - smoothstep(0.63, 0.88, y);
	float intensity = (cone * 0.23 + core * 0.32 + rays * cone * 0.17) * fade_at_floor;

	// Small illuminated dust squares drift upward inside the beam.
	vec2 grid = vec2(uv.x * 17.0, (uv.y + TIME * 0.07) * 24.0);
	vec2 cell = floor(grid);
	float seed = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
	vec2 local = abs(fract(grid) - vec2(seed * 0.65 + 0.17, 0.5));
	float mote = step(0.82, seed) * (1.0 - step(0.09, max(local.x, local.y)));
	intensity += mote * cone * fade_at_floor * 0.68;

	float opacity = COLOR.a;
	vec3 light = mix(vec3(1.0, 0.53, 0.22), vec3(1.0, 0.91, 0.68), core);
	COLOR = vec4(light, clamp(intensity, 0.0, 1.0) * opacity);
}
