local mainMod = "SUPER"

hl.on("hyprland.start", function()
hl.exec_cmd("mako")
hl.exec_cmd("wl-paste --watch cliphist store")
end)

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu fuzzel"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'"))
hl.on("hyprland.start", function()
hl.exec_cmd("awww-daemon")
hl.exec_cmd("sleep 1 && awww restore")
end)
hl.bind(mainMod .. "+ F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle"}))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle"}))
require("colors")

hl.on("hyprland.start", function()
  hl.exec_cmd("qs")
end)

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu networkmanager_dmenu"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu /home/anand-r-m/.local/bin/volume-menu"))

hl.bind("Print", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/screenshot"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/screenshot region"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu /home/anand-r-m/.local/bin/power-menu"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu /home/anand-r-m/.local/bin/bt-menu"))

hl.on("hyprland.start", function()
  hl.exec_cmd("hypridle")
end)

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("kitty -o font_size=8.5 btop"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("kitty -o font_size=8.5 cava"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("kitty -o font_size=8.5 cava"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu /home/anand-r-m/.local/bin/wallpaper-pick"))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("/home/anand-r-m/.local/bin/toggle-menu /home/anand-r-m/.local/bin/cheatsheet"))

-- Monitors: external on the left, laptop on the right
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "auto" })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-left", scale = "auto" })

-- Monitors: external on the left, laptop on the right
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "auto" })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-left", scale = "auto" })

hl.config({
  general = {
    resize_on_border = true,
    extend_border_grab_area = 15,
  },
})

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.window_rule({ name = "brave-ws", match = { class = "^(brave-browser)$" }, workspace = "2" })

hl.workspace_rule({ workspace = "special:magic", on_created_empty = "kitty" })

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("makoctl mode -t do-not-disturb"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("pkill -x hyprsunset || hyprsunset -t 4500"))

hl.window_rule({ name = "code-ws", match = { class = "^([Cc]ode)$" }, workspace = "1" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("code"))
