extends SceneTree
const Medals = preload("res://scripts/c14/medal_service.gd")
const Journal = preload("res://scripts/c8/journal_service.gd")
const Progress = preload("res://scripts/c4/progress_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool,reason: String) -> void:
    if not ok:
        fails += 1
        push_error("C14 UNIT FAIL: " + reason)

func _clean(p: String) -> void:
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+s))

func _run() -> void:
    var money_path := "user://c14_unit_money.json"
    var species_path := "user://c14_unit_species.json"
    _clean(money_path)
    _clean(species_path)
    var wallet: Progress = Progress.new()
    wallet.configure(Store.new(money_path))
    var journal: Journal = Journal.new()
    journal.configure(Store.new(species_path))
    var medals: Medals = Medals.new()
    check(Medals.MEDALS.size()==12,"12 original Garden Medals")
    check(medals.trophy_count(journal,wallet)==0,"a new player has no medal")
    medals.snapshot(journal,wallet)
    check(medals.newly_unlocked(journal,wallet).is_empty(),"baseline does not notify")

    journal.begin_run(1)
    check(journal.record_cube("apprentice",1,1),"first real documented cube")
    var found: Array[Dictionary] = medals.newly_unlocked(journal,wallet)
    check(found.size()==1 and String(found[0]["id"])=="first",
        "first cube triggers exactly one medal")
    check(medals.newly_unlocked(journal,wallet).is_empty(),
        "the same achievement does not announce twice")
    check(medals.mastery_level(4)==0 and medals.mastery_level(5)==1
        and medals.mastery_level(19)==1 and medals.mastery_level(20)==2
        and medals.mastery_level(49)==2 and medals.mastery_level(50)==3,
        "mastery thresholds are exactly 5, 20 and 50")
    check(medals.next_mastery_target(0)==5 and medals.next_mastery_target(5)==20
        and medals.next_mastery_target(20)==50,"clear next goal for each species")

    var counts := {"apprentice":50,"reinforced":20,"golden":1,"armored":1,
        "elite":1,"master4":1,"master5":1}
    check(Store.new(species_path).write_json({"version":1,"counts":counts,"seen":[]}),
        "existing journal fixture with older real progress")
    journal.configure(Store.new(species_path))
    check(wallet.update_record(5,75,8),"recorded historic best combo")
    var historical: Medals = Medals.new()
    check(historical.trophy_count(journal,wallet)==11,
        "11 of 12 medals unlock retroactively from old data")
    check(historical.unlocked(Medals.MEDALS[2],journal,wallet)==false,
        "100 solved cubes remains locked below 100")
    check(historical.mastery_label(journal.solved_count("apprentice"))=="✦ OURO"
        and historical.mastery_label(journal.solved_count("reinforced"))=="◆ PRATA",
        "existing counts immediately reveal matching mastery ranks")
    historical.snapshot(journal,wallet)
    check(historical.newly_unlocked(journal,wallet).is_empty(),
        "restart never spams already earned awards")
    counts["apprentice"] = 100
    check(Store.new(species_path).write_json({"version":1,"counts":counts,"seen":[]}),
        "100-solve milestone fixture saved")
    journal.configure(Store.new(species_path))
    found = historical.newly_unlocked(journal,wallet)
    check(found.size()==1 and String(found[0]["id"])=="hundred",
        "only the new hundred-cube medal announces")
    check(historical.trophy_count(journal,wallet)==12,"full collection possible")
    var after_restart := Medals.new()
    check(after_restart.trophy_count(journal,wallet)==12,
        "all medals remain unlocked without any new save schema")
    wallet.free()
    journal.free()
    _clean(money_path)
    _clean(species_path)
    print("KubRogue C14 retroactive medals and mastery: %d failures" % fails)
    quit(0 if fails==0 else 1)
