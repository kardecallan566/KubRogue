extends SceneTree
const Workshop = preload("res://scripts/c8/workshop.gd")
const Progress = preload("res://scripts/c4/progress_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_test")
func check(ok: bool, note: String) -> void:
    if not ok:
        failures += 1
        push_error("C8 WORKSHOP FAIL: "+note)
func _clear(p: String) -> void:
    for suffix in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+suffix))
func _test() -> void:
    var path := "user://c8_workshop_test.json"
    _clear(path)
    var progress := Progress.new()
    get_root().add_child(progress)
    progress.configure(Store.new(path))
    var shop := Workshop.new()
    check(shop.available(0,0)==0,"shop begins empty")
    check(not shop.buy("tempo",progress,0),"cannot buy from previous-run money")
    check(progress.begin_run(),"save starts")
    check(progress.credit_cube(1,90),"first 90 coins persist")
    check(shop.available(90,progress.balance())==90,"run earning wallet budget")
    check(shop.buy("tempo",progress,90),"first time upgrade bought")
    check(progress.balance()==60 and shop.rank("tempo")==1 and shop.spent==30,
        "purchase debits exactly once")
    check(shop.next_wave_time()==10.0,"time upgrade has a real effect")
    check(shop.buy("tempo",progress,90),"second time rank costs 60 when affordable")
    check(shop.rank("tempo")==2 and shop.next_wave_time()==20.0,"second time rank takes effect")
    check(not shop.buy("escudo",progress,90),"not enough coins for healing")
    check(progress.balance()==0 and shop.rank("escudo")==0,"failed purchase does not charge")
    check(not shop.buy("lucro",progress,90),"can't buy expensive upgrades on low budget")
    check(shop.coin_bonus()==0.0,"no phantom bonus")
    check(shop.available(90,progress.balance())==0,"spent deducted from earned")
    var disk: Dictionary = Store.new(path).read_json()
    check(int(disk["coins"])==0,"coin debit durable")
    shop.begin_run()
    check(shop.rank("tempo")==0 and shop.spent==0,"upgrades reset for new run")
    check(shop.available(0,progress.balance())==0,
        "prior run's permanent balance is NOT spendable as current-run coins")
    progress.queue_free()
    await process_frame
    _clear(path)
    print("KubRogue C8 workshop unit: %d failures" % failures)
    quit(0 if failures==0 else 1)
