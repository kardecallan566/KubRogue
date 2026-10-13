extends RefCounted
## A truly rounded rectangular solid: flat faces, cylindrical edge transitions and
## spherical corner transitions. The same ArrayMesh is shared by all cubies.
static func make_mesh(size: Vector3, radius: float, bevel_steps: int = 3) -> ArrayMesh:
    var half := size * 0.5
    var r: float = clampf(radius, 0.0001, minf(half.x, minf(half.y, half.z)) * 0.98)
    var steps: int = maxi(1, bevel_steps)
    var normals: Array[Vector3] = [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD]
    var tangents: Array[Vector3] = [Vector3.FORWARD, Vector3.BACK, Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT, Vector3.LEFT]
    var bitangents: Array[Vector3] = [Vector3.UP, Vector3.UP, Vector3.FORWARD, Vector3.BACK, Vector3.UP, Vector3.UP]
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for f in range(6):
        var n: Vector3 = normals[f]
        var u: Vector3 = tangents[f]
        var v: Vector3 = bitangents[f]
        var hu: float = absf(u.dot(half))
        var hv: float = absf(v.dot(half))
        var us := _samples(hu, r, steps)
        var vs := _samples(hv, r, steps)
        for iy in range(vs.size() - 1):
            for ix in range(us.size() - 1):
                # The u x v basis points inward; reverse winding for outward triangles.
                _vertex(tool, n, u, v, us[ix], vs[iy], hu, hv, half, r)
                _vertex(tool, n, u, v, us[ix + 1], vs[iy + 1], hu, hv, half, r)
                _vertex(tool, n, u, v, us[ix + 1], vs[iy], hu, hv, half, r)
                _vertex(tool, n, u, v, us[ix], vs[iy], hu, hv, half, r)
                _vertex(tool, n, u, v, us[ix], vs[iy + 1], hu, hv, half, r)
                _vertex(tool, n, u, v, us[ix + 1], vs[iy + 1], hu, hv, half, r)
    return tool.commit()

static func _samples(extent: float, r: float, steps: int) -> Array[float]:
    var out: Array[float] = []
    for i in range(steps + 1):
        out.append(-extent + r * float(i) / float(steps))
    out.append(0.0)
    for i in range(steps + 1):
        out.append(extent - r + r * float(i) / float(steps))
    return out

static func _vertex(tool: SurfaceTool, n: Vector3, u: Vector3, v: Vector3,
        a: float, b: float, hu: float, hv: float, half: Vector3, r: float) -> void:
    var surface: Vector3 = n * absf(n.dot(half)) + u * a + v * b
    var inner: Vector3 = half - Vector3.ONE * r
    var center := Vector3(
        clampf(surface.x, -inner.x, inner.x),
        clampf(surface.y, -inner.y, inner.y),
        clampf(surface.z, -inner.z, inner.z)
    )
    var normal: Vector3 = (surface - center).normalized()
    tool.set_normal(normal)
    tool.set_uv(Vector2((a + hu) / (2.0 * hu), (b + hv) / (2.0 * hv)))
    tool.add_vertex(center + normal * r)
