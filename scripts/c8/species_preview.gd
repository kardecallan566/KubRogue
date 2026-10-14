extends Control
## Tiny isometric Rubik cubie preview for codex/mode cards.
## Drawn procedurally, not a generated asset or a placeholder screenshot.
var dimension := 2
var discovered := true
var tone := Color("#63bca7")

func _ready() -> void:
    custom_minimum_size = Vector2(116,116)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func configure(n: int, unlocked: bool, accent: Color = Color("#60bba4")) -> void:
    dimension = clampi(n,2,5)
    discovered = unlocked
    tone = accent
    queue_redraw()

func _paint_face(origin: Vector2, dx: Vector2, dy: Vector2,
        front: Color) -> void:
    for ix in range(dimension):
        for iy in range(dimension):
            var a := origin + dx * (float(ix) / dimension) + dy * (float(iy)/dimension)
            var bx := dx / float(dimension)
            var by := dy / float(dimension)
            var corners := PackedVector2Array([a,a+bx,a+bx+by,a+by])
            var fill := front if discovered else Color("#718279")
            draw_colored_polygon(corners,fill)
            draw_polyline(PackedVector2Array([a,a+bx,a+bx+by,a+by,a]),
                Color("#213e43"),2.1,true)
            if discovered:
                draw_line(a + by * 0.12,a + bx * 0.7 + by * 0.12,
                    Color.WHITE*Color(1,1,1,0.20),1.0,true)

func _draw() -> void:
    var sc := minf(size.x/116.0,size.y/116.0)
    draw_set_transform(Vector2((size.x-116*sc)/2.0,(size.y-116*sc)/2.0),
        0.0,Vector2.ONE*sc)
    draw_circle(Vector2(57,102),36,Color("#2f4c40",0.12))
    var top := Vector2(58,10)
    var right := Vector2(100,32)
    var front := Vector2(58,53)
    var left := Vector2(16,32)
    var lower := Vector2(58,103)
    _paint_face(top,right-top,left-top,
        tone.lightened(0.28) if discovered else Color("#718279"))
    _paint_face(left,front-left,Vector2(0,50),
        Color("#f7c763") if discovered else Color("#718279"))
    _paint_face(front,right-front,Vector2(0,50),
        Color("#68b8ee") if discovered else Color("#718279"))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
