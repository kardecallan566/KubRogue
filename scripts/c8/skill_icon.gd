extends Control
## Original, vector-drawn badges for all eight C3 skills.
## No asset imports; scales clearly with Godot Compatibility renderer.
const INK := Color("#24463f")
const CATEGORIES := {
    "pulso_agil":"#64b7ec", "dedo_certeiro":"#58c5a7",
    "luva_magnetica":"#ab91e5", "bolsa_encantada":"#efbc56",
    "ritmo_mestre":"#f2a17c", "folego_extra":"#7db5eb",
    "olhar_cubista":"#89bae3", "mao_paciente":"#71ccab"
}
var skill_id := "pulso_agil"

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = Vector2(58, 58)

func set_skill(id: String) -> void:
    skill_id = id
    queue_redraw()

func _line(a: Vector2, b: Vector2, width: float = 3.0, color: Color = INK) -> void:
    draw_line(a, b, color, width, true)

func _poly(points: Array, fill: Color, edge: Color = INK) -> void:
    var poly := PackedVector2Array(points)
    draw_colored_polygon(poly, fill)
    var closed := poly.duplicate()
    closed.append(poly[0])
    draw_polyline(closed, edge, 2.7, true)

func _draw() -> void:
    if size.x <= 0 or size.y <= 0:
        return
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(size.x / 64.0, size.y / 64.0))
    var base := Color(String(CATEGORIES.get(skill_id, "#92c4ad")))
    draw_circle(Vector2(32, 34), 27, Color("#2e4b47", 0.17))
    draw_circle(Vector2(32, 30), 27, base.darkened(0.17))
    draw_circle(Vector2(31, 28), 25, base)
    draw_circle(Vector2(20, 14), 10, Color("#ffffff", 0.18))
    match skill_id:
        "pulso_agil":
            _poly([Vector2(34,9),Vector2(20,34),Vector2(30,34),Vector2(26,53),
                Vector2(48,26),Vector2(35,26)],Color("#fff6ce"))
            _line(Vector2(11,28),Vector2(19,28),2.5)
            _line(Vector2(10,37),Vector2(18,37),2.5)
        "dedo_certeiro":
            draw_arc(Vector2(32,29),17,0,TAU,40,INK,3,true)
            draw_arc(Vector2(32,29),8,0,TAU,32,Color.WHITE,3,true)
            _line(Vector2(32,8),Vector2(32,20))
            _line(Vector2(32,38),Vector2(32,51))
            _line(Vector2(12,29),Vector2(24,29))
            _line(Vector2(41,29),Vector2(52,29))
            draw_circle(Vector2(32,29),4,INK)
        "luva_magnetica":
            _poly([Vector2(18,13),Vector2(26,13),Vector2(26,33),Vector2(30,39),
                Vector2(36,39),Vector2(39,33),Vector2(39,13),Vector2(47,13),
                Vector2(47,35),Vector2(42,45),Vector2(33,49),Vector2(24,46),
                Vector2(18,36)],Color("#f1f6ff"))
            _line(Vector2(18,23),Vector2(26,23),4,Color("#e36f68"))
            _line(Vector2(39,23),Vector2(47,23),4,Color("#e36f68"))
        "bolsa_encantada":
            _poly([Vector2(23,15),Vector2(40,15),Vector2(37,22),Vector2(46,33),
                Vector2(43,48),Vector2(20,48),Vector2(17,34),Vector2(26,22)],Color("#ffe79b"))
            _line(Vector2(24,23),Vector2(39,23),3.4)
            draw_arc(Vector2(32,36),7,0,TAU,24,INK,2.4,true)
            _line(Vector2(32,28),Vector2(32,44),2.4)
        "ritmo_mestre":
            for i in range(3):
                var x := 14.0 + float(i)*13.0
                _poly([Vector2(x,26),Vector2(x+10,26),Vector2(x+10,37),
                    Vector2(x,37)],Color("#fff2c7"))
            _line(Vector2(12,44),Vector2(51,44),3.2)
            _line(Vector2(21,15),Vector2(26,21),2)
            _line(Vector2(31,12),Vector2(31,20),2)
            _line(Vector2(42,15),Vector2(37,21),2)
        "folego_extra":
            draw_circle(Vector2(32,32),19,Color("#f9fdff"))
            draw_arc(Vector2(32,32),19,0,TAU,40,INK,3,true)
            _line(Vector2(32,32),Vector2(32,20),3.2)
            _line(Vector2(32,32),Vector2(43,36),3.2)
            draw_circle(Vector2(32,32),3.5,INK)
            _line(Vector2(25,10),Vector2(40,10),3)
        "olhar_cubista":
            _poly([Vector2(11,31),Vector2(20,20),Vector2(32,17),Vector2(45,22),
                Vector2(53,31),Vector2(43,41),Vector2(31,45),Vector2(19,41)],Color("#f8ffff"))
            draw_circle(Vector2(32,31),10,Color("#78b9dd"))
            draw_circle(Vector2(32,31),5,INK)
            draw_circle(Vector2(29,28),2.5,Color.WHITE)
        "mao_paciente":
            _poly([Vector2(32,11),Vector2(49,19),Vector2(47,39),
                Vector2(32,51),Vector2(17,39),Vector2(15,19)],Color("#e6fff0"))
            _line(Vector2(32,23),Vector2(32,41),5,Color("#328d65"))
            _line(Vector2(23,32),Vector2(41,32),5,Color("#328d65"))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
