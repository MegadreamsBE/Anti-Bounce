----------------- Anti-Bounce ----------------------
-- * The MIT License (MIT)
-- * Copyright (C) 2015 Aleksi "Arezu" Lindeman and Jordy "Megadreams" Sleeubus
-- * 
-- * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
-- * documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
-- * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
-- * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
-- * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---------------------------------------------------
---------------------------------------------------

-----------------------------------
-- * Variables
-----------------------------------

SettingsTemplate = setmetatable({},{__index = {}})

SettingsTemplate.TYPE_CATEGORY = 0
SettingsTemplate.TYPE_BOOL = 1
SettingsTemplate.TYPE_INTEGER = 2
SettingsTemplate.TYPE_STRING = 3
SettingsTemplate.TYPE_CUSTOM = 4

SettingsTemplate.g_aSettingsTemplate = 
{
	{
		["setting"] = "credits",
		["default"] = 1,
		["type"] = SettingsTemplate.TYPE_BOOL,
		["description"] = [[Do you want to show everyone who made the Anti-Bounce resource?
							0 = disabled, 1 = enabled, Default = 1]],
		["converter"] = 
		{
			["setting"] = "enablecredits"
		}
	},
	{
		["setting"] = "defaultstate",
		["default"] = 1,
		["type"] = SettingsTemplate.TYPE_BOOL,
		["description"] = [[What should the default state be for new players?
							0 = disabled, 1 = enabled, Default = 1]]
	},
	{
		["setting"] = "command",
		["default"] = "ab",
		["type"] = SettingsTemplate.TYPE_STRING,
		["description"] = [[You are able to specify what commands (separate each command with "," you want your players to be able to use to
							toggle the Anti-Bounce with.
							
							Value: String, 
							Default: ab		
							Attributes: enabled (Disables the use of commands when set to 0. Default: 1)]],
		["attributes"] = 
		{
			{
				["attribute"] = "enabled",
				["default"] = 1,
				["type"] = SettingsTemplate.TYPE_BOOL
			}
		}
	},
	{
		["setting"] = "bind",
		["default"] = "f10",
		["type"] = SettingsTemplate.TYPE_CUSTOM,
		["description"] = [[You are able to specify what key to set to bind the toggle feature of the Anti-Bounce can be used with.
		
							Value: String, 
							Default: f10		
							Attributes: enabled (Disables the use of a bind when set to 0. Default: 0)]],
		["custom"] = [[
			local lBinds = split(node:getValue(),',')
			
			for _,lBind in pairs(lBinds) do
				if SettingsTemplate.g_KeyTable[lBind:lower()] == nil and SettingsTemplate.g_KeyTable[lBind:upper()] == nil then
					Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce "..self.setting.."]: #ff0000The key '#ffffff"..lBind.."#ff0000' is not a valid key to bind. Please remove/modify it.",
						255,255,255,true)
					Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Please refer to the Anti-Bounce documentation.",255,255,255,true)
					
					return false
				end
			end
			
			return true
		]],
		["attributes"] = 
		{
			{
				["attribute"] = "enabled",
				["default"] = 0,
				["type"] = SettingsTemplate.TYPE_BOOL
			}
		}
	},
	{
		["setting"] = "messages",
		["type"] = SettingsTemplate.TYPE_CATEGORY,
		["settings"] = 
		{
			{
				["setting"] = "infomessage",
				["default"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff' or by simply pressing '#368DEB%2#ffffff'.",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is shown when both commands as binds are set. Use %1 where the commands have to be shown and %2 where 
									the bind has to be shown.
									 
									Value: String, 
									Default: #3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff' or by simply pressing '#368DEB%2#ffffff'.		 
									Attributes: enabled (Disables the message when set to 0. Default: 1)]],
				["attributes"] = 
				{
					{
						["attribute"] = "enabled",
						["default"] = 1,
						["type"] = SettingsTemplate.TYPE_BOOL
					}
				}
			},
			{
				["setting"] = "infomessage2",
				["default"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff'.",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is shown when either only the commands are enabled or a bind is set. Use %1 on the place they have to be shown.
		 
									Value: String, 
									Default: #3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff'.		 
									Attributes: enabled (Disables the message when set to 0. Default: 1)]],
				["attributes"] = 
				{
					{
						["attribute"] = "enabled",
						["default"] = 1,
						["type"] = SettingsTemplate.TYPE_BOOL
					}
				}
			},
			{
				["setting"] = "disabledmessage",
				["default"] = "#ff0000disabled",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is used in togglemessage and preferencemessage to show that the Anti-Bounce is disabled.
		
									Value: String, 
									Default: #ff0000disabled]],
			},
			{
				["setting"] = "enabledmessage",
				["default"] = "#00ff00enabled",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is used in togglemessage and preferencemessage to show that the Anti-Bounce is enabled.
		
									Value: String, 
									Default: #00ff00enabled]],
			},
			{
				["setting"] = "togglemessage",
				["default"] = "#3A85D6[Anti-Bounce]: #ffffffThe Anti-Bounce is now %1#ffffff.",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is shown whenever the Anti-Bounce is turned on/off. Use %1 wherever it should be replaced with either "disabled" or "enabled".
									Those are both also customizable under "disabledmessage" and "enabledmessage".
									 
									Value: String, 
									Default: #3A85D6[Anti-Bounce]: #ffffffThe Anti-Bounce is now %1#ffffff.		 
									Attributes: enabled (Disables the message when set to 0. Default: 1)]],
				["attributes"] = 
				{
					{
						["attribute"] = "enabled",
						["default"] = 1,
						["type"] = SettingsTemplate.TYPE_BOOL
					}
				}
			},
			{
				["setting"] = "preferencemessage",
				["default"] = "#3A85D6[Anti-Bounce]: #ffffffYour #368DEBpreferences #ffffffare #368DEBloaded #ffffff|| Anti-Bounce is %1#ffffff.",
				["type"] = SettingsTemplate.TYPE_STRING,
				["description"] = [[This message is shown when the player' preferences are loaded. Use %1 wherever the state should be replaced with either "disabled" or 
									"enabled". Those are both also customizable under "disabledmessage" and "enabledmessage".
									
									Value: String, 
									Default: #3A85D6[Anti-Bounce]: #ffffffYour #368DEBpreferences #ffffffare #368DEBloaded #ffffff|| Anti-Bounce is %1#ffffff.		
									Attributes: enabled (Disables the message when set to 0. Default: 1)]],
				["attributes"] = 
				{
					{
						["attribute"] = "enabled",
						["default"] = 1,
						["type"] = SettingsTemplate.TYPE_BOOL
					}
				}
			}
		}
	}
}

SettingsTemplate.g_KeyTable = 
{
	["mouse1"]= 0,
	["mouse2"]= 0,
	["mouse3"]= 0,
	["mouse4"]= 0,
	["mouse5"]= 0,
	["mouse_wheel_up"]= 0,
	["mouse_wheel_down"]= 0, 
	["arrow_l"]= 0,
	["arrow_u"]= 0,
	["arrow_r"]= 0,
	["arrow_d"]= 0,
	["0"]= 0,
	["1"]= 0,
	["2"]= 0,
	["3"]= 0,
	["4"]= 0,
	["5"]= 0,
	["6"]= 0,
	["7"]= 0,
	["8"]= 0, 
	["9"]= 0,
	["a"]= 0,
	["b"]= 0,
	["c"]= 0,
	["d"]= 0,
	["e"]= 0,
	["f"]= 0,
	["g"]= 0,
	["h"]= 0,
	["i"]= 0,
	["j"]= 0,
	["k"]= 0,
	["l"]= 0,
	["m"]= 0,
	["n"]= 0,
	["o"]= 0,
	["p"]= 0,
	["q"]= 0,
	["r"]= 0,
	["s"]= 0,
	["t"]= 0,
	["u"]= 0,
	["v"]= 0,
	["w"]= 0,
	["x"]= 0,
	["y"]= 0,
	["z"]= 0,
	["num_0"]= 0,
	["num_1"]= 0,
	["num_2"]= 0,
	["num_3"]= 0,
	["num_4"]= 0,
	["num_5"]= 0,
	["num_6"]= 0,
	["num_7"]= 0,
	["num_8"]= 0,
	["num_9"]= 0,
	["num_mul"]= 0,
	["num_add"]= 0,
	["num_sep"]= 0,
	["num_sub"]= 0,
	["num_div"]= 0,
	["num_dec"]= 0,
	["num_enter"]= 0,
	["F1"]= 0,
	["F2"]= 0,
	["F3"]= 0,
	["F4"]= 0,
	["F5"]= 0,
	["F6"]= 0,
	["F7"]= 0,
	["F8"]= 0,
	["F9"]= 0,
	["F10"]= 0,
	["F11"]= 0,
	["F12"]= 0,
	["escape"]= 0,
	["backspace"]= 0, 
	["tab"]= 0,
	["lalt"]= 0,
	["ralt"]= 0,
	["enter"]= 0,
	["space"]= 0,
	["pgup"]= 0,
	["pgdn"]= 0,
	["end"]= 0,
	["home"]= 0,
	["insert"]= 0,
	["delete"]= 0,
	["lshift"]= 0,
	["rshift"]= 0, 
	["lctrl"]= 0,
	["rctrl"]= 0,
	["["]= 0,
	["]"]= 0,
	["pause"]= 0,
	["capslock"]= 0,
	["scroll"]= 0,
	[";"]= 0,
	["]= 0,"]= 0,
	["-"]= 0,
	["."]= 0,
	["/"]= 0,
	["#"]= 0,
	["\\"]= 0,
	["="]=0 
}

-----------------------------------
-- * Functions
-----------------------------------

function SettingsTemplate.get()
	return SettingsTemplate.g_aSettingsTemplate
end