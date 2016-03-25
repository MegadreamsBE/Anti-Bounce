----------------- Anti-Bounce ----------------------
-- * The MIT License (MIT)
-- * 
-- * Copyright (c) 2016 Aleksi "Arezu" Lindeman and Jordy "Megadreams" Sleeubus
-- * 
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- * 
-- * The above copyright notice and this permission notice shall be included in all
-- * copies or substantial portions of the Software.
-- * 
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- * SOFTWARE.
---------------------------------------------------

-----------------------------------
-- * Variables
-----------------------------------

Settings = setmetatable({},{__index = {}})

Settings.SETTINGS_FILE = "settings.xml"
Settings.g_aSettings = {}

-----------------------------------
-- * Functions
-----------------------------------

function Settings.load()
	if not File.exists(Settings.SETTINGS_FILE) then
		if File.exists("config.xml") then
			Converter.convert()
		else
			Settings.create()
		end
	else
		Settings.loadConfig()
	end
end

function Settings.writeSettingsBlock(lSettingsFile,lSettingsTable,lTab,lConvert)
	local lTabs = ""
	
	for i=1,lTab do
		lTabs = lTabs.."\t"
	end
	
	for lIndex,lData in pairs(lSettingsTable) do
		if lData["type"] == SettingsTemplate.TYPE_CATEGORY then
			lSettingsFile:write(lTabs.."<"..lData["setting"]..">\n")
			Settings.writeSettingsBlock(lSettingsFile,lData["settings"],(lTab + 1),lConvert)
			lSettingsFile:write("\n"..lTabs.."</"..lData["setting"]..">")
		else
			if lData["description"] then
				lSettingsFile:write(lTabs.."<!--\n"..lTabs.."\t"..lData["description"]:gsub("\t",""):gsub("\n","\n\t"..lTabs).."\n"..lTabs.."-->\n")
			end
			
			lSettingsFile:write(lTabs.."<"..lData["setting"])
			
			if lData["attributes"] then
				for _,lAttributeData in pairs(lData["attributes"]) do
					lSettingsFile:write(" "..lAttributeData["attribute"].."=\""..lAttributeData["default"].."\"")
				end
			end
			
			lSettingsFile:write(">"..(lData["default"] or 0).."</"..lData["setting"]..">")
			
			if(lIndex < #lSettingsTable) then
				lSettingsFile:write("\n\n")
			end
		end
	end
end

function Settings.validateSetting(lSetting,lTemplateNode,lbIsAttribute)
	if lTemplateNode.type == SettingsTemplate.TYPE_BOOL then
		local lValue = tonumber(tostring(lSetting:getValue():gsub("true","1"):gsub("false","0")))
		
		if lValue ~= 0 and lValue ~= 1 then
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce"..((lbIsAttribute) and (" "..lSetting:getParent():getName()) or ("")).."]: #ff0000'#ffffff"..
				lSetting:getName().."#ff0000' expects a boolean but has '#ffffff"..lSetting:getValue().."#ff0000'.",255,255,255,true)
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Please refer to the Anti-Bounce documentation.",255,255,255,true)
			
			return false
		end
	elseif lTemplateNode.type == SettingsTemplate.TYPE_INTEGER then
		if tonumber(lValue) == nil then
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce"..((lbIsAttribute) and (" "..lSetting:getParent():getName()) or ("")).."]: #ff0000'#ffffff"..
				lSetting:getName().."#ff0000' expects an integer but has '#ffffff"..lSetting:getValue().."#ff0000'.",255,255,255,true)
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Please refer to the Anti-Bounce documentation.",255,255,255,true)
			
			return false
		end
	elseif lTemplateNode.type == SettingsTemplate.TYPE_CUSTOM then
		self = lTemplateNode
		node = lSetting
		local lbSuccess = assert(loadstring(lTemplateNode.custom))()
		self = nil
		node = nil
		
		return lbSuccess
	end
	-- String is always valid, it does not require a check.
	
	return true
end

function Settings.loadSettingsBlock(lSettingsNodeTable,lTemplateNodes,lSettingsTable)
	for _,lNode in ipairs(lSettingsNodeTable:getChildren()) do
		local lTemplateNode = false
	
		for _,lTemplateTbl in pairs(lTemplateNodes) do
			if lTemplateTbl.setting == lNode:getName() then
				lTemplateNode = lTemplateTbl
				break
			end
		end
		
		if lTemplateNode == false then
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000'#ffffff"..lNode:getName().."#ff0000' is not a valid setting in this category.",255,255,255,true)
			Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Please refer to the Anti-Bounce documentation.",255,255,255,true)
			return false
		end
		
		if lSettingsTable[lTemplateNode.setting] == nil then
			lSettingsTable[lTemplateNode.setting] = {}
		end
		
		if lTemplateNode.type ~= SettingsTemplate.TYPE_CATEGORY then
			if Settings.validateSetting(lNode,lTemplateNode,false) == false then
				return false
			end
			
			local lValue = lNode:getValue()
			
			if lTemplateNode.type == SettingsTemplate.TYPE_BOOL then
				lValue = tonumber(tostring(lNode:getValue():gsub("true","1"):gsub("false","0")))
			elseif lTemplateNode.type == SettingsTemplate.TYPE_INTEGER then
				lValue = tonumber(lValue)
			end
			
			lSettingsTable[lTemplateNode.setting].value = lValue

			if lTemplateNode.attributes then
				if lSettingsTable[lTemplateNode.setting].attributes == nil then
					lSettingsTable[lTemplateNode.setting].attributes = {}
				end
				
				for lAttributeName,lAttributeValue in pairs(lNode:getAttributes()) do
					local lAttributeNode = false
		
					for _,lAttributeTbl in pairs(lTemplateNode.attributes) do
						if lAttributeTbl.attribute == lAttributeName then
							lAttributeNode = lAttributeTbl
							break
						end
					end
					
					if lAttributeNode == false then
						Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce "..lNode:getName().."]: #ff0000'#ffffff"..lAttributeName.."#ff0000' is not a valid attribute.",255,255,255,true)
						Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Please refer to the Anti-Bounce documentation.",255,255,255,true)
						return false
					end
			
					if lSettingsTable[lTemplateNode.setting].attributes[lAttributeName] == nil then
						lSettingsTable[lTemplateNode.setting].attributes[lAttributeName] = {}
					end
			
					local lAttributeCheck = setmetatable({},{__index = {}})
					
					lAttributeCheck.getValue =
					function()
						return lAttributeValue
					end
					
					lAttributeCheck.getName =
					function()
						return lAttributeName
					end
					
					lAttributeCheck.getParent =
					function()
						return lNode
					end
					
					if Settings.validateSetting(lAttributeCheck,lAttributeNode,true) == false then
						return false
					end
					
					local lValue = lAttributeValue
					
					if lAttributeNode.type == SettingsTemplate.TYPE_BOOL then
						lValue = tonumber(tostring(lAttributeValue:gsub("true","1"):gsub("false","0")))
					elseif lAttributeNode.type == SettingsTemplate.TYPE_INTEGER then
						lValue = tonumber(lValue)
					end
					
					lSettingsTable[lTemplateNode.setting].attributes[lAttributeName].value = lValue
				end
			end
		else
			lSettingsTable[lTemplateNode.setting].settings = {}
			Settings.loadSettingsBlock(lNode,lTemplateNode.settings,lSettingsTable[lTemplateNode.setting].settings)
		end
	end
	
	return true
end

function Settings.create()
	if File.exists(Settings.SETTINGS_FILE) then
		File.delete(Settings.SETTINGS_FILE)
	end
	
	local lSettingsFile = File.new(Settings.SETTINGS_FILE)

	if not lSettingsFile then
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to create a configuration file.",255,255,255,true)
		return
	end
	
	lSettingsFile:write("<settings>\n")
	Settings.writeSettingsBlock(lSettingsFile,SettingsTemplate.get(),1,false)
	lSettingsFile:write("\n</settings>")
	
	lSettingsFile:close()

	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffCreated a new configuration file '"..Settings.SETTINGS_FILE.."'.",255,255,255,true)
	Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffUse /abreload to reload this file after editing it.",255,255,255,true)
end

function Settings.prepareDefaultSettings(lSettingsTable,lSettingsTemplate)
	for _,lTemplateNode in pairs(lSettingsTemplate) do
		if lSettingsTable[lTemplateNode.setting] == nil then
			lSettingsTable[lTemplateNode.setting] = {}
			
			if lTemplateNode.type ~= SettingsTemplate.TYPE_CATEGORY then
				lSettingsTable[lTemplateNode.setting].value = lTemplateNode.default
				lSettingsTable[lTemplateNode.setting].attributes = {}
				
				if lTemplateNode.attributes ~= nil then
					for _,lAttributeTable in pairs(lTemplateNode.attributes) do
						if lAttributeTable.attribute ~= nil then -- Prevents a strange Lua bug
							if lTemplateNode.attributes[lAttributeTable.attribute] == nil then
								lTemplateNode.attributes[lAttributeTable.attribute] = {}
							end
							
							lTemplateNode.attributes[lAttributeTable.attribute].value = lAttributeTable.default
						end
					end
				end
			else
				Settings.prepareDefaultSettings(lSettingsTable[lTemplateNode.setting],lTemplateNode.settings)
			end
		end
	end
end

function Settings.loadConfig()
	if not File.exists(Settings.SETTINGS_FILE) then
		Settings.create()
	end
	
	local lSettingsFile = XML.load(Settings.SETTINGS_FILE)
	
	if not lSettingsFile then
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to load the configuration file.",255,255,255,true)
		return
	end
	
	Settings.g_aSettings = {}
	Settings.prepareDefaultSettings(Settings.g_aSettings,SettingsTemplate.get())
	
	local lbSuccess = Settings.loadSettingsBlock(lSettingsFile,SettingsTemplate.get(),Settings.g_aSettings)
	
	lSettingsFile:unload()
	
	if lbSuccess then
		outputDebugString("[Anti-Bounce]: Succesfully loaded configuration file.")
	else
		Utils.outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to load the configuration file.",255,255,255,true)
	end
end