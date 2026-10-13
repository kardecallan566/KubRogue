extends RefCounted
class_name KubRogueSaveStore
## Disk adapter, independently testable with user:// path overrides.
## A temp file is flushed first; an existing valid save is retained as backup.
const MAX_BYTES := 65536
var path: String

func _init(save_path: String = "user://kubrogue_progress_v1.json") -> void:
    path = save_path

func read_json() -> Dictionary:
    for source in [path, path + ".bak"]:
        if not FileAccess.file_exists(source):
            continue
        var f := FileAccess.open(source, FileAccess.READ)
        if f == null:
            continue
        if f.get_length() <= 0 or f.get_length() > MAX_BYTES:
            f.close()
            continue
        var raw := f.get_as_text()
        f.close()
        var parser := JSON.new()
        if parser.parse(raw) == OK and parser.data is Dictionary:
            return parser.data
    return {}

func write_json(payload: Dictionary) -> bool:
    var serialized := JSON.stringify(payload)
    if serialized.to_utf8_buffer().size() > MAX_BYTES:
        return false
    var temp := path + ".tmp"
    var f := FileAccess.open(temp, FileAccess.WRITE)
    if f == null:
        return false
    f.store_string(serialized)
    f.flush()
    f.close()
    if FileAccess.file_exists(path):
        # A last-known-good backup makes interrupted writes recoverable.
        if DirAccess.copy_absolute(ProjectSettings.globalize_path(path),
                ProjectSettings.globalize_path(path + ".bak")) != OK:
            DirAccess.remove_absolute(ProjectSettings.globalize_path(temp))
            return false
    var result := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path))
    if result != OK:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(temp))
        return false
    return true
