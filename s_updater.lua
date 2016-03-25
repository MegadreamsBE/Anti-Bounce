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
* File: s_updater.lua
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

Updater = {}
Updater = setmetatable({},{__index = Updater})

----------------------
-- Functions/Events
----------------------

function Updater:setup()
	if(Settings.g_SettingsTable["checkupdates"]["value"] == false) then
		return
	end
	
	Updater:checkForUpdates()
	setTimer(Updater.checkForUpdates,Settings.g_SettingsTable["updatechecktimer"]["value"],0)
end

function Updater:checkForUpdates()
	if(Settings.g_SettingsTable["checkupdates"]["value"] == false) then
		return
	end
	
	fetchRemote("http://ultimateairgamers.com/mta/anti-bounce/update-info.txt", Updater.onUpdateInfoReceived, "", false)
end

function Updater.onUpdateInfoReceived(lResponseData, lErrno)
    if lErrno == 0 then
        lUpdateData = fromJSON(lResponseData)
		
		if(tonumber(lUpdateData["min_version"]) > Core.VERSION) then
			local lCheckKey = "-1"
			
			for key,_ in pairs(lUpdateData["update-info"]) do
				if(key ~= "-1") then
					local lSplitData = split(key,"-")
					
					if(tonumber(lSplitData[1]) <= Core.VERSION and tonumber(lSplitData[2]) >= Core.VERSION) then
						lCheckKey = key
						break
					end
				end
			end
			
			if(lUpdateData["update-info"][lCheckKey]["custom-message"] == true) then
				Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffff"..lUpdateData["update-info"][lCheckKey]["message"],255,255,255,true)
			else
				Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffA #368DEBnew #ffffffversion (#368DEBv"..lUpdateData["version"].."#ffffff) " 
					.."of the #368DEBAnti-Bounce #ffffffis available. You may download it on '#368DEBcommunity.mtasa.com#ffffff'.",255,255,255,true)
			end
		end
    end
end