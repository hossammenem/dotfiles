-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) })
		in_error = false
	end)
end
-- }}}

awful.spawn.with_shell("~/.config/awesome/autostartup.sh")

-- {{{ Variable definitions

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
}
-- }}}

-- {{{ Menu

-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end },
}

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local my_context_menu = awful.menu({
    items = {
        -- Category 1: Applications
        { "Rofi", function() awful.spawn("rofi -show drun") end },
		{ "──────────", function() end }, -- Acts as a separator


        -- Category 2: AwesomeWM Actions
        { "Restart", function() awesome.restart() end },
        { "Quit", function() awesome.quit() end },
		{ "──────────", function() end }, -- Acts as a separator
        -- Category 3: System Actions
        { "Reboot", function() awful.spawn("systemctl reboot") end },
        { "Sleep", function() awful.spawn("systemctl suspend") end },
        { "Shutdown", function() awful.spawn("systemctl poweroff") end },
    }
})

-- Create a custom menu
local custom_menu = wibox({
	width = 200, -- Wider width
	height = 250, -- Adjust height as needed
	bg = "#000000", -- Background color (Nord theme's dark blue)
	border_width = 1,
	border_color = "#333333", -- Border color
	ontop = true,
	visible = false,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 5)
	end,
})

-- Create a layout for the menu items
local menu_layout = wibox.layout.fixed.vertical()

-- Function to add a menu item
local function add_menu_item(label, action)
    local item = wibox.widget({
        {
            {
                align = "left",
                markup = '<span font="Jetbrains Mono Bold 9" color="#ededed">' .. label .. '</span>',
                widget = wibox.widget.textbox,
            },
            left = dpi(10),
            top = dpi(5),
            bottom = dpi(5),
            widget = wibox.container.margin,
        },
        bg = "#00000000", -- Transparent background by default

        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(5)) -- Rounded corners
        end,
        widget = wibox.container.background,
    })

    -- Add hover effect
    item:connect_signal("mouse::enter", function()
        item.bg = "#444444" -- Selected item background color
    end)
    item:connect_signal("mouse::leave", function()
        item.bg = "#00000000" -- Default item background color
    end)

    -- Add click action
    item:connect_signal("button::release", function(_, _, _, button)
        action()
        custom_menu.visible = false
    end)

    menu_layout:add(item)
end

-- Function to add a line separator
local function add_line_separator()
	local separator = wibox.widget({
		{
		widget = wibox.widget.separator,
		orientation = "horizontal",
		color = "#444444", -- Separator color
		-- thickness = 1, -- Line thickness
		forced_height = 1,
		},
		top = dpi(3), -- Add some spacing around the separator
		bottom = dpi(3),
		widget = wibox.container.margin,

		}
	)
    menu_layout:add(separator)
end

-- Wrap the entire menu layout in a margin container
local padded_menu_layout = wibox.widget({
	menu_layout,
	widget = wibox.container.margin,
	margins = dpi(5), -- Add padding around the entire menu
})



-- Add items to the menu
add_menu_item("Rofi", function() awful.spawn("rofi -show drun") end)
add_line_separator() -- Add a line separator
add_menu_item("Restart Awesome", function() awesome.restart() end)
add_menu_item("Quit Awesome", function() awesome.quit() end)
add_line_separator() -- Add a line separator
add_menu_item("Reboot", function() awful.spawn("systemctl reboot") end)
add_menu_item("Sleep", function() awful.spawn("systemctl suspend") end)
add_menu_item("Shutdown", function() awful.spawn("systemctl poweroff") end)

-- Add the padded layout to the menu
custom_menu:set_widget(padded_menu_layout)


local arch_logo = "/home/longassarchad/.config/awesome/arch-logo-bw.png"

-- Create an imagebox widget
local arch_logo_widget = wibox.widget {
	image = arch_logo,
	resize = true,
	widget = wibox.widget.imagebox,
	forced_width = 20,
	forced_height = 20,
	align="center",
}

local function calculate_menu_height()
    local item_height = dpi(22) -- Approximate height of each item
    local separator_height = dpi(7) -- Height of each separator + separator margins
    local padding_top_bottom = dpi(5) * 2 -- Padding on top and bottom

    local num_items = 0
    local num_separators = 0

    -- Count the number of items and separators
    for _, child in ipairs(menu_layout.children) do
        if child.widget == wibox.widget.separator then
            num_separators = num_separators + 1
        else
            num_items = num_items + 1
        end
    end

    -- Calculate total height
    local total_height = (num_items * item_height) + (num_separators * separator_height) + padding_top_bottom
    return total_height
end



-- Update the menu height when toggling
local function toggle_menu(follow_mouse)
    custom_menu.visible = not custom_menu.visible
    if custom_menu.visible then

		if follow_mouse then
        local mouse_coords = mouse.coords()

        -- Get the screen geometry
        local screen_geometry = awful.screen.focused().geometry

        -- Calculate the menu's potential position
        local menu_x = mouse_coords.x
        local menu_y = mouse_coords.y

        -- Adjust for the right edge of the screen
        if menu_x + custom_menu.width > screen_geometry.x + screen_geometry.width then
            menu_x = screen_geometry.x + screen_geometry.width - custom_menu.width
        end

        -- Adjust for the bottom edge of the screen
        if menu_y + custom_menu.height > screen_geometry.y + screen_geometry.height then
            menu_y = screen_geometry.y + screen_geometry.height - custom_menu.height
        end

        -- Position the menu
        custom_menu.x = menu_x
        custom_menu.y = menu_y

		else

			-- Position the menu below the Arch logo (or any widget)
			-- local geometry = arch_logo_widget:geometry() -- unable to get it working
			custom_menu.x = 10 -- geometry.x
			custom_menu.y = 30 -- geometry.y + geometry.height
		end

        -- Set the menu height dynamically
        custom_menu.height = calculate_menu_height()
    end
end
--arch_logo_widget:buttons(gears.table.join(
--    awful.button({}, 1, function()
--        my_context_menu:toggle() -- Toggle the context menu on left-click
--    end)
--))


-- Bind the menu to the Arch logo
arch_logo_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then -- Left click
        toggle_menu(false)
    end
end)



























mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, "./arch-logo-bw.png" }, { "open terminal", terminal } } })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })



-- {{{ Wibar


local font_settings = "Jetbrains Mono Bold 8" -- Adjust font size and boldness
local font_color = "#ededed" -- Font color
local alignment = "center" -- Text alignment

local mykeyboardlayout = awful.widget.keyboardlayout()
local keyboard_box = wibox.container.margin(mykeyboardlayout.widget)
keyboard_box:set_top(5)

local function update_keyboard_layout()
	local layout = mykeyboardlayout.widget.text    

  if awesome.xkb_get_layout_group() == 0 then
        mykeyboardlayout.widget:set_markup('<span font="Jetbrains Mono Bold 8" color="#ededed">en</span>')
   elseif awesome.xkb_get_layout_group() == 1 then
        mykeyboardlayout.widget:set_markup('<span font="Jetbrains Mono Bold 8" color="#ededed">ar</span>')
   end
end

-- Connect the function to the signal triggered when the layout changes
mykeyboardlayout:connect_signal("widget::redraw_needed", function()
    update_keyboard_layout()
end)

-- Initial update
update_keyboard_layout()

-- Customize Text Clock Widget
mytextclock = wibox.widget.textclock(
    "<span color='#ededed'>%a %d %b, %I:%M %p</span>", -- 12-hour format (e.g., 02:30 PM)
    60 -- Update every 60 seconds
)

-- Wrap the text clock widget to apply styling
mytextclock = wibox.widget {
    {
        widget = mytextclock,
        font = font_settings,
        align = alignment,
    },
    fg = font_color,
    widget = wibox.container.background
}

local calendar_widget = require("calendar")
-- ...
-- default
local cw = calendar_widget()
-- or customized
local cw = calendar_widget({
    theme = 'dark',
    placement = 'top_right',
    start_sunday = true,
    radius = 8,
-- with customized next/previous (see table above)
    previous_month_button = 1,
    next_month_button = 3,
})


mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

-- Create a wibox for each screen and add it



beautiful.font_var = "Jetbrains Mono"
beautiful.bg_3 = "#ededed"
beautiful.fg_color =  "#ededed"

local get_taglist = function(s)
	-- Taglist buttons
	local taglist_buttons = gears.table.join(
		awful.button({}, 1, function(t) t:view_only() end),
		awful.button({modkey}, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
		awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
		awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
		awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
	)

	-- Create the taglist widget
	local the_taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout = { layout = wibox.layout.fixed.horizontal },
		widget_template = {
			{
				{
					id = "text",
					widget = wibox.widget.textbox,
					font = beautiful.font .. " 12", -- Adjust font size as needed
					align = "center",
					valign = "center"
				},
				margins = 0,
				widget = wibox.container.margin
			},
			id = "background",
			widget = wibox.container.background,
			shape = function(cr, width, height)
				gears.shape.circle(cr, width, height)
			end,
			create_callback = function(self, tag, index, tags)
				if tag.selected then
					self:get_children_by_id("text")[1].text = "●" -- Filled circle for selected tag
				else
					self:get_children_by_id("text")[1].text = "○" -- Empty circle for unselected tags
				end
			end,
			update_callback = function(self, tag, index, tags)
				if tag.selected then
					self:get_children_by_id("text")[1].text = "●" -- Filled circle for selected tag
				else
					self:get_children_by_id("text")[1].text = "○" -- Empty circle for unselected tags
				end
			end
		}
	}



    return the_taglist
end

local get_tasklist = function(s)
	-- Tasklist buttons remain the same
	local tasklist_buttons = gears.table.join(
		awful.button({ }, 1, function (c)
			if c == client.focus then
				c.minimized = true
			else
				c:emit_signal("request::activate", "tasklist", {raise = true})
			end
		end),
		awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
		awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
		awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
	)

	local the_tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style = {
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, dpi(5))
			end
		},
		layout = {
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{  -- Extra container for margin around the whole task
				{  -- Task content container
					{   -- Icon and text container
							{ -- Icon
								id     = 'clienticon',
								widget = awful.widget.clienticon,
							},
						{   -- Text
							id     = 'text_role',
							widget = wibox.widget.textbox,
							forced_width = dpi(150),
							ellipsize = "end"
						},
						spacing = dpi(4),  -- Space between icon and text
						layout  = wibox.layout.fixed.horizontal
					},
					margins = dpi(4),  -- Inner margins
					widget  = wibox.container.margin
				},
				id     = 'background_role',
				widget = wibox.container.background,
			},
			top = dpi(4), bottom = dpi(4),  -- Outer margins - space between task and bar
			widget  = wibox.container.margin,

			create_callback = function(self, c, index, objects)
				self:get_children_by_id('clienticon')[1].client = c


				self:connect_signal('mouse::enter', function()
					if c.valid then
						awesome.emit_signal("bling::task_preview::visibility", s, true, c)
					end
				end)
				self:connect_signal('mouse::leave', function()
					awesome.emit_signal("bling::task_preview::visibility", s, false, c)
				end)
			end,

		}
	}
	return the_tasklist
end


-- First, let's create widgets for CPU, RAM, and Volume
local function create_system_widgets()
    -- CPU Widget
    local cpu_widget = wibox.widget {
        {
            id = "cpu_text",
            -- text = "CPU: N/A",
            widget = wibox.widget.textbox,
			font = beautiful.font_var .. " Bold 8", -- Adjust font size as needed
			markup = '<span color="#ededed">RAM: N/A</span>', -- Use markup for initial textt
			align = "center",
			valign = "center"
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }
    
    -- RAM Widget
    local ram_widget = wibox.widget {
        {
			id = "ram_text",
			widget = wibox.widget.textbox,
			font = beautiful.font_var .. " Bold 8", -- Adjust font size as needed
			markup = '<span color="#ededed">RAM: N/A</span>', -- Use markup for initial textt
			align = "center",
			valign = "center"
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }
    
    -- Volume Widget
    local volume_widget = wibox.widget {
        {
			id = "volume_text",
			--text = "Vol: N/A",
			widget = wibox.widget.textbox,
			font = beautiful.font_var .. " Bold 8", -- Adjust font size as needed
			markup = '<span color="#ededed">Vol: N/A</span>', -- Use markup for initial textt
			align = "center",
			valign = "center"

        },
        margins = dpi(4),
        widget = wibox.container.margin
    }

    -- Update CPU and RAM every 2 seconds
    gears.timer {
        timeout = 2,
        call_now = true,
        autostart = true,
        callback = function()
            -- CPU Usage
            awful.spawn.easy_async("bash -c \"top -bn1 | grep 'Cpu(s)' | awk '{print $2}'\"",
                function(stdout)
                    cpu_widget:get_children_by_id("cpu_text")[1].text = "CPU: " .. stdout:gsub("\n", "") .. "%"
                end
            )
            
            -- RAM Usage
            awful.spawn.easy_async("bash -c \"free -m | grep Mem | awk '{print $3/$2 * 100.0}'\"",
                function(stdout)
                    ram_widget:get_children_by_id("ram_text")[1].text = "RAM: " .. string.format("%.1f", stdout) .. "%"
				end
            )
        end
    }

    -- Update Volume
    awesome.connect_signal("signal::volume", function(volume, muted)
        volume_widget:get_children_by_id("volume_text")[1].text = "Vol: " .. volume .. "%"
    end)

    return cpu_widget, ram_widget, volume_widget
end




-- For the volume widget, here's a PulseAudio specific implementation:
local function create_volume_widget()
    local volume_widget = wibox.widget {
        {
            id = "volume_text",
            --text = "Vol: N/A",
            widget = wibox.widget.textbox,
			font = beautiful.font_var .. " Bold 8", -- Adjust font size as needed
			markup = '<span color="#ededed">Vol: N/A</span>', -- Use markup for initial textt
			align = "center",
			valign = "center"
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }

    -- Function to update volume
    local function update_volume()
        awful.spawn.easy_async_with_shell(
            "pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1",
            function(stdout)
                local volume = stdout:gsub("\n", "")
                -- Check if muted
                awful.spawn.easy_async_with_shell(
                    "pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo true || echo false",
                    function(muted)
                        if muted:match("true") then
                            volume_widget:get_children_by_id("volume_text")[1].text = "Vol: Muted"
                        else
                            volume_widget:get_children_by_id("volume_text")[1].text = "Vol: " .. volume .. "%"
                        end
                    end
                )
            end
        )
    end

    -- Update initial volume
    update_volume()

    -- Set up volume update timer
    gears.timer {
        timeout = 2,
        call_now = true,
        autostart = true,
        callback = update_volume
    }

    -- Optional: Add mouse bindings for volume control
    volume_widget:buttons(gears.table.join(
        awful.button({ }, 4, function() -- Scroll up
            awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%")
            update_volume()
        end),
        awful.button({ }, 5, function() -- Scroll down
            awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%")
            update_volume()
        end),
        awful.button({ }, 1, function() -- Left click to toggle mute
            awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            update_volume()
        end)
    ))

    -- Listen for volume changes
    awful.spawn.with_line_callback(
        [[ bash -c "pactl subscribe | grep --line-buffered 'sink'" ]],
        {
            stdout = function(line)
                update_volume()
            end
        }
    )

    return volume_widget
end



beautiful.wallpaper = "/home/longassarchad/Downloads/images/3.jpg"
local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end


beautiful.fg_normal  = "#ffffff"


-- Function to get default app icons
local function get_default_icon(app_name)
	-- Check common icon paths in descending size order
	local icon_sizes = {"256x256", "128x128", "96x96", "64x64", "48x48", "32x32"}
	local icon_extensions = {".png", ".svg"}

	-- Try hicolor icons first
	for _, size in ipairs(icon_sizes) do
		for _, ext in ipairs(icon_extensions) do
			local icon = "/usr/share/icons/hicolor/" .. size .. "/apps/" .. app_name .. ext
			if gears.filesystem.file_readable(icon) then
				return icon
			end
		end
	end

	-- Try .desktop file
	local desktop_file = "/usr/share/applications/" .. app_name .. ".desktop"
	if gears.filesystem.file_readable(desktop_file) then
		-- Extract Icon= line from .desktop file
		local icon_name = io.popen("grep '^Icon=' '" .. desktop_file .. "' | cut -d'=' -f2"):read("*l")
		if icon_name then
			-- Check if it's a full path
			if gears.filesystem.file_readable(icon_name) then
				return icon_name
			end
			-- Try hicolor again with the icon name
			for _, size in ipairs(icon_sizes) do
				for _, ext in ipairs(icon_extensions) do
					local icon = "/usr/share/icons/hicolor/" .. size .. "/apps/" .. icon_name .. ext
					if gears.filesystem.file_readable(icon) then
						return icon
					end
				end
			end
		end
	end

	-- Try /usr/share/pixmaps
	for _, ext in ipairs(icon_extensions) do
		local icon = "/usr/share/pixmaps/" .. app_name .. ext
		if gears.filesystem.file_readable(icon) then
			return icon
		end
	end

	-- Fallback to default icon
	return gears.filesystem.get_configuration_dir() .. "icons/default.png"
end


local function create_bottom_dock(s)
    -- Tasklist buttons (same as your topbar)
    local tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end),
        awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
        awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
        awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
    )

    -- Pinned apps (class, icon, exec)
    local pinned_apps = {
        {"zen-beta", "zen-browser", "zen"},
        {"discord", "discord", "discord"},
        {"obsidian", "obsidian", "~/Downloads/obsidian/Obsidian-1.6.7.AppImage"},
        --{"Alacritty", "Alacritty", "alacritty"},
        {"com.mitchellh.ghostty", "com.mitchellh.ghostty", "ghostty"}
    }

    -- Create the tasklist widget (updated for icons only and dot indicator)
    local tasklist = awful.widget.tasklist {
        screen = s,
        filter = function(c)
            -- Filter out pinned apps to avoid duplication

            for _, app in ipairs(pinned_apps) do
                if c.class == app[1] then
                    return false
                end
            end
            -- Include all other clients
            return awful.widget.tasklist.filter.currenttags(c, s)
        end,
		source = function()
			local clients = {}
			for _, c in ipairs(client.get()) do
				if awful.widget.tasklist.filter.currenttags(c, s) then
					table.insert(clients, 1, c) -- Insert at the beginning to reverse the order
				end
			end
			return clients
		end,
        buttons = tasklist_buttons,
        layout = { layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {  -- Main container
                {  -- Icon container
                    {
                        id     = 'clienticon',
                        widget = awful.widget.clienticon,
                        forced_width = dpi(48), -- Larger icon size
                        forced_height = dpi(48),
                    },
                    margins = dpi(5), -- Margin around the icon
                    widget  = wibox.container.margin
                },
                layout = wibox.layout.fixed.horizontal
            },
            widget = wibox.container.margin,

            create_callback = function(self, c, index, objects)
                self:get_children_by_id('clienticon')[1].client = c
                -- Fallback to default icon if clienticon fails
                if not self:get_children_by_id('clienticon')[1].image then
                    self:get_children_by_id('clienticon')[1].image = get_default_icon(c.class)
                end
            end,

            update_callback = function(self, c, _, __)
                local indicator = self:get_children_by_id('indicator')[1]
                if c.active then
                     self.bg = beautiful.bg_3 -- Active app dot color
                else
                     self.bg = beautiful.bg_3 -- Inactive app dot color
                 end
            end
        }
    }







-- Function to focus the first instance of an app
local function count_open_instances(app_class, screen)
    local count = 0
    for _, c in ipairs(client.get()) do
        if c.class == app_class and awful.widget.tasklist.filter.currenttags(c, screen) then
            count = count + 1
        end
    end
    return count
end

-- Function to focus the first instance of an app on the current tag
local function focus_first_instance(app_class, screen)
    for _, c in ipairs(client.get()) do
        if c.class == app_class and awful.widget.tasklist.filter.currenttags(c, screen) then
            c:emit_signal("request::activate", "tasklist", {raise = true})
            return true -- Found and focused an instance
        end
    end
    return false -- No instance found
end



    -- Create pinned apps with white dots
    local pinned_widgets = wibox.layout.fixed.horizontal()
    for _, app in ipairs(pinned_apps) do
        local app_icon = wibox.widget {
            image = get_default_icon(app[2]), -- Use the updated function
            widget = wibox.widget.imagebox,
            forced_width = dpi(48),
            forced_height = dpi(48),
            resize = true
        }

        -- Indicator dots container
        local indicator_dots = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(1) -- Spacing between dots
        }

        -- Function to update the indicator dots
        local function update_indicator(screen)
            indicator_dots:reset() -- Clear existing dots
            local count = count_open_instances(app[1], screen)

            local white_dot = wibox.widget {
                widget = wibox.widget.textbox,
                font = "Arial 6", -- Adjust the size of the dot by changing the font size
                text = "●"        -- Unicode character for a solid circle
            }

            -- Set the color of the dot to white
            white_dot.markup = "<span foreground='white'>" .. white_dot.text .. "</span>"

            for i = 1, count do
                indicator_dots:add(white_dot)
            end
        end

        -- Initial update of the indicator
    update_indicator(s)

    -- Update the indicator when apps are opened or closed
    client.connect_signal("manage", function(c)
        if c.class == app[1] then
            update_indicator(s)
        end
    end)

    client.connect_signal("unmanage", function(c)
        if c.class == app[1] then
            update_indicator(s)
        end
    end)

    -- Update the indicator when the tag changes
    tag.connect_signal("property::selected", function()
        update_indicator(s)
    end)


        -- Combine the icon and indicator dots
        local app_button = wibox.widget {
            {
                app_icon,
                {
                    indicator_dots,
                    halign = "center", -- Center horizontally
                    widget = wibox.container.place
                },
                layout = wibox.layout.fixed.vertical,
            },
            margins = dpi(5), -- Margin around the icon
            widget = wibox.container.margin
        }

		app_button:buttons(gears.table.join(
			awful.button({ }, 1, function()
				-- Try to focus an existing instance
				local focused = focus_first_instance(app[1], s)

				-- If no instance was found, spawn a new one
				if not focused then
					awful.spawn.with_shell("zsh -ic '" .. app[3] .."'")
				end

			end)
		))

        pinned_widgets:add(app_button)
    end

    -- Separator between pinned apps and other tasks
    local separator = wibox.widget {
        widget = wibox.widget.separator,
        orientation = "vertical",
        color = "#888888", -- Separator color
        forced_width = dpi(1),
        forced_height = dpi(48), -- Match the height of the icons
        visible = false, -- Initially hidden
    }

    -- Function to update the separator visibility
    local function update_separator(t)
				local selected = s.selected_tag and s.selected_tag or t
        local has_other_tasks = false
        for _, c in ipairs(selected:clients()) do
            local in_pinned = false
            for _, app in ipairs(pinned_apps) do
                if c.class == app[1] then
                    in_pinned = true
                    break
                end
            end
            if not in_pinned then
                has_other_tasks = true
                break
            end
        end
        separator.visible = has_other_tasks
    end

    local function get_dock_width(no_apps)
        -- 20 for left and right margin around all the apps, and 10 as 5 and 5 of the first and last app
        return dpi((48 * no_apps) + (10 * (no_apps - 1)) + 30 + ((separator.visible and 21 or 0)))
    end

    -- Create the dock wibox
    local dock = wibox {
        screen = s,
        width = get_dock_width(#pinned_apps), -- Initial width for 4 apps
        height = dpi(74), -- Reduced dock height
        bg = "#00000088", -- Semi-transparent black background
        border_width = dpi(1), -- Border width
        border_color = "#888888", -- Gray border color
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(20)) -- Adjust the radius here
        end,
        ontop = false, -- Keep the dock on top of other windows
        visible = true, -- Make the dock visible
    }

    -- Function to update the dock's width and position dynamically
    local function update_dock(t)
				local selected = s.selected_tag and s.selected_tag or t
        local total_apps = #pinned_apps

        for _, c in ipairs(selected:clients()) do
            local in_pinned = false
            for _, app in ipairs(pinned_apps) do
                if c.class == app[1] then
                    in_pinned = true
                    break
                end
            end
            if not in_pinned then
                total_apps = total_apps + 1
            end
        end

        -- Adjust width based on the number of apps and separator
        dock.width = get_dock_width(total_apps)
        dock.x = s.geometry.x + (s.geometry.width - dock.width) / 2 -- Center the dock
    end

    -- Update the dock's width and position when apps are opened or closed
    client.connect_signal("manage", function(c)
        update_separator()
        update_dock()
    end)

    client.connect_signal("unmanage", function()
        update_separator()
        update_dock()
    end)

    tag.connect_signal("property::selected", function(t)
        if t.screen == s then
						update_separator(t)
            update_dock(t)
        end
    end)

    -- Position the dock at the bottom center of the screen
    update_dock()
    dock.y = s.geometry.y + s.geometry.height - dock.height - dpi(5) -- Reduced margin from the bottom

    -- Add the pinned apps, separator, and tasklist to the dock
    dock:setup {
        {
            {
                pinned_widgets,
                {
                    separator,
                    margins = dpi(10), -- Margin around the icon
                    widget = wibox.container.margin
                },
                tasklist,
                layout = wibox.layout.fixed.horizontal,
            },
            left = dpi(10),
            right = dpi(10),
            top = dpi(5),
            bottom = dpi(5),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal,
        expand = "none"
    }

    return dock
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Add this somewhere in your rc.lua
awesome.connect_signal("signal::volume", function()
    awful.spawn.easy_async("pamixer --get-volume-human", function(stdout)
        local volume = stdout:match("(%d+)")
        local muted = stdout:match("muted")
        awesome.emit_signal("signal::volume", volume or 0, muted ~= nil)
    end)
end)

local task_widgets = {}
local task_switchers = {}

local highlighted
local alt_key = "Mod1"  -- The key name for the Alt key in AwesomeWM
local shift_pressed = false

local function highlight_task(direction)
	local next_idx

	-- Get clients and filter by current tag, while reversing the order
	local clients = client.get()
	local current_tag = awful.screen.focused().selected_tag
	local reversed_tag_clients = {}

	local tag_task_widgets = task_widgets[current_tag.index]

	for _, c in ipairs(clients) do
		if c.first_tag == current_tag then
			table.insert(reversed_tag_clients, 1, c)  -- Insert at the beginning to reverse the order
		end
	end

	if #reversed_tag_clients > 1 then
		-- Use the highlighted index if it exists, otherwise find the focused client
		local idx = highlighted or 1
		if not highlighted then
			for i, c in ipairs(reversed_tag_clients) do
				if c == client.focus then
					idx = i
					break
				end
			end
		end

		-- Calculate next_idx based on direction
		if direction == 1 then
			-- Cycle forward in the reversed order
			next_idx = idx % #reversed_tag_clients + 1
		else
			-- Cycle backward in the reversed order
			next_idx = (idx - 2 + #reversed_tag_clients) % #reversed_tag_clients + 1
		end
	else
		-- If there's only one client, it must be the focused one
		next_idx = 1
	end

	-- Update the highlighted index
	highlighted = next_idx

	-- debugging
	for i, task_widget in ipairs(tag_task_widgets) do
		-- naughty.notify({ title = "Task Widgets", text = "Index: " .. i .. ", Client: " .. (task_widget:get_children_by_id('text')[1].text or "Unknown") })
	end

	-- Highlight the task corresponding to next_idx
	for i, task_widget in ipairs(tag_task_widgets) do
		if i == next_idx then
			task_widget:get_children_by_id('background')[1].bg = "#00FF0044"  -- Green background for the highlighted client
		else
			task_widget:get_children_by_id('background')[1].bg = "#00000088"  -- Default background for other clients
		end
	end
end


local function hide_task_switcher()
    local screen = awful.screen.focused()
    task_switchers[screen].visible = false
end


local function init_task_switcher(s)
    local the_tasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        source = function()
            local clients = {}
            for _, c in ipairs(client.get()) do
                if awful.widget.tasklist.filter.currenttags(c, s) then
                    table.insert(clients, 1, c)  -- Insert at the beginning to reverse the order
                end
            end
            return clients
        end,
        style = {
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(10))
            end
        },
        layout = { layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {  -- Extra container for margin around the whole task
                {  -- Task content container
                    {   -- Icon and text container
                        nil,  -- Empty space above the icon
                        {  -- Centered icon and text
                            {  -- Centered icon container
                                {
                                    id     = 'icon',
                                    widget = awful.widget.clienticon,
                                    forced_width = dpi(96),
                                    forced_height = dpi(96),
                                },
                                widget = wibox.container.place,  -- Center the icon
                                halign = "center",
                                valign = "center"
                            },
                            {   -- Text
                                id     = 'text',
                                widget = wibox.widget.textbox,
                                font = beautiful.font_var .. " Bold 12",
                                forced_width = dpi(128),
                                ellipsize = "end",
                                markup = "DD",
                                align  = "center",
                                valign = "center"
                            },
                            spacing = dpi(10),  -- Space between icon and text
                            layout  = wibox.layout.fixed.vertical
                        },
                        nil,  -- Empty space below the text
                        layout = wibox.layout.align.vertical
                    },
                    margins = dpi(8),  -- Inner margins
                    widget  = wibox.container.margin
                },
				id     = 'background',
				widget = wibox.container.background,
				bg="#00000088",
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, dpi(10))  -- Rounded corners
                end,
            },
            widget  = wibox.container.margin,

			create_callback = function(self, c, index, objects)
				self:get_children_by_id('icon')[1].client = c
				self:get_children_by_id('text')[1].text = c.class or "Unknown"
				self:get_children_by_id('background')[1].bg = "#00000000"

				if not task_widgets[c.first_tag.index] then
					task_widgets[c.first_tag.index] = {}
				end
				task_widgets[c.first_tag.index][index] = self

                -- Add hover effects for task preview
                self:connect_signal('mouse::enter', function()
                    if c.valid then

						if highlighted then
							task_widgets[c.first_tag.index][highlighted]:get_children_by_id('background')[1].bg = "#00000000"  -- Green background for the highlighted client
						end
                        self:get_children_by_id('background')[1].bg = "#FFFFFF44"  -- Background color on hover

                        awesome.emit_signal("bling::task_preview::visibility", s, true, c)
                    end
                end)

    self:connect_signal('button::release', function(_, _, _, button)
        if c.valid then
            -- Focus the client
            client.focus = c
            c:raise()

            -- Hide the task switcher
            hide_task_switcher()
            keygrabber.stop()

            -- Reset the highlighted task
            highlighted = nil
        end
    end)

                self:connect_signal('mouse::leave', function()
					-- retain focus for what was about to be selected
                    if c.valid then

                        self:get_children_by_id('background')[1].bg = "#00000000"  -- Reset background on leave
						if highlighted then
												task_widgets[c.first_tag.index][highlighted]:get_children_by_id('background')[1].bg = "#00FF0044"  -- Green background for the highlighted client
						end

                        awesome.emit_signal("bling::task_preview::visibility", s, false, c)
                    end
                end)

            end,
        }
    }

    -- Create the task_switcher wibox
    local task_switcher = wibox {
        screen = s,
        ontop = true,
        visible = false,  -- Hidden by default
        bg = "#000000",
        fg = "#FFFFFF",
        shape = gears.shape.rounded_rect,
        shape_border_width = 1,
				widget=the_tasklist,
        shape_border_color = beautiful.border_normal or "#888888",
        height = dpi(150),
        width = dpi(700),
    }

    -- Position the task_switcher in the center of the screen
    awful.placement.centered(task_switcher, { parent = s })

    task_switcher:setup {
        {
            {
                the_tasklist,
                layout = wibox.layout.fixed.horizontal,
            },
            left = dpi(10),
            right = dpi(10),
            top = dpi(5),
            bottom = dpi(5),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal,
        expand = "none"
    }

    return task_switcher
end

-- Create a text widget to display the focused client's class
local focused_client_widget = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.font_var .. " Bold 10", -- Adjust font size as needed
	markup = '',
	align = "center",
	valign = "center"
}

-- Function to update the widget with the focused client's class
local function update_focused_client(c)
	if c and c.class then
		focused_client_widget.markup = '<span color="#ededed">' .. c.class .. '</span>' -- Blue text
	else
		focused_client_widget.markup = "" -- Red textd
	end
end

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4"}, s, awful.layout.layouts[1])
	local mytaglist = get_taglist(s)

	-- local mytasklist = get_tasklist(s)

	-- Create system widgets
	local cpu_widget, ram_widget = create_system_widgets()  -- Remove volume from here if it was included
	local volume_widget = create_volume_widget()

	-- Create the wibox with padding
	 s.mywibox = awful.wibar({
	 	position = "top",
		bg = "#0c0c0c",
	 	screen = s,
	 	height = dpi(30),  -- Adjust height to add vertical padding
	 })

	s.bottom_dock = create_bottom_dock(s)
	task_switchers[s] = init_task_switcher(s)

	-- Add widgets to the wibox
	 s.mywibox:setup {
	 	layout = wibox.layout.align.horizontal,
	 	{ -- Left section
	 		{
	 			{
					arch_logo_widget,
	 				layout = wibox.layout.fixed.horizontal,
	 				spacing = dpi(8),  -- Spacing between left widgets
	 				mytaglist,
					focused_client_widget
	 			},
	 			left   = dpi(8),
	 			right  = dpi(8),
				top    = dpi(4),    -- Add top padding
	 			bottom = dpi(4),    -- Add bottom padding
	 			widget = wibox.container.margin,
	 		},
	 		layout = wibox.layout.fixed.horizontal,
	 	},
	 	{ -- Middle section
	 		{
				-- mytasklist,
	 			left   = dpi(4),
	 			right  = dpi(4),
	 			widget = wibox.container.margin,
	 		},
	 		widget = wibox.container.constraint,
	 		strategy = "max",
	 		width = dpi(800),  -- Maximum width for tasklist
	 	},
	 	{ -- Right widgets
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),  -- Spacing between right widgets
				-- wibox.widget.systray(),
				mykeyboardlayout,
				volume_widget,
				ram_widget,
				cpu_widget,
				mytextclock,
			},
			left   = dpi(8),
	 		right  = dpi(8),
	 		widget = wibox.container.margin,
	 	},
	 }

end)

-- Function to set up tag selection signals
local function setup_update_focused_client()
	awful.screen.connect_for_each_screen(function(s)
		for _, tag in ipairs(s.tags) do
			tag:connect_signal("property::selected", function(t)
				update_focused_client(nil)
			end)
		end
	end)
end

-- Connect to the focus signal to update the widget
setup_update_focused_client()
client.connect_signal("focus", update_focused_client)


awful.screen.connect_for_each_screen(function(s)
	-- dock height + dock padding
	local bottom_padding = 74 + 5 

    -- Adjust workarea margins
    awful.screen.padding(s, {
        top = 0,    -- Additional top margin
        bottom = bottom_padding, -- Bottom margin
        left = 0,   -- Left margin
        right = 0   -- Right margin
    })
end)


-- }}}

-- {{{ Mouse bindings

root.buttons(gears.table.join(
	awful.button({ }, 3, function () toggle_menu(true) end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}




local aclient   = require("awful.client")
local resize    = require("awful.mouse.resize")
local aplace    = require("awful.placement")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local color     = require("gears.color")
local shape     = require("gears.shape")
local cairo     = require("lgi").cairo


awful.mouse.snap.edge_enabled = false

local module = {
    default_distance = 8
}

local capi = {
    root = root,
    mouse = mouse,
    screen = screen,
    client = client,
    mousegrabber = mousegrabber,
}

local bg_placeholder = nil
local border_placeholder = nil

local function show_placeholder(geo)
    if not geo then
        if bg_placeholder then
            bg_placeholder.visible = false
        end
        if border_placeholder then
            border_placeholder.visible = false
        end
        return
    end

    -- Background wibox
    bg_placeholder = bg_placeholder or wibox {
        ontop = true,
        bg = "#212121DD",
        border_width = 0,
    }
    
    -- Border wibox
    border_placeholder = border_placeholder or wibox {
        ontop = true,
        bg = "#444444",
        border_width = 2,
    }

    -- Set geometry for both wiboxes
    bg_placeholder:geometry(geo)
    border_placeholder:geometry(geo)

    -- Create shape for background
    local bg_img = cairo.ImageSurface(cairo.Format.ARGB32, geo.width, geo.height)
    local bg_cr = cairo.Context(bg_img)
    
    bg_cr:set_operator(cairo.Operator.CLEAR)
    bg_cr:paint()
    bg_cr:set_operator(cairo.Operator.OVER)
    
    bg_cr:translate(5, 5)
    shape.rounded_rect(bg_cr, geo.width-10, geo.height-10, 5)
    bg_cr:fill()
    
    bg_placeholder.shape_bounding = bg_img._native
    bg_img:finish()

    -- Create shape for border
    local border_img = cairo.ImageSurface(cairo.Format.ARGB32, geo.width, geo.height)
    local border_cr = cairo.Context(border_img)
    
    border_cr:set_operator(cairo.Operator.CLEAR)
    border_cr:paint()
    border_cr:set_operator(cairo.Operator.OVER)
    
    border_cr:translate(5, 5)
    border_cr:set_line_width(2)
    shape.rounded_rect(border_cr, geo.width-10, geo.height-10, 5)
    border_cr:stroke()
    
    border_placeholder.shape_bounding = border_img._native
    border_img:finish()

    -- Show both wiboxes
    bg_placeholder.visible = true
    border_placeholder.visible = true
end



local function build_placement(snap, axis)
	return aplace.scale + aplace[snap] + ( axis and aplace["maximize_"..axis] or nil)
end

local function detect_screen_edges(c, snap)
    local coords = capi.mouse.coords()

    local sg = c.screen.geometry

    local v, h = nil

    if math.abs(coords.x) <= snap + sg.x and coords.x >= sg.x then
        h = "left"
    elseif math.abs((sg.x + sg.width) - coords.x) <= snap then
        h = "right"
    end

    if math.abs(coords.y) <= snap + sg.y and coords.y >= sg.y then
        v = "top"
    --elseif math.abs((sg.y + sg.height) - coords.y) <= snap then
    --    v = "bottom"
    end

    return v, h
end

local current_snap, current_axis = nil

local function detect_areasnap(c, distance)
    local old_snap = current_snap
    local v, h = detect_screen_edges(c, distance)

    if v and h then
        current_snap = v.."_"..h
    else
        current_snap = v or h or nil
    end

    if old_snap == current_snap then return end

    current_axis = ((v and not h) and "horizontally")
        or ((h and not v) and "vertically")
        or nil

    -- Show the expected geometry outline
    show_placeholder(
        current_snap and build_placement(current_snap, current_axis)(c, {
            to_percent     = (current_axis == "vertically" and .5) or (current_axis == "horizontally" and 1),
            honor_workarea = true,
						honor_padding = true,
            pretend        = true
        }) or nil
    )

end

local function apply_areasnap(c, args)
    if not current_snap then return end

    -- Remove the move offset
    args.offset = {}

	bg_placeholder.visible = false
	border_placeholder.visible = false

	if current_axis == "horizontally" then
		c.maximized = true
		return setmetatable(module, {__call = function(_, ...) return module.snap(...) end})

	else
		return build_placement(current_snap, current_axis)(c,{
			to_percent     = .5,
			honor_workarea = true,
			honor_padding = true
		})
	end

end


-- Enable edge snapping
awful.mouse.resize.add_move_callback(function(c, geo, args)
    -- Screen edge snapping (areosnap)
    if args and (args.snap == nil or args.snap) then
        detect_areasnap(c, 16)
    end

    -- Snapping between clients
    if args and (args.snap == nil or args.snap) then
        return awful.mouse.snap(c, args.snap, geo.x, geo.y)
    end
end, "mouse.move")

-- Apply the aerosnap
awful.mouse.resize.add_leave_callback(function(c, _, args)
    return apply_areasnap(c, args)
end, "mouse.move")



local function on_alt_release()
	hide_task_switcher()

	-- Focus the highlighted client
	if highlighted then
		local clients = client.get()
		local current_tag = awful.screen.focused().selected_tag
		local clients_on_tag = {}

		-- Filter clients on the current tag
		for _, c in ipairs(clients) do
			if c.first_tag == current_tag then
				table.insert(clients_on_tag, 1, c)
			end
		end

		-- Check if the highlighted index is valid
		local c = clients_on_tag[highlighted]
		client.focus = c
		c:raise()
	end

	highlighted = nil  -- Reset the highlighted task
	shift_pressed = false 
	keygrabber.stop()  -- Stop listening for key events
end


local function start_keygrabber()
	keygrabber.run(function(mod, key, event)
		-- Print key events for debugging
		--naughty.notify({ title = "Key Event", text = "Mod: " .. tostring(mod) .. ", Key: " .. key .. ", Event: " .. event })

		-- Allow certain keys to pass through (e.g., Super, Ctrl, etc.)
		if mod["Mod4"] or mod["Control"] then
			return false  -- Let AwesomeWM handle these keys
		end

		-- Check if the Alt key is released (either by key name or modifier state)
		if (key == "Alt_L") and event == "release" then
			on_alt_release()
			return true  -- Stop the keygrabber
		end

		-- Stop the keygrabber and hide the task switcher if Escape is pressed
		if key == "Escape" then
			on_alt_release()
			return true  -- Stop the keygrabber
		end

		if key == "Shift_L" and event == "press" then
			shift_pressed = true

		elseif key == "Shift_L" and event == "release" then
			shift_pressed = false 
		end

			-- Handle task switching
			if key == "Tab" and event == "press" then
				-- Check if the Shift key is pressed
				if shift_pressed then
					highlight_task(-1)  -- Cycle backward
				else
					highlight_task(1)  -- Cycle forward
				end

				return true  -- Consume the Tab key
			end

			-- Ignore other keys
			return true
		end)
end


-- Call this function to show the task switcher and start listening for Alt key release
local function show_task_switcher()
    local screen = awful.screen.focused()
    local current_tag = screen.selected_tag

    -- Get clients on the current tag
    local clients = {}
    for _, c in ipairs(client.get()) do
        if c.first_tag == current_tag then
            table.insert(clients, c)
        end
    end

    -- Hide the task switcher if there are no clients
    if #clients == 0 then
        hide_task_switcher()
        return
    end

    -- Adjust the task switcher width based on the number of clients
    local task_switcher = task_switchers[screen]
    task_switcher.width = #clients * 150  -- Adjust the multiplier as needed
    awful.placement.centered(task_switcher, { parent = screen })

    -- Show the task switcher
    if not task_switcher.visible then
        task_switcher.visible = true
        start_keygrabber()  -- Start listening for Alt key release
    end
end

-- Reset highlight when switching tags
local function reset_highlight()
    highlighted = nil
    hide_task_switcher()
end

-- Connect the tag::property::selected signal
local function setup_tag_signals()
    for _, tag in ipairs(root.tags()) do
        tag:connect_signal("property::selected", function(t)
            if t.selected then
                reset_highlight()
            end
        end)
    end
end

-- Initialize tag signals
setup_tag_signals()





-- Function to cycle through clients
local function cycle_clients(direction)
    local clients = client.get()
    local focused = client.focus
    local current_tag = awful.screen.focused().selected_tag

    -- Filter clients to only those on the current tag
    local tag_clients = {}
    for _, c in ipairs(clients) do
        if c.first_tag == current_tag then
            table.insert(tag_clients, c)
        end
    end

    if #tag_clients > 1 then
        -- Find the index of the currently focused client
        local idx = 1
        for i, c in ipairs(tag_clients) do
            if c == focused then
                idx = i
                break
            end
        end

        -- Calculate the index of the next/previous client
        local next_idx
        if direction == 1 then
            next_idx = idx % #tag_clients + 1
        else
            next_idx = (idx - 2) % #tag_clients + 1
        end

        -- Focus the next/previous client
        local c = tag_clients[next_idx]
        c:emit_signal("request::activate", "key.unminimize", {raise = true})
        c:raise()
    end
end




-- {{{ Key bindings
globalkeys = gears.table.join(

	-- HELP & Session
	awful.key({ modkey }, "s",      hotkeys_popup.show_help, {description="show help", group="awesome"}),
	awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

	-- Screen cycling 
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, {description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end, {description = "focus the previous screen", group = "screen"}),

	-- cycle between tags
	awful.key({ modkey }, ",", function()
		local screen = awful.screen.focused()
		local current_index = screen.selected_tag.index
		local num_tags = #screen.tags
		-- Wrap around to the last tag if we're on the first tag
		local new_index = ((current_index - 2) % num_tags) + 1
		screen.tags[new_index]:view_only()
	end,
		{description = "view previous tag", group = "tag"}),

	awful.key({ modkey }, ".", function()
		local screen = awful.screen.focused()
		local current_index = screen.selected_tag.index
		local num_tags = #screen.tags
		-- This calculation is already correct for next tag
		local new_index = (current_index % num_tags) + 1
		screen.tags[new_index]:view_only()
	end,
		{description = "view next tag", group = "tag"}),



	awful.key({ modkey }, "Escape", awful.tag.history.restore, {description = "go back tag", group = "tag"}),

	-- Swift cross-tags movement
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end, {description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end, {description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1) end, {description = "focus next by index", group = "client"}),
	awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1) end, {description = "focus previous by index", group = "client"}),

	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),

	-- Cycle focus between clients in a tag
	--awful.key({ "Mod1" }, "Tab", function () cycle_clients(1) end, {description = "cycle forward through clients (including minimized)", group = "client"}),
	--awful.key({ "Mod1", "Shift" }, "Tab", function () cycle_clients(-1) end, {description = "cycle backward through clients (including minimized)", group = "client"}),
	
  -- Task switcher keybindings
	awful.key({ alt_key }, "Tab", function()
    show_task_switcher()
		highlight_task(1)
	end, {description = "cycle forward through tasks", group = "client"}),

	awful.key({ alt_key, "Shift" }, "Tab", function() 
    show_task_switcher()
		shift_pressed = true
		highlight_task(-1)
	end, {description = "cycle backward through clients (including minimized)", group = "client"}),


	-- Layout change
	awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end, {description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end, {description = "select previous", group = "layout"}),

	-- custom scripts & apps
	-- Rofi
	awful.key({ modkey }, "Return", function () awful.spawn("rofi -show drun") end, {description = "run rofi", group = "launcher"}),
	awful.key({ modkey, "Shift" }, "s", function () awful.spawn("flameshot gui") end, {description = "run flameshot", group = "launcher"}),


	-- idk, running custom scripts
	awful.key({ modkey }, "x", function ()
		awful.prompt.run {
			prompt       = "Run Lua code: ",
			textbox      = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval"
		}
	end, {description = "lua execute prompt", group = "awesome"}),


	-- IDK
	awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05) end, {description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05) end, {description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1, nil, true) end, {description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end, {description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end, {description = "decrease the number of columns", group = "layout"})
)

clientkeys = gears.table.join(
	-- quite useless since im only using floating and tiling, so the layout toggle button would do the same trick as this one
	-- awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, {description = "toggle floating", group = "client"}),

	awful.key({ modkey }, "w", function (c) c:kill() end, {description = "close", group = "client"}),
	awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end, {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),

	-- Maximize and Minimize
	awful.key({ modkey, "Control" }, "n",
		function ()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:emit_signal(
					"request::activate", "key.unminimize", {raise = true}
				)
			end
		end,
		{description = "restore minimized", group = "client"}),
	awful.key({ modkey }, "n", function (c) c.minimized = true end , {description = "minimize", group = "client"}),
	awful.key({ modkey, 				  }, "m", function (c) c.maximized = not c.maximized c:raise() end , {description = "toggle window maximized", group = "client"}),
	awful.key({ modkey, "Control" }, "m", function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end , {description = "(un)maximize vertically", group = "client"}),
	awful.key({ modkey, "Shift"   }, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end ,
		{description = "(un)maximize horizontally", group = "client"}),

	-- Tiling 
	-- Half screen
	awful.key({ modkey, "Shift" }, ",", function (c) 
		awful.placement.left(c) 
		awful.placement.maximize_vertically(c, { honor_padding = true, honor_workarea = true })
		c.width = c.screen.workarea.width / 2
	end, {description = "move to left half", group = "client"}),

	awful.key({ modkey, "Shift" }, ".", function (c) 
		awful.placement.right(c)
		awful.placement.maximize_vertically(c, { honor_padding = true, honor_workarea = true })
		c.width = c.screen.workarea.width / 2
	end, {description = "move to right half", group = "client"}),

	-- Quarter screen
	awful.key({ modkey, "Control" }, "1", function (c)
		awful.placement.top_left(c, {honor_workarea=true, honor_padding=true})
		c.width = c.screen.workarea.width / 2
		c.height = c.screen.workarea.height / 2
	end, {description = "move to top-left quarter", group = "client"}),

	awful.key({ modkey, "Control" }, "2", function (c)
		awful.placement.top_right(c, {honor_workarea=true, honor_padding=true})
		c.width = c.screen.workarea.width / 2
		c.height = c.screen.workarea.height / 2
	end, {description = "move to top-right quarter", group = "client"}),

	awful.key({ modkey, "Control" }, "3", function (c)
		awful.placement.bottom_left(c, {honor_workarea=true, honor_padding=true})
		c.width = c.screen.workarea.width / 2
		c.height = c.screen.workarea.height / 2
	end, {description = "move to bottom-left quarter", group = "client"}),

	awful.key({ modkey, "Control" }, "4", function (c)
		awful.placement.bottom_right(c, {honor_workarea=true, honor_padding=true})
		c.width = c.screen.workarea.width / 2
		c.height = c.screen.workarea.height / 2
	end, {description = "move to bottom-right quarter", group = "client"}),

	-- Center
	awful.key({ modkey, "Shift" }, "s", function (c)
		awful.placement.centered(c)
	end, {description = "move to bottom-right quarter", group = "client"}),

	-- Screen related stuff ig
	awful.key({ modkey }, "o", function (c) c:move_to_screen() end, {description = "move to screen", group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"})
)

-- Bind all key numbers to tags.
no_tags = 9
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{description = "view tag #"..i, group = "tag"}),
		-- Toggle tag display.
		--awful.key({ modkey, "Control" }, "#" .. i + 9,
		--	function ()
		--		local screen = awful.screen.focused()
		--		local tag = screen.tags[i]
		--		if tag then
		--			awful.tag.viewtoggle(tag)
		--		end
		--	end,
		--	{description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{description = "move focused client to tag #"..i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

-- mouse
clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
	awful.button({ modkey }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
	awful.button({ modkey }, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c, "bottom_right") end)
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).

awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
		properties = { border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			--placement = awful.placement.no_overlap+awful.placement.no_offscreen
			placement = awful.placement.no_offscreen
		}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
			"DTA",  -- Firefox addon DownThemAll.
			"copyq",  -- Includes session name in class.
			"pinentry",
		},
		class = {
			"Arandr",
			"Blueman-manager",
			"Gpick",
			"Kruler",
			"MessageWin",  -- kalarm.
			"Sxiv",
			"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
			"Wpa_gui",
			"veromix",
			"xtightvncviewer"},

		-- Note that the name property shown in xprop might be set slightly after creation of the client
		-- and the name shown there might not match defined rules here.
		name = {
			"Event Tester",  -- xev.
		},
		role = {
			"AlarmWindow",  -- Thunderbird's calendar.
			"ConfigManager",  -- Thunderbird's about:config.
			"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
		}
		}, properties = { floating = true }},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = {type = { "normal", "dialog" }
		}, properties = { titlebars_enabled = true }
	},
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
beautiful.border_normal = "#444444"
beautiful.border_focus = "#444444"

local edges = {} -- Global edges table

local cursor_mapping = {
	left = "sb_h_double_arrow",
	right = "sb_h_double_arrow",
	top = "sb_v_double_arrow",
	bottom = "sb_v_double_arrow",
	top_left = "top_left_corner",
	top_right = "top_right_corner",
	bottom_left = "bottom_left_corner",
	bottom_right = "bottom_right_corner"
}

-- Destroy resize overlays for a client
local function destroy_resize_overlays(client)
	if edges[client] then
		for _, edge in pairs(edges[client]) do
			edge.visible = false
			edge.ontop = false
		end
	end
end

-- Check if in tiling mode
local function is_tiling_active()
	local layout = awful.layout.get(awful.screen.focused())
	return layout == awful.layout.suit.tile or 
		layout == awful.layout.suit.tile.left or 
		layout == awful.layout.suit.tile.bottom or 
		layout == awful.layout.suit.tile.top or
		layout == awful.layout.suit.fair or
		layout == awful.layout.suit.fair.horizontal
end

-- Update visibility of resize overlays based on client state
local function update_overlay_visibility(focused_client)
	-- Hide all overlays except minimized ones, and make sure we are not in tilting mode as well
	-- as we only applying this to clients in the current tag ( desktop )
	for client, client_edges in pairs(edges) do
		if client.valid and (client:tags()[1] == focused_client:tags()[1]) 
			and not is_tiling_active() and not client.maximized then

			for _, edge in pairs(client_edges) do
				edge.visible = true
			end

		else
			destroy_resize_overlays(client)
		end
	end
	return
end

local function do_resize(client, edge, mouse)
	if not is_resizing or not start_coords then return end

	local delta_x = mouse.x - start_coords.x
	local delta_y = mouse.y - start_coords.y
	local geo = client:geometry()
	local new_geo = {
		x = geo.x,
		y = geo.y,
		width = geo.width,
		height = geo.height
	}

	-- Get the client's actual size hints
	local hints = client.size_hints
	local min_w = hints and hints.min_width or 350
	local min_h = hints and hints.min_height or 350
	local max_w = hints and hints.max_width or 1920
	local max_h = hints and hints.max_height or 1080

	-- Store original position before resize
	local original_x = geo.x
	local original_right = geo.x + geo.width

	-- Handle diagonal resizing
	if edge:match("top") or edge:match("bottom") then
		local y_direction = edge:match("top") and -1 or 1
		new_geo.height = geo.height + (delta_y * y_direction)
		if edge:match("top") then
			new_geo.y = geo.y + delta_y
		end
	end

	if edge:match("left") or edge:match("right") then
		local x_direction = edge:match("left") and -1 or 1
		new_geo.width = geo.width + (delta_x * x_direction)

		if edge:match("left") then
			new_geo.x = geo.x + delta_x
		end
	end

	-- Apply size constraints while preserving position
	if new_geo.width < min_w then
		new_geo.width = min_w
		if edge:match("left") then
			new_geo.x = original_right - min_w
		end
	elseif new_geo.width > max_w then
		new_geo.width = max_w
		if edge:match("left") then
			new_geo.x = original_right - max_w
		end
	end

	if new_geo.height < min_h then
		new_geo.height = min_h
		if edge:match("top") then
			new_geo.y = geo.y + geo.height - min_h
		end
	elseif new_geo.height > max_h then
		new_geo.height = max_h
		if edge:match("top") then
			new_geo.y = geo.y + geo.height - max_h
		end
	end

	client:geometry(new_geo)
	start_coords = mouse
end

local function update_overlays(client)
	if not client.valid or client.maximized then return end
	local geo = client:geometry()

	local margin_size = 10
	local corner_size = margin_size * 1.5

	if edges[client] then
		edges[client].left:geometry({
			x = geo.x - margin_size,
			y = geo.y + corner_size,
			width = margin_size,
			height = geo.height - (corner_size * 2)
		})

		edges[client].right:geometry({
			x = geo.x + geo.width,
			y = geo.y + corner_size,
			width = margin_size,
			height = geo.height - (corner_size * 2)
		})

		edges[client].top:geometry({
			x = geo.x + corner_size,
			y = geo.y - margin_size,
			width = geo.width - (corner_size * 2),
			height = margin_size
		})

		edges[client].bottom:geometry({
			x = geo.x + corner_size,
			y = geo.y + geo.height,
			width = geo.width - (corner_size * 2),
			height = margin_size
		})

		edges[client].top_left:geometry({
			x = geo.x - margin_size,
			y = geo.y - margin_size,
			width = corner_size,
			height = corner_size
		})

		edges[client].top_right:geometry({
			x = geo.x + geo.width,
			y = geo.y - margin_size,
			width = corner_size,
			height = corner_size
		})

		edges[client].bottom_left:geometry({
			x = geo.x - margin_size,
			y = geo.y + geo.height,
			width = corner_size,
			height = corner_size
		})

		edges[client].bottom_right:geometry({
			x = geo.x + geo.width,
			y = geo.y + geo.height,
			width = corner_size,
			height = corner_size
		})
	end
end

local function setup_resize_overlays(client)
	-- Destroy existing overlays if they exist
	destroy_resize_overlays(client)

	edges[client] = {
		left = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		right = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		top = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		bottom = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		top_left = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		top_right = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		bottom_left = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		}),
		bottom_right = wibox({
			visible = false,
			ontop = client.focused,
			bg = "#00000000",
			type = "utility",
		})
	}

	-- Set up mouse handlers for each edge
	for edge_name, edge_wibox in pairs(edges[client]) do
		edge_wibox:connect_signal("mouse::enter", function()
			root.cursor(cursor_mapping[edge_name])
		end)

		edge_wibox:connect_signal("mouse::leave", function()
			if not is_resizing then
				root.cursor("left_ptr")
			end
		end)

		edge_wibox:connect_signal("button::press", function(_, _, _, button)
			if button == 1 then
				if not client.focus then
					awful.client.focus.byidx(0, client)
				end
				is_resizing = true
				current_edge = edge_name
				start_coords = mouse.coords()

				mousegrabber.run(function(mouse)
					if not mouse.buttons[1] then
						is_resizing = false
						current_edge = nil
						root.cursor("left_ptr")
						return false
					end

					do_resize(client, current_edge, mouse)
					return true
				end, cursor_mapping[current_edge])
			end
		end)

		edge_wibox:connect_signal("mouse::move", function(w)
			w.cursor = cursor_mapping[edge_name]
		end)
	end

	update_overlays(client)
	update_overlay_visibility(client)
end

client.connect_signal("manage", function(c)
	if awesome.startup
		and not c.size_hints.user_position
		and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end

	c.border_width = 1
	c.shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, 5)
	end

	-- Update overlays when geometry changes
	c:connect_signal("property::geometry", function()
		update_overlays(c)
	end)

	-- Update the maximize signal handler
	c:connect_signal("property::maximized", function()
		if not edges[c] then
			setup_resize_overlays(c)
		end

		update_overlay_visibility(c)
	end)

	c:connect_signal("focus", function()
		update_overlay_visibility(c)
		if edges[c] then
			for _, edge in pairs(edges[c]) do
				edge.ontop = true
			end

		else
			setup_resize_overlays(c)

			for _, edge in pairs(edges[c]) do
				edge.ontop = true
			end
		end
	end)

	c:connect_signal("unfocus", function()
		destroy_resize_overlays(c)
	end)

	-- Handle screen focus
	-- Add this at the same level as your other signal handlers
	tag.connect_signal("property::selected", function(t)
		-- If switching to an empty tag
		if #t:clients() == 0 then
			-- Destroy all overlays
			for client, _ in pairs(edges) do
				destroy_resize_overlays(client)
			end
		else
			-- Get the focused client on the current tag
			local focused_client = awful.client.focus.history.get(t.screen, 0)
			if focused_client and focused_client:tags()[1] == t then
				update_overlay_visibility(focused_client)
			else
				-- If no focused client on this tag, destroy all overlays
				for client, _ in pairs(edges) do
					destroy_resize_overlays(client)
				end
			end
		end
	end)

	screen.connect_signal("focus", function(s)
		local current_tag = s.selected_tag
		if not current_tag or #current_tag:clients() == 0 then
			-- If current tag is empty or doesn't exist, destroy all overlays
			for client, _ in pairs(edges) do
				destroy_resize_overlays(client)
			end
		else
			local focused_client = awful.client.focus.history.get(s, 0)
			if focused_client and focused_client:tags()[1] == current_tag then
				update_overlay_visibility(focused_client)
			else
				-- If no focused client on this tag, destroy all overlays
				for client, _ in pairs(edges) do
					destroy_resize_overlays(client)
				end
			end
		end
	end)



	-- Handle layout changes
	awful.tag.attached_connect_signal(nil, "property::layout", function(t)
		for _, c in ipairs(t:clients()) do
			if is_tiling_active() then
				destroy_resize_overlays(c)
			else
				setup_resize_overlays(c)
			end
		end
	end)

	-- Clean up when the window is unmanaged
	c:connect_signal("unmanage", function()
		destroy_resize_overlays(c)

		local focused_client = awful.client.focus.history.get(awful.screen.focused(), 0)
		if focused_client then
			update_overlay_visibility(focused_client)
		end
	end)

	-- Set up overlays initially if appropriate
	if not c.maximized and not is_tiling_active() then
		setup_resize_overlays(c)
	end
end)


beautiful.titlebar_bg_normal = "#212121"
beautiful.titlebar_bg_focus = "#1E1E1E"

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Buttons for moving/resizing the window
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			if c.maximized then
				c.maximized = false
			end
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c, "bottom_right")
		end)
	)

	-- Create Mac-like buttons
	local function create_mac_button(color, hover_color)
		local button = wibox.widget.base.make_widget()

		button.bg = color
		button.hover_bg = hover_color
		button.cursor = "pointer"

		function button:fit(_, width, height)
			return 12, 12 -- Button size
		end

		function button:draw(_, cr, width, height)
			cr:set_source_rgb(gears.color.parse_color(self.bg))
			cr:arc(width / 2, height / 2, 6, 0, math.pi * 2)
			cr:fill()
		end

		-- Hover effect
		button:connect_signal("mouse::enter", function()
			button.bg = button.hover_bg
			button:emit_signal("widget::redraw_needed")
		end)

		button:connect_signal("mouse::leave", function()
			button.bg = color
			button:emit_signal("widget::redraw_needed")
		end)

		return button
	end

	local close_button = create_mac_button("#FF5F57", "#FF7B7B")
	local minimize_button = create_mac_button("#28C840", "#4AD861")
	local maximize_button = create_mac_button("#FEBC2E", "#FFCF4F")

	-- Button actions
	close_button:connect_signal("button::release", function()
		c:kill()
	end)

	maximize_button:connect_signal("button::release", function()
		c.maximized = not c.maximized
	end)

	minimize_button:connect_signal("button::release", function()
		c.minimized = true
	end)

	-- Configure titlebar
	awful.titlebar(c, { size = 30, bg_normal = beautiful.titlebar_bg_normal or "#2D2D2D" })
		:setup {
		{ -- Left
			{
				close_button,
				maximize_button,
				minimize_button,
				spacing = 8,
				layout = wibox.layout.fixed.horizontal,
			},
			left = 10,
			widget = wibox.container.margin,
		},
		{ -- Middle
			{
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			right = 10,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.horizontal,
	}
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
