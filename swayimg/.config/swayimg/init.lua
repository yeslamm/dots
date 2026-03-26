---@diagnostic disable: undefined-global

-- =============================================================================
-- SWAYIMG v5.0+ LUA CONFIGURATION (~/.config/swayimg/init.lua)
-- =============================================================================

-- --- 1. GENERAL & VISUAL SETTINGS ---
swayimg.set_mode("viewer")
swayimg.enable_decoration(false)
swayimg.enable_antialiasing(true)

swayimg.viewer.set_window_background(0xff000000)
swayimg.viewer.set_image_chessboard(10, 0xff222222, 0xff444444)
swayimg.viewer.set_default_scale("optimal")

-- Hide info text on startup
swayimg.on_initialized(function()
	swayimg.text.hide()
end)

-- --- 2. FILE NAVIGATION (Explicitly mapped for stability) ---
swayimg.viewer.on_key("Space", function()
	swayimg.viewer.switch_image("next")
end)

swayimg.viewer.on_key("BackSpace", function()
	swayimg.viewer.switch_image("prev")
end)

-- --- 3. VIM KEYBINDINGS (PANNING) ---
local pan_speed = 50

swayimg.viewer.on_key("h", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x + pan_speed, pos.y)
end)

swayimg.viewer.on_key("l", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x - pan_speed, pos.y)
end)

swayimg.viewer.on_key("j", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x, pos.y - pan_speed)
end)

swayimg.viewer.on_key("k", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x, pos.y + pan_speed)
end)

-- --- 4. ZOOM & INFO TOGGLE ---
-- z: Reset to optimal fit and center
swayimg.viewer.on_key("z", function()
	swayimg.viewer.set_fix_scale("optimal")
	swayimg.viewer.set_fix_position("center")
end)

-- i: Toggle info text
swayimg.viewer.on_key("i", function()
	if swayimg.text.visible() then
		swayimg.text.hide()
	else
		swayimg.text.show()
	end
end)

-- --- 5. GALLERY & SYSTEM ---
swayimg.viewer.on_key("g", function()
	swayimg.set_mode("gallery")
end)
swayimg.gallery.on_key("Return", function()
	swayimg.set_mode("viewer")
end)

-- Gallery Vim Nav
swayimg.gallery.on_key("h", function()
	swayimg.gallery.switch_image("left")
end)
swayimg.gallery.on_key("l", function()
	swayimg.gallery.switch_image("right")
end)
swayimg.gallery.on_key("j", function()
	swayimg.gallery.switch_image("down")
end)
swayimg.gallery.on_key("k", function()
	swayimg.gallery.switch_image("up")
end)

-- Quit
swayimg.viewer.on_key("q", function()
	swayimg.exit()
end)
swayimg.gallery.on_key("q", function()
	swayimg.exit()
end)
