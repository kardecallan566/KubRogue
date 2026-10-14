extends SceneTree
const SpecialDirector = preload("res://scripts/c7/special_director.gd")
const SpecialWallet = preload("res://scripts/c7/special_wallet.gd")
const Visuals = preload("res://scripts/c7/special_visuals.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("C7 UNIT FAIL: " + why)

func _run() -> void:
    var director: SpecialDirector = SpecialDirector.new()
    check(director.waves.size() == 5, "original five waves intact")
    check(director.waves[0]["types"].size() == 5, "intro wave unchanged")
    var kinds: Dictionary = {}
    for i in range(5):
        var wave: Dictionary = director.waves[i]
        for kind in wave["types"]:
            kinds[String(kind)] = int(kinds.get(String(kind), 0)) + 1
    check(int(kinds.get("golden", 0)) == 4, "four gold targets across later waves")
    check(int(kinds.get("armored", 0)) == 3, "three armored targets across later waves")
    check(director.waves[4]["types"].size() == 9, "boss wave common slots preserved")
    check(SpecialDirector.BOSS_WAVE == 4 and not director.elite_spawned,
        "boss still scheduled in fifth wave")

    var wallet: SpecialWallet = SpecialWallet.new()
    var gold: Dictionary = wallet.award(99, "golden")
    check(gold.get("coins", 0) == 32 and gold.get("xp", 0) == 2, "gold unique payout")
    check(wallet.award(99, "golden").is_empty(), "gold double-credit prevented")
    var armor: Dictionary = wallet.award(100, "armored", 0.25)
    check(armor.get("coins", 0) == 37 and armor.get("xp", 0) == 3,
        "armored payout respects skill coin modifier")
    check(wallet.award(101, "apprentice")["coins"] == 10, "old rewards unchanged")
    check(wallet.solved == 3, "wallet counts actual solutions")
    check(director.scramble_depth("armored", 1) >= 8,
        "armor takes more turns than apprentice")
    check(director.scramble_depth("armored", 1, 2) >= 2,
        "look skill still reduces reinforced-like puzzles")
    check(director.scramble_depth("golden", 2) >= 3, "golden is still a real 2x2")
    check(Visuals.is_special("golden") and Visuals.is_special("armored"),
        "both special variants are visibly distinct")
    check(not Visuals.is_special("elite"), "boss untouched")
    print("KubRogue C7 special cubes unit: %d failures" % failures)
    quit(0 if failures == 0 else 1)
