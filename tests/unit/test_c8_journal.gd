extends SceneTree
const Journal = preload("res://scripts/c8/journal_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool, why: String) -> void:
    if not ok:
        fails += 1
        push_error("C8 UNIT FAIL: " + why)
func _clean(p: String) -> void:
    for x in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p + x))
func _run() -> void:
    var path := "user://c8_journal_unit.json"
    _clean(path)
    var service: Journal = Journal.new()
    service.configure(Store.new(path))
    check(service.CATALOG.size() == 7 and service.discovery_total() == 0, "seven locked species")
    check(not service.record_cube("unknown", 1, 1), "unknown species rejected")
    check(not service.record_cube("apprentice", -1, 1), "invalid run rejected")
    service.begin_run(1)
    check(service.contract_status().size() == 3, "three independent contracts")
    for id in range(1, 5):
        var out: Dictionary = service.register_solve("apprentice", id)
        check(int(out["bonus"]) == (20 if id == 4 else 0), "four cubes give one 20-coin reward")
    check(int(service.register_solve("apprentice", 4)["bonus"]) == 0,
        "repeating a cube never duplicates contract bonus")
    check(service.completed_contracts() == 1, "first contract done")
    check(service.register_solve("golden", 5)["bonus"] == 0, "one rare is insufficient")
    check(service.register_solve("armored", 6)["bonus"] == 35, "second rare pays one bonus")
    check(service.register_solve("master4", 7)["bonus"] == 60, "first large puzzle pays 60")
    check(service.register_solve("master5", 8)["bonus"] == 0, "large contract cannot pay again")
    check(service.completed_contracts() == 3 and service.run_bonus_total == 115,
        "bonus cap of 115 per run")
    check(service.record_cube("master4", 1, 7), "first discovery persisted")
    check(service.record_cube("master4", 1, 7), "same cube event idempotent")
    check(service.record_cube("master5", 1, 8), "second discovery persisted")
    check(service.discovery_total() == 2 and service.solved_count("master4") == 1,
        "discovery counters correct")
    var reload: Journal = Journal.new()
    reload.configure(Store.new(path))
    check(reload.discovery_total() == 2 and reload.solved_count("master5") == 1,
        "journal survives application restart")
    check(reload.record_cube("master4", 1, 7) and reload.solved_count("master4") == 1,
        "dedupe survives reload")
    reload.begin_run(2)
    check(reload.completed_contracts() == 0, "new run resets temporary objectives")
    check(reload.register_solve("master5", 10)["bonus"] == 60, "new run rewards new objectives")
    check(reload.solved_count("master5") == 1, "new run never clears permanent discoveries")
    service.free()
    reload.free()
    _clean(path)
    print("KubRogue C8 journal and contracts: %d failures" % fails)
    quit(0 if fails == 0 else 1)
