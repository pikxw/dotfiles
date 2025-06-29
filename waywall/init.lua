local waywall = require("waywall")
local helpers = require("waywall.helpers")

local config = {
    input = {
	remaps = {
	     ["7"] = "0",
	     ["V"] = "Backspace",
	     ["I"] = "V",
	     ["O"] = "I" 
	},
        layout = "mc",
	variant = "basic",
        repeat_rate = 20,
	repeat_delay = 180,
        sensitivity = 0.0625
    },
    theme = {
        background = "#333333",
	background_png = "/home/flv/.config/hypr/clouds.png", 	     
	--ninb_anchor = "right",
    },
    experimental = {
	       jit = true,
	tearing = false,
    }
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

waywall.listen("state", update_keymap_text)local make_image = function(path, dst)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.image(path, {dst = dst})
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local make_mirror = function(options)
    local this = nil 

    return function(enable)
        if enable and not this then
            this = waywall.mirror(options)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local make_res = function(width, height, enable, disable)
    return function()
        local active_width, active_height = waywall.active_res()

        if active_width == width and active_height == height then
            waywall.set_resolution(0, 0)
            disable()
        else
            waywall.set_resolution(width, height)
            enable()
        end
    end
end

local mirrors = {
    eye_measure = make_mirror({
        src = {x = 130,     y = 7902,   w = 60,     h = 580},
        dst = {x = 0,       y = 315,    w = 800,    h = 450},
    }),
    tall_pie = make_mirror({
        src = {x = 0,       y = 15980,  w = 320,    h = 260},
        dst = {x = 480,     y = 765,    w = 320,    h = 260},
    }),

    f3_ecount = make_mirror({
        src = {x = 0,       y = 36,     w = 49,     h = 9},
        dst = {x = 1120,    y = 540,    w = 196,    h = 36},
        color_key  = {
            input  = "#dddddd",
            output = "#ffffff",
        },
    }),

    tall_pie_entities = make_mirror({
        src = {x = 226,     y = 16164,  w = 84,     h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key  = {
            input  = "#e145c2",
            output = "#e145c2",
        },
    }),
    tall_pie_blockentities = make_mirror({
        src = {x = 226,     y = 16164,  w = 84,     h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key  = {
            input  = "#e96d4d",
            output = "#e96d4d",
        },
    }),
    tall_pie_unspec = make_mirror({
        src = {x = 226,     y = 16164,  w = 84,    h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key  = {
            input  = "#45cb65",
            output = "#45cb65",
        },
    }),


    thin_pie_entities = make_mirror({
        src = {x = 205,     y = 859,    w = 84,     h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key = {
            input  = "#e145c2",
            output = "#e145c2",
        },
    }),
    thin_pie_blockentities = make_mirror({
        src = {x = 205,     y = 859,    w = 84,     h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key = {
            input  = "#e96d4d",
            output = "#e96d4d",
        },
    }),
    thin_pie_unspec = make_mirror({
        src = {x = 205,     y = 859,    w = 84,     h = 42},
        dst = {x = 1120,    y = 650,    w = 504,    h = 252},
        color_key = {
            input  = "#45cb65",
            output = "#45cb65",
        },
    }),
}

local images = {
    overlay = make_image(
        "/home/flv/mcsr/overlay.png",
        {x = 0, y = 315, w = 800, h = 450}
    )
}

local show_mirrors = function(eye, f3, tall, thin, lowest)
    images.overlay(eye)
    mirrors.eye_measure(eye)
    mirrors.tall_pie(eye)

    mirrors.f3_ecount(f3)

    mirrors.tall_pie_entities(tall)
    mirrors.tall_pie_blockentities(tall)
    mirrors.tall_pie_unspec(tall)

    mirrors.thin_pie_entities(thin)
    mirrors.thin_pie_blockentities(thin)
    mirrors.thin_pie_unspec(thin)

end

local thin_enable = function()
    waywall.set_sensitivity(0)
    show_mirrors(false, true, false, true, false)
end

local thin_disable = function()
    show_mirrors(false, false, false, false, false)
end

local tall_enable = function()
    waywall.set_sensitivity(0.33)
    show_mirrors(true, true, true, false, false)
end

local tall_disable = function()
    waywall.set_sensitivity(0)
    show_mirrors(false, false, false, false, false)
end

local wide_enable = function()
    waywall.set_sensitivity(0)
    show_mirrors(false, false, false, false, false)
end

local wide_disable = function()
    -- nothing
end


local resolutions = {
    thin            = make_res(300, 1080, thin_enable, thin_disable),
    tall            = make_res(320, 16384, tall_enable, tall_disable),
    wide            = make_res(1920, 300, wide_enable, wide_disable),

}

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
    ["*-Caps_Lock"]              = resolutions.thin,
    ["*-J"]              = resolutions.tall,
    ["*-Y"]          = resolutions.wide,
    ["*-Alt-M"]          = resolutions.semithin,
    ["*-U"]          = resolutions.lowest,
    
    ["*-Ctrl-P"]         = waywall.toggle_fullscreen,
    ["*-Ctrl-H"]         = helpers.toggle_floating,
    ["*-Ctrl-K"]         = exec_ninb, 
    ["Comma"] = set_keymap("mc"),
    ["Period"] = set_keymap("us"),
}
return config
