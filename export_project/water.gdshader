shader_type spatial;

uniform vec3 uAlbedo : source_color;  // Base color of the water
uniform sampler2D uTexureNormal;      // First normal map
uniform sampler2D uTexureNormal2;     // Second normal map
uniform float uNormalMix: hint_range(0.0, 1.0, 0.2) = 0.2;  // Blending factor for normals
uniform vec2 uWaveDirection = vec2(1.0, 0.0);  // Wave direction 1
uniform vec2 uWaveDirection2 = vec2(0.0, 1.0); // Wave direction 2
uniform float uTimeScale: hint_range(0.0, 0.2, 0.001) = 0.0015;  // Animation speed
uniform float uWaveScale = 1.6;       // UV scaling for waves
uniform float uWaveHeight: hint_range(0.0, 10.0, 0.01) = 2.0;    // Max height offset for waves
uniform float uSpecularStrength = 10.0;  // Strength of specular highlight

varying vec2 vUv;  // Passing UV to fragment shader

// Vertex shader for displacing geometry
void vertex() {
    vUv = UV; // Pass UV to fragment shader
    
    // Animate the wave UVs (same as fragment shader)
    vec2 time1 = (TIME * uWaveDirection) * uTimeScale;
    vec2 time2 = (TIME * uWaveDirection2) * uTimeScale;

    // Sample both normal maps for displacement
    vec3 normal1 = texture(uTexureNormal, (UV * uWaveScale) + time1).rgb;
    vec3 normal2 = texture(uTexureNormal2, (UV * uWaveScale) + time2).rgb;

    // Mix both normals
    vec3 blendedNormal = mix(normal1, normal2, uNormalMix);

    // Calculate wave height based on the combined normal
    float heightValue = (blendedNormal.r + blendedNormal.g + blendedNormal.b) / 3.0;

    // Offset vertex position on the Y axis
    float heightOffset = (heightValue * 2.0 - 1.0) * uWaveHeight;

    VERTEX.y += heightOffset;

    // Pas de recalcul manuel des normales ici
}

void fragment() {
    // Animate waves (same as vertex shader)
    vec2 time1 = (TIME * uWaveDirection) * uTimeScale;
    vec2 time2 = (TIME * uWaveDirection2) * uTimeScale;

    // Sample normals with animated UVs
    vec3 normal1 = texture(uTexureNormal, (vUv * uWaveScale) + time1).rgb;
    vec3 normal2 = texture(uTexureNormal2, (vUv * uWaveScale) + time2).rgb;

    // Mix the normals for more complex wave detail
    vec3 normal = mix(normal1, normal2, uNormalMix);

    // Light & view vectors
    vec3 L = normalize(vec3(0.5, 1.0, 0.5));  // Light direction
    vec3 V = normalize(-FRAGCOORD.xyz);       // View direction
    vec3 H = normalize(L + V);                // Half vector

    // Specular highlight using the normal map
    float spec = pow(max(dot(normalize(normal), H), 0.0), 200.0);

    // Final specular reflection intensity
    float specularReflection = mix(0.1, uSpecularStrength, spec);

    // Final color with specular highlight influence
    ALBEDO = uAlbedo * (1.0 - specularReflection);

    METALLIC = 0.0;
    ROUGHNESS = 0.3;
    SPECULAR = 0.1 + specularReflection;

    // Apply the normal map (affecte l'éclairage)
    NORMAL_MAP = normal;
}
