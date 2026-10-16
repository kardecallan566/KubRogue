extends "res://scripts/c12/history_service.gd"
## Extend the original v1 local result schema with an optional weekly mode.
## Existing normal/daily histories do not need migration.
const Calendar = preload("res://scripts/c15/weekly_calendar.gd")

func _normalize(entry: Dictionary) -> Dictionary:
    if String(entry.get("mode","normal")) != "weekly":
        return super._normalize(entry)
    var monday := String(entry.get("date",""))
    if Calendar.week_key(monday) != monday:
        return {}
    var normal: Dictionary = entry.duplicate(true)
    normal["mode"] = "normal"
    var result: Dictionary = super._normalize(normal)
    if result.is_empty():
        return {}
    result["mode"] = "weekly"
    result["date"] = monday
    return result
