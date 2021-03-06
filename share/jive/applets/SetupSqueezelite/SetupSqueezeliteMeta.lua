--[[

Setup Squeezelite Meta - configuration support for Squeezelite player to set alsa params for Community Squeeze Instance

(c) 2013, Adrian Smith, triode1@btinternet.com

--]]

local oo         = require("loop.simple")
local AppletMeta = require("jive.AppletMeta")
local jiveMain   = jiveMain

local arg, ipairs, string = arg, ipairs, string

module(...)
oo.class(_M, AppletMeta)


function jiveVersion(meta)
	return 1, 1
end


function defaultSettings(meta)
	return { 
	}
end


function registerApplet(meta)
	-- only load on community squeeze control instance
	local load = false
	if string.match(arg[0], "jivelite%-cs") then
		load = true
	end
	for _, a in ipairs(arg) do
		if a == "--cs-applets" then
			load = true
		end
	end

	if load then
		jiveMain:addItem(
			meta:menuItem('appletSetupSqueezelite', 'settingsAudio', meta:string("APPLET_NAME"), 
						  function(applet, ...) applet:deviceMenu(...) end
			)
		)
	end
end
