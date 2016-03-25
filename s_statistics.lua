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

--[[------------------
* Anti-Bounce v2.4.0
* File: s_statistics.lua
*
* We highly discourage
* directly editing the
* scripts. Please use
* the customization
* possibilities.
--------------------]]

----------------------
-- Variables
----------------------

Statistics = {}
Statistics = setmetatable({},{__index = Statistics})

Statistics.g_bDoubleSent = false
Statistics.g_bDataSent = false

----------------------
-- Functions/Events
----------------------

function Statistics:setup()
	if(Settings.g_SettingsTable["enablestats"]["value"] == false) then
		return
	end
	
	Statistics:sendServerStatistics()
	
	if(Settings.g_SettingsTable["enableplayerstats"]["value"] == true) then
		setTimer(Statistics.sendPlayerData,900000,0)
	end
end

function Statistics:sendServerStatistics()
	local lStatisticData = {
		["uuid"] = Statistics:generateUniqueId(),
		["data"] = {
			["version"] = Core.VERSION,
			["mta-version-data"] = getVersion(),
			["fps-limit"] = getFPSLimit()
		}
	}
	
	if(Settings.g_SettingsTable["enablesettingstats"]["value"] == true) then
		lStatisticData["settings"] = {
			["enablecredits"] = Settings.g_SettingsTable["enablecredits"],
			["defaultstate"] = Settings.g_SettingsTable["defaultstate"],
			["bouncecommands"] = Settings.g_SettingsTable["bouncecommands"],
			["bouncebind"] = Settings.g_SettingsTable["bouncebind"],
			["checkupdates"] = Settings.g_SettingsTable["checkupdates"],
			["updatechecktimer"] = Settings.g_SettingsTable["updatechecktimer"],
			["enableplayerstats"] = Settings.g_SettingsTable["enableplayerstats"]
		}
	end
	
	fetchRemote("http://ultimateairgamers.com/mta/anti-bounce/stats.php?type=server&uuid="..lStatisticData["uuid"], 
		Statistics.onServerDataSent, tostring(toJSON(lStatisticData):gsub(" ","")), false)
end

function Statistics.sendPlayerData()
	local lStatisticData = {
		["uuid"] = Statistics:generateUniqueId(),
		["data"] = {}
	}
	
	for _,lPlayer in pairs(getElementsByType("player")) do
		local lUsageData = getElementData(lPlayer,"ab.player.usage")
		if(lUsageData ~= nil and lUsageData ~= false) then
			if(type(lUsageData) == "table") then
				local lPlayerUUID = lUsageData["uuid"]
				lUsageData["uuid"] = nil
				lUsageData["signed_code"] = sha256(getPlayerSerial(lPlayer))
				lStatisticData["data"][lPlayerUUID] = lUsageData
			end
		end
	end
	
	fetchRemote("http://ultimateairgamers.com/mta/anti-bounce/stats.php?type=playerdata&uuid="..lStatisticData["uuid"], Statistics.onPlayerDataSent, 
		tostring(toJSON(lStatisticData):gsub(" ","")), false)
end

function Statistics.onPlayerDataSent(lResponseData, lErrno)
    if lErrno == 0 then
		if(lResponseData == "server_blacklisted") then
			return
		end
		
		if(lResponseData == "invalid_uuid") then
			if(File.exists("uuid.json")) then
				File.delete("uuid.json")
			end

			return
		end
		
		if(lResponseData == "maintenance") then
			return
		end
		
		triggerClientEvent("onUsageResetRequest",Core.g_ResourceRoot)
	end
end

function Statistics.onServerDataSent(lResponseData, lErrno)
    if lErrno == 0 then
		if(lResponseData == "server_blacklisted") then
			Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffYour server appears to be on the statistic system' blacklist.",255,255,255,true)
			return
		end
		
		if(lResponseData == "invalid_uuid") then
			if(Statistics.g_bDoubleSent == false) then
				Statistics.g_bDoubleSent = true
				
				if(File.exists("uuid.json")) then
					File.delete("uuid.json")
				end
				Statistics:sendServerStatistics()
				
				return
			end
		end
		
		if(lResponseData == "maintenance") then
			Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffThe statistics service is currently having maintenance. We'll try to sent "
				.."the data again in an hour.",255,255,255,true)
			setTimer(Statistics.sendServerStatistics,3600000,1)
			return
		end
		
		Statistics.g_bDataSent = true
	end
end

function Statistics:generateUniqueId()
	if(File.exists("uuid.json")) then
		local lSuccess,lRet = pcall(Statistics.readUniqueId)
		
		if(lSuccess) then
			return lRet
		end
		
		File.delete("uuid.json")
	end
	
	local lHash = md5(tostring(getServerPort() + getTickCount() / math.random() * math.random(math.random(9999) * math.random(9999)))):lower()
	local lUUID = lHash:sub(0,8).."-"..lHash:sub(9,12).."-"..lHash:sub(13,16).."-"..lHash:sub(16,19).."-"..lHash:sub(20,31)
	
	local lFile = File.new("uuid.json")
	lFile:write(toJSON({["uuid"] = lUUID}))
	lFile:destroy()
	
	return lUUID
end

function Statistics.readUniqueId()
	local lFile = File.create("uuid.json")
	local lData = fromJSON(lFile:read(lFile:getSize()))
	lFile:destroy()
	
	return lData['uuid']
end
