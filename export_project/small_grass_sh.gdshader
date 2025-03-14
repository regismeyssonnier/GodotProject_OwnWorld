shader_type spatial;

// Désactiver le culling
render_mode depth_prepass_alpha, cull_disabled;

uniform sampler2D normal_map : hint_normal;  // Normal Map
uniform sampler2D alpha_mask ;    // Mask de transparence (noir et blanc)
uniform sampler2D texture_diffuse ;  // Texture diffuse
uniform sampler2D height_map ;  // Height Map (pour displacement)
uniform float transparency_threshold = 0.5;  // Seuil de transparence
uniform float displacement_strength = 0.1;  // Force du displacement
uniform sampler2D roughness_map; // Texture de roughness (noir et blanc)
uniform sampler2D specular_map;               // Specular map (optionnel)

uniform sampler2D exclusion_mask; // Ton masque blanc/noir

// Uniforms pour les transformations UV
uniform vec2 exclusion_uv_offset; // Décalage des UV du masque d'exclusion
uniform vec2 exclusion_uv_scale;  // Facteur de mise à l'échelle des UV du masque d'exclusion


varying vec3 tangent;     // Tangente du vertex
varying vec3 bitangent;   // Bitangente du vertex
varying vec3 normal;      // Normal du vertex

varying vec3 frag_tangent;
varying vec3 frag_bitangent;
varying vec3 frag_normal;
varying vec2 frag_uv;
varying vec2 frag_exclusion_uv; // UV ajustés pour le masque d'exclusion



void vertex() {
    // Passer les informations aux shaders suivants
    frag_tangent = tangent;
    frag_bitangent = bitangent;
    frag_normal = normal;
    frag_uv = UV;  // Passer la coordonnée UV
	
	// Utiliser les coordonnées mondiales pour obtenir des UV pour l'exclusion (par exemple, projetées sur une surface)
    // Ici, tu pourrais utiliser des coordonnées mondiales pour déterminer la "position" du terrain et la mapper dans les UV du masque.
    vec4 world_position = MODEL_MATRIX * vec4(VERTEX, 1.0);
	frag_exclusion_uv = ((world_position.xyz.xz + 10.0) / 20.0) + exclusion_uv_offset;
	
	   
}

void fragment() {
    // Calcul de la matrice TBN (Tangent, Bitangent, Normal)
    mat3 TBN_matrix = mat3(frag_tangent, frag_bitangent, frag_normal); // Crée la matrice TBN
    
    // Appliquer la normal map
    vec3 normal_map_value = texture(normal_map, frag_uv).xyz * 2.0 - 1.0;  // Conversion de la normal map de [0,1] à [-1,1]
    
	//float displacement = texture(height_map, frag_uv).r; // Lire la valeur de la displacement map
    //displacement = displacement * 2.0 - 1.0;  // Convertir la valeur pour avoir un intervalle [-1, 1]
    //normal_map_value = normal_map_value * displacement * displacement_strength;
         	
	vec3 transformed_normal = normalize(TBN_matrix * normal_map_value);  // Transformation de la normale dans l'espace de la texture
    
    // Obtenir la valeur du masque alpha (noir et blanc)
    float alpha = texture(alpha_mask, frag_uv).r;  // Prendre le canal rouge de l'image en noir et blanc

    // Appliquer un seuil de transparence
    //alpha = alpha > transparency_threshold ? 1.0 : 0.0;  // Si l'alpha > seuil, on garde la transparence, sinon on la rend opaque

    // Appliquer la couleur de la texture diffuse
    vec4 color = texture(texture_diffuse, frag_uv);

    // Appliquer l'alpha sur la couleur
    color.a *= alpha;
	
	// Appliquer le masque d'exclusion sur les UV modifiés
    float exclusion_value = texture(exclusion_mask, frag_exclusion_uv).r; // Lire la valeur du masque d'exclusion
    if (exclusion_value > 0.5) {
        discard;  // Ne pas dessiner si la zone est considérée comme un chemin (exclusion)
    }
	
	if (color.a < 0.1) {
        discard;
    }
	
	 // Appliquer la rugosité (roughness)
    //float roughness = texture(roughness_map, frag_uv).r * 1.1;  // Prendre la rugosité de la texture
    //roughness = 1.0 - roughness;  // Inverser pour que 0 soit rugueux et 1 lisse
	
	// Spéculaire (par texture si elle existe, sinon valeur par défaut)
	float specular = 0.5;  // valeur par défaut
	specular = texture(specular_map, frag_uv).r;
	specular = clamp(specular, 0.0, 1.0);
	
    
    // Définir l'albedo, la normal et l'alpha du fragment
    ALBEDO = color.rgb;
    NORMAL = transformed_normal ;
    ALPHA = color.a;  // Appliquer l'alpha
	//ROUGHNESS = roughness;  // Appliquer la rugosité
	SPECULAR = specular;
}