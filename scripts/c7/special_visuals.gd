extends RefCounted
## C7 optional cosmetic differences. Sticker colors stay untouched.
const FEATURES := {
    "golden": {
        "body": Color("#b37c24"), "edge": Color("#ffd866"),
        "ring": Color("#ffe69a"), "title": "✦ DOURADO",
        "glow": Color("#ffc75f")
    },
    "armored": {
        "body": Color("#464063"), "edge": Color("#b7a4ee"),
        "ring": Color("#c1a6f2"), "title": "◆ BLINDADO",
        "glow": Color("#ab89eb")
    }
}

static func is_special(kind: String) -> bool:
    return FEATURES.has(kind)

static func apply(actor_root: Node3D, cube, kind: String) -> Node3D:
    if not FEATURES.has(kind):
        return null
    var entry: Dictionary = FEATURES[kind]
    var body_mat := StandardMaterial3D.new()
    body_mat.albedo_color = entry["body"]
    body_mat.roughness = 0.32
    body_mat.metallic = 0.18 if kind == "golden" else 0.05
    for body in cube.body_nodes:
        body.material_override = body_mat
    var decorations := Node3D.new()
    decorations.name = "SpecialEffects_%s" % kind
    actor_root.add_child(decorations)

    var ring := MeshInstance3D.new()
    ring.name = "SpecialHalo"
    var torus := TorusMesh.new()
    torus.inner_radius = 0.94
    torus.outer_radius = 1.015
    ring.mesh = torus
    ring.position.y = 0.075
    var ring_material := StandardMaterial3D.new()
    ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    ring_material.albedo_color = entry["ring"]
    ring_material.emission_enabled = true
    ring_material.emission = entry["glow"]
    ring_material.emission_energy_multiplier = 0.40
    ring.material_override = ring_material
    decorations.add_child(ring)

    var sign := Label3D.new()
    sign.name = "SpecialLabel"
    sign.text = String(entry["title"])
    sign.font_size = 27
    sign.pixel_size = 0.008
    sign.position = Vector3(0, 1.24, 0)
    sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sign.modulate = entry["edge"]
    sign.outline_modulate = Color("#1a2532")
    sign.outline_size = 7
    decorations.add_child(sign)

    var top := MeshInstance3D.new()
    top.name = "SpecialGem"
    var mesh := SphereMesh.new()
    mesh.radius = 0.12
    mesh.height = 0.23
    top.mesh = mesh
    top.position = Vector3(0, 1.56, 0)
    top.material_override = ring_material
    decorations.add_child(top)
    return decorations
