---@diagnostic disable: undefined-global

-- =============================================================================
-- 1. GENERAL & VISUAL SETTINGS
-- =============================================================================
swayimg.set_mode 'viewer'
swayimg.enable_decoration(false)
swayimg.enable_antialiasing(true)

swayimg.viewer.set_window_background(0xff000000)
swayimg.viewer.set_image_chessboard(10, 0xff222222, 0xff444444)
swayimg.viewer.set_default_scale 'optimal'

swayimg.on_initialized(function()
    swayimg.text.hide()
end)

-- =============================================================================
-- 2. FILE NAVIGATION
-- =============================================================================
swayimg.viewer.on_key('Space', function()
    swayimg.viewer.switch_image 'next'
end)

swayimg.viewer.on_key('BackSpace', function()
    swayimg.viewer.switch_image 'prev'
end)

-- =============================================================================
-- 3. VIM PANNING & VIEWER CONTROLS
-- =============================================================================
local pan_speed = 50

swayimg.viewer.on_key('h', function()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x + pan_speed, pos.y)
end)

swayimg.viewer.on_key('l', function()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x - pan_speed, pos.y)
end)

swayimg.viewer.on_key('j', function()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, pos.y - pan_speed)
end)

swayimg.viewer.on_key('k', function()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, pos.y + pan_speed)
end)

-- Reset scale & position (z)
swayimg.viewer.on_key('z', function()
    swayimg.viewer.set_fix_scale 'optimal'
    swayimg.viewer.set_fix_position 'center'
end)

-- Toggle text info layer (i)
swayimg.viewer.on_key('i', function()
    if swayimg.text.visible() then
        swayimg.text.hide()
    else
        swayimg.text.show()
    end
end)

-- =============================================================================
-- 4. GALLERY MODE & NAVIGATION
-- =============================================================================
swayimg.viewer.on_key('g', function()
    swayimg.set_mode 'gallery'
end)
swayimg.gallery.on_key('g', function()
    swayimg.set_mode 'viewer'
end)
swayimg.gallery.on_key('Return', function()
    swayimg.set_mode 'viewer'
end)
swayimg.gallery.on_key('Escape', function()
    swayimg.set_mode 'viewer'
end)

swayimg.gallery.on_key('h', function()
    swayimg.gallery.switch_image 'left'
end)
swayimg.gallery.on_key('l', function()
    swayimg.gallery.switch_image 'right'
end)
swayimg.gallery.on_key('j', function()
    swayimg.gallery.switch_image 'down'
end)
swayimg.gallery.on_key('k', function()
    swayimg.gallery.switch_image 'up'
end)

-- =============================================================================
-- 5. EXIT
-- =============================================================================
swayimg.viewer.on_key('q', function()
    swayimg.exit()
end)
swayimg.gallery.on_key('q', function()
    swayimg.exit()
end)
