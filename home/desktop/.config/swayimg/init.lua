---@diagnostic disable: undefined-global

-- =============================================================================
-- 1. GENERAL & VISUAL SETTINGS
-- =============================================================================
swayimg.mode = 'viewer'
swayimg.decoration = false
swayimg.antialiasing = true

swayimg.viewer.set_window_background(0xff000000)
swayimg.viewer.set_image_chessboard(10, 0xff222222, 0xff444444)
swayimg.viewer.default_scale = 'optimal'

swayimg.on_initialized(function()
    swayimg.text.visible = false
end)

-- =============================================================================
-- 2. FILE NAVIGATION
-- =============================================================================
swayimg.viewer.on_key('Space', function()
    swayimg.viewer.open 'next'
end)

swayimg.viewer.on_key('BackSpace', function()
    swayimg.viewer.open 'prev'
end)

-- =============================================================================
-- 3. VIM PANNING & ROTATION CONTROLS
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

swayimg.viewer.on_key('r', function()
    swayimg.viewer.rotate(90)
end)

swayimg.viewer.on_key('z', function()
    swayimg.viewer.set_fix_scale 'optimal'
    swayimg.viewer.set_fix_position 'center'
end)

swayimg.viewer.on_key('i', function()
    swayimg.text.visible = not swayimg.text.visible
end)

-- =============================================================================
-- 4. GALLERY MODE & NAVIGATION
-- =============================================================================
swayimg.viewer.on_key('g', function()
    swayimg.mode = 'gallery'
end)
swayimg.gallery.on_key('g', function()
    swayimg.mode = 'viewer'
end)
swayimg.gallery.on_key('Return', function()
    swayimg.mode = 'viewer'
end)
swayimg.gallery.on_key('Escape', function()
    swayimg.mode = 'viewer'
end)

swayimg.gallery.on_key('h', function()
    swayimg.gallery.select 'left'
end)
swayimg.gallery.on_key('l', function()
    swayimg.gallery.select 'right'
end)
swayimg.gallery.on_key('j', function()
    swayimg.gallery.select 'down'
end)
swayimg.gallery.on_key('k', function()
    swayimg.gallery.select 'up'
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
