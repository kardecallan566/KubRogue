extends SceneTree
const History = preload("res://scripts/c12/history_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C12 HISTORY FAIL: " + reason)

func _clean(path: String) -> void:
    for suffix in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))

func sample(id: int, victory: bool = true, stability: int = 80,
        combo: int = 5, contracts: int = 3) -> Dictionary:
    return {
        "run_id":id, "result":"victory" if victory else "defeat",
        "mode":"daily" if id%2==0 else "normal",
        "date":"2026-10-14", "seed":12345,
        "finished_at":"2026-10-14T07:12:00", "wave":5 if victory else 3,
        "cubes":18, "coins":315, "xp":22, "combo":combo,
        "contracts":contracts, "fevers":2, "skills":4,
        "stability":stability
    }

func _run() -> void:
    var path := "user://c12_history_test.json"
    _clean(path)
    var svc: History = History.new()
    svc.configure(Store.new(path))
    check(svc.writable and svc.recent().is_empty(), "new file starts empty")
    check(History.medal_for(sample(1))=="gold", "gold requires win with stability, combo and contracts")
    check(History.medal_for(sample(1,true,55,2,1))=="silver", "moderate victory is silver")
    check(History.medal_for(sample(1,true,12,1,0))=="bronze", "hard victory is bronze")
    check(History.medal_for(sample(1,false,100,99,3))=="none", "loss earns no medal")
    check(not svc.record_finish({"run_id":0,"result":"victory"}),"bad run ID rejected")
    check(not svc.record_finish({"run_id":8,"result":"invalid"}),"bad result rejected")
    check(svc.record_finish(sample(1)), "first victory recorded")
    check(svc.record_finish(sample(1)), "same run can be safely retried")
    check(svc.runs.size()==1 and svc.victories()==1,"no duplicate medal created")
    check(svc.latest()["medal"]=="gold" and svc.best_by("combo")==5,"best record calculated")
    for id in range(2,16):
        check(svc.record_finish(sample(id,id%3!=0,55,2,1)),
            "completed run recorded")
    check(svc.runs.size()==History.MAX_RUNS,"only twelve recent runs kept")
    check(int(svc.runs[0]["run_id"])==4 and int(svc.latest()["run_id"])==15,
        "oldest entries removed, newest remain")
    var disk: Dictionary = Store.new(path).read_json()
    check(int(disk["version"])==History.VERSION and disk["runs"].size()==12,
        "history committed as bounded independent JSON")
    var reload: History = History.new()
    reload.configure(Store.new(path))
    check(reload.runs.size()==12 and reload.latest()["run_id"]==15,"history survives reload")
    check(reload.record_finish(sample(15)) and reload.runs.size()==12,"dedup survives restart")
    var file := FileAccess.open(path,FileAccess.WRITE)
    check(file!=null,"fault fixture")
    if file!=null:
        file.store_string("{broken")
        file.close()
    var restored: History = History.new()
    restored.configure(Store.new(path))
    check(restored.writable and not restored.runs.is_empty(),"intact backup recovers broken primary")
    _clean(path)
    var future := {"version":77, "runs":[sample(999)]}
    check(Store.new(path).write_json(future),"future-schema fixture saved")
    var future_bytes: String = FileAccess.get_file_as_string(path)
    restored.configure(Store.new(path))
    check(not restored.writable and restored.last_error.contains("preservado"),"future schema locked")
    check(not restored.record_finish(sample(1000)),"no future file overwrite")
    check(FileAccess.get_file_as_string(path)==future_bytes,"future file unchanged")
    _clean(path)
    svc.free()
    reload.free()
    restored.free()
    print("KubRogue C12 history unit: %d failures" % failures)
    quit(0 if failures==0 else 1)
