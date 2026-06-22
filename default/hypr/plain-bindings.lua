require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling-v2")
require("default.hypr.bindings.utilities")

-- Application bindings without Arch's preinstalled web apps, TUIs, or desktop apps.
o.bind("SUPER + RETURN", "Terminal", { archy = "terminal" })
o.bind("SUPER + SHIFT + RETURN", "Browser", { archy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { archy = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { archy = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { archy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { archy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { archy = "editor" })
