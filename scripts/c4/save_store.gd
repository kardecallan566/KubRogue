extends RefCounted
class_name KubRogueSaveStore
## Disk adapter, independently testable with user:// path overrides.
## A temp file is flushed first; an existing valid save is retained as backup.
const MAX_BYTES := 65536
var path: String

func _init(save_path: String = "user://kubrogue_progress_v1.json") -> void:
    path = save_path

func _read_document(source: String) -> Dictionary:
    if not FileAccess.file_exists(source):
        return {}
    var file := FileAccess.open(source, FileAccess.READ)
    if file == null:
        return {}
    if file.get_length() <= 0 or file.get_length() > MAX_BYTES:
        file.close()
        return {}
    var content := file.get_as_text()
    file.close()
    var parser := JSON.new()
    if parser.parse(content) != OK or not (parser.data is Dictionary):
        return {}
    return parser.data

func read_json() -> Dictionary:
    # Prefer the last successful primary; recover from the previous backup
    # when a crash or disk problem left the primary invalid.
    for source in [path, path + ".bak"]:
        var payload: Dictionary = _read_document(source)
        if not payload.is_empty():
            return payload
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
    if FileAccess.file_exists(path) and not _read_document(path).is_empty():
        # Never replace a valid backup with a corrupt/truncated primary.
        # A recovered save must preserve the previous last-known-good file.
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
