local waywall = require("waywall")
local helpers = require("waywall.helpers")

os.execute("export LD_PRELOAD=/usr/lib/libjemalloc.so")
os.execute("export MALLOC_CONF='background_thread:true,narenas:2,dirty_decay_ms:15000,muzzy_decay_ms:15000'")

local read_file = function(name)
	local file = io.open("/home/flv/.config/waywall/" .. name, "r")
	local data = file:read("*a")
	file:close()

	return data
end

local config = {
	input = {
		remaps = {
			["7"] = "0",
			["V"] = "Backspace",
		},

		layout = "mc",
		variant = "basic",
		repeat_rate = 50,
		repeat_delay = 180,
		sensitivity = 0.0625,
		confine_pointer = false,
	},
	theme = {
		background = "#333333",
		ninb_anchor = "right",
		ninb_opacity = 0.8,

		cursor_icon = "",
		cursor_theme = "",
	},
	shaders = {
		["pie_chart"] = {
			vertex = read_file("pie_chart.vert"),
			fragment = read_file("pie_chart.frag"),
		},
	},

	experimental = {
		jit = true,
		tearing = false,
	},
}

-- State
local active_keymap = "mc"
local active_keymap_text = nil

local update_keymap_text = function()
	if active_keymap_text then
		active_keymap_text:close()
		active_keymap_text = nil
	end

	local state = waywall.state()
	if state.screen ~= "inworld" or state.inworld ~= "menu" then
		return
	end

	if active_keymap ~= "mc" then
		active_keymap_text = waywall.text("US layout active", 10, 960, "#ee4444", 5)
	end
end

waywall.listen("state", update_keymap_text)

-- Eye magnifier
helpers.res_mirror({
	src = { x = 130, y = 7902, w = 60, h = 580 },
	dst = { x = 0, y = 315, w = 800, h = 450 },
}, 320, 16384)
helpers.res_image("/home/flv/mcsr/overlay.png", {
	dst = { x = 0, y = 315, w = 800, h = 450 },
}, 320, 16384)

-- Tall pie
helpers.res_mirror({
	src = { x = 0, y = 15980, w = 320, h = 260 },
	dst = { x = 800, y = 586, w = 320, h = 260 },
}, 320, 16384)(
	-- F3 Client Chunk Cache
	[[helpers.res_mirror(
    {
        src = {x = 101,     y = 55,     w = 27,      h = 9},
        dst = {x = 880,     y = 484,    w = 108,     h = 36},
color_key  = {
            input  = "#dddddd",
            output = "#ee1111",
        },
    },
    320, 900
)]]
)

-- F3 Entity Count
helpers.res_mirror({
	src = { x = 0, y = 36, w = 49, h = 9 },
	dst = { x = 537, y = 162, w = 254, h = 47 },
	color_key = {
		input = "#dddddd",
		output = "#ffffff",
	},
}, 300, 1020)

-- Tall pie numbers
helpers.res_mirror({
	src = { x = 227, y = 16163, w = 84, h = 42 },
	dst = { x = 1120, y = 650, w = 504, h = 252 },
	shader = "pie_chart",
}, 320, 16384)

-- Thin pie numbers
helpers.res_mirror({
	src = { x = 1016, y = 828, w = 84, h = 42 },
	dst = { x = 1120, y = 650, w = 504, h = 252 },
	shader = "pie_chart",
}, 300, 1020)

local resolutions = {
	thin = helpers.ingame_only(helpers.toggle_res(300, 1020)),
	eye = helpers.toggle_res(320, 16384, 0.1),
	tall = helpers.toggle_res(320, 1638),
	wide = helpers.toggle_res(1920, 320),
}

-- Actions
local atum_reset = function()
	waywall.press_key("Backslash")
	waywall.set_resolution(0, 0)
end

local exec_ninb = function()
	waywall.exec("java -jar /home/flv/mcsr/Ninjabrain-Bot-1.5.1.jar")
end

local set_keymap = function(layout)
	return function()
		waywall.set_keymap({ layout = layout })

		active_keymap = layout
		update_keymap_text()
	end
end

config.actions = {
	-- Resolutions
	["*-Caps_Lock"] = resolutions.thin,
	["Ctrl-V"] = resolutions.eye,
	["*-Y"] = resolutions.wide,
	["*-U"] = resolutions.tall,

	-- Ninjabrain Bot
	["*-H"] = helpers.ingame_only(helpers.toggle_floating),
	["*-Alt-H"] = helpers.toggle_floating,
	["Ctrl-K"] = exec_ninb,

	-- Miscellaneous
	["*-J"] = atum_reset,
	["*-Ctrl-P"] = waywall.toggle_fullscreen,
	["Comma"] = set_keymap("mc"),
	["Period"] = set_keymap("us"),
}

return config
