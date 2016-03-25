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

-----------------------------------
-- * Variables
-----------------------------------

Converter = setmetatable({},{__index = {}})

-- Settings format from Anti-Bounce v2 for conversion.
Converter.g_aOldTemplate = 
{
	["enablecredits"] = {
		["value"] = true,
		["value_type"] = 0
	},
	["defaultstate"] = {
		["value"] = true,
		["value_type"] = 0
	},
	["infomessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff' or by simply pressing '#368DEB%2#ffffff'.",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["infomessage2"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff'.",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["togglemessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffThe Anti-Bounce is now %1#ffffff.",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["preferencemessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffYour #368DEBpreferences #ffffffare #368DEBloaded #ffffff|| Anti-Bounce is %1#ffffff.",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["disabledmessage"] = {
		["value"] = "#ff0000disabled",
		["value_type"] = 2
	},
	["enabledmessage"] = {
		["value"] = "#00ff00enabled",
		["value_type"] = 2
	},
	["bouncecommands"] = {
		["value"] = "ab",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["bouncebind"] = {
		["value"] = "f10",
		["value_type"] = 2,
		["disable"] = true,
		["disable_type"] = 0
	},
	["checkupdates"] = {
		["value"] = true,
		["value_type"] = 0,
	},
	["updatechecktimer"] = {
		["value"] = 1800000,
		["value_type"] = 1,
	},
	["enablestats"] = {
		["value"] = true,
		["value_type"] = 0,
	},
	["enablesettingstats"] = {
		["value"] = true,
		["value_type"] = 0,
	},
	["enableplayerstats"] = {
		["value"] = true,
		["value_type"] = 0,
	},
}

Converter.g_aConversionTable = {}

-----------------------------------
-- * Functions
-----------------------------------

function Converter.loadOldSettingsfile()
	local lConfigXML = XML.load("config.xml")
	if(lConfigXML == false) then
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000Unable to read the configuration file.",255,255,255,true)
		return
	end
	
	for _,lNode in pairs(lConfigXML:getChildren()) do
		local lNodeName = lNode:getName()
		
		if(Converter.g_aOldTemplate[lNodeName] ~= nil) then
			if(Converter.g_aOldTemplate[lNodeName]["value"] ~= nil) then
				local lValue = lNode:getValue()
				
				if(lValue ~= false and lValue ~= "") then
					if(Converter.g_aOldTemplate[lNodeName]["value_type"] == 0) then
						if(lValue == "true") then
							Converter.g_aConversionTable[lNodeName] = {["value"] = true,["attributes"] = {}}
						elseif(lValue == "false") then
							Converter.g_aConversionTable[lNodeName] = {["value"] = false,["attributes"] = {}}
						else
							Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
								.."boolean (true/false) as value. Please modify it.",255,255,255,true)
								
							lConfigXML:destroy()
							return false
						end
					elseif(Converter.g_aOldTemplate[lNodeName]["value_type"] == 1) then
						if(tonumber(lValue) ~= nil) then
							Converter.g_aConversionTable[lNodeName] = {["value"] = tonumber(lValue),["attributes"] = {}}
						else
							Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
								.."number as value. Please modify it.",255,255,255,true)
								
							lConfigXML:destroy()
							return false
						end
					elseif(Converter.g_aOldTemplate[lNodeName]["value_type"] == 2) then
						Converter.g_aConversionTable[lNodeName] = {["value"] = lValue,["attributes"] = {}}
					end
				else
					Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
						.."value. Please add it.",255,255,255,true)
						
					lConfigXML:destroy()
					return false
				end
			end
			
			for lName,lValue in pairs(lNode:getAttributes()) do
				if(Converter.g_aOldTemplate[lNodeName][lName] ~= nil) then
					if(lValue ~= false and lValue ~= "") then
						if(Converter.g_aOldTemplate[lNodeName][lName.."_type"] == 0) then
							if(lValue == "true") then
								Converter.g_aConversionTable[lNodeName]["attributes"][lName] = true
							elseif(lValue == "false") then
								Converter.g_aConversionTable[lNodeName]["attributes"][lName] = false
							else
								Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The attribute #ffffff"..lName.." #ff0000in Anti-Bounce v2 setting #ffffff"
									..tostring(lNodeName).." #ff0000expects a boolean (true/false) as value. Please modify it.",255,255,255,true)
									
								lConfigXML:destroy()
								return false
							end
						elseif(Converter.g_aOldTemplate[lNodeName][lName.."_type"] == 1) then
							if(tonumber(lValue) ~= nil) then
								Converter.g_aConversionTable[lNodeName]["attributes"][lName] = tonumber(lValue)
							else
								Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The attribute #ffffff"..lName.." #ff0000in Anti-Bounce v2 setting #ffffff"
									..tostring(lNodeName).." #ff0000expects a number as value. Please modify it.",255,255,255,true)
									
								lConfigXML:destroy()
								return false
							end
						elseif(Converter.g_aOldTemplate[lNodeName][lName.."_type"] == 2) then
							Converter.g_aConversionTable[lNodeName]["attributes"][lName] = lValue
						end
					else
						Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The attribute #ffffff"..lName.." #ff0000in Anti-Bounce v2 setting #ffffff"
							..tostring(lNodeName).." #ff0000expects a value. Please add it.",255,255,255,true)
							
						lConfigXML:destroy()
						return false
					end
				else
					Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffff"..tostring(lNodeName).." #ff0000doesnt have a attribute "
						.."#ffffff"..tostring(lName)..". #ff0000Please remove it.",255,255,255,true)
						
					lConfigXML:destroy()
					return false
				end
			end
		else
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffff"..tostring(lNodeName).." #ff0000in the configuration file "
			.."is not a supported setting.",255,255,255,true)
			
			lConfigXML:destroy()
			return false
		end
	end
	
	if(Converter.g_aConversionTable["bouncebind"]) then
		if(Converter.g_aConversionTable["bouncebind"]["attributes"]["disable"] == false) then
			if(SettingsTemplate.g_KeyTable[Converter.g_aConversionTable["bouncebind"]["value"]] == nil and
				SettingsTemplate.g_KeyTable[Converter.g_aConversionTable["bouncebind"]["value"]:upper()] == nil) then
				Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce converter]: #ff0000The Anti-Bounce v2 setting #ffffffbouncebind #ff0000has an invalid key to " 
					.."bind on. Please modify it.",255,255,255,true)
					
				lConfigXML:destroy()
				return false
			end
		end
	end
	
	lConfigXML:destroy()
	
	return true
end

function Converter.convert()
	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffA configuration file from Anti-Bounce v2 has been found.",255,255,255,true)
	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffAttempting to convert...",255,255,255,true)
	
	if File.exists(Settings.SETTINGS_FILE) then
		File.delete(Settings.SETTINGS_FILE)
	end
	
	if not Converter.loadOldSettingsfile() then
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to load the settings from Anti-Bounce v2.",255,255,255,true)
		return
	end
	
	local lSettingsFile = File.new(Settings.SETTINGS_FILE)

	if not lSettingsFile then
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to create a configuration file.",255,255,255,true)
		return
	end
	
	lSettingsFile:write("<settings>\n")
	Settings.writeSettingsBlock(lSettingsFile,SettingsTemplate.get(),1,true)
	lSettingsFile:write("\n</settings>")
	
	lSettingsFile:close()
	
	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffSuccesfully converted the configuration file to '"..Settings.SETTINGS_FILE.."'.",255,255,255,true)
	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffUse /abreload to reload this file after editing it.",255,255,255,true)
end