extends RefCounted
## UTC Gregorian Mondays are the deterministic identity of a weekly challenge.
## No locale, timezone, external services or platform-dependent random hash.
const EPOCH_MONDAY := "2025-01-06T00:00:00"

static func valid_day(value: String) -> bool:
    if value.length() != 10 or value.substr(4,1) != "-" or value.substr(7,1) != "-":
        return false
    var digits := value.replace("-","")
    if not digits.is_valid_int():
        return false
    var year := int(value.substr(0,4))
    var month := int(value.substr(5,2))
    var day := int(value.substr(8,2))
    if year < 2025 or year > 9999 or month < 1 or month > 12:
        return false
    var days := [31,28,31,30,31,30,31,31,30,31,30,31]
    var limit: int = days[month-1]
    if month == 2 and year%4 == 0 and (year%100 != 0 or year%400 == 0):
        limit = 29
    return day >= 1 and day <= limit

static func week_key(day: String) -> String:
    if not valid_day(day):
        return ""
    var start: int = int(Time.get_unix_time_from_datetime_string(EPOCH_MONDAY))
    var requested: int = int(Time.get_unix_time_from_datetime_string(day+"T00:00:00"))
    var monday: int = start + floori(float(requested-start)/604800.0)*604800
    var result: Dictionary = Time.get_datetime_dict_from_unix_time(monday)
    return "%04d-%02d-%02d" % [int(result["year"]),int(result["month"]),int(result["day"])]

static func weekly_seed(monday: String) -> int:
    if week_key(monday) != monday:
        return 0
    return (int(monday.replace("-",""))*137+1931)%2147483647
