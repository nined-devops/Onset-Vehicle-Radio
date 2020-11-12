	
	local RADIO = {}
	local RADIO_TIMER
	local PLAYER_SEAT = 0
	local LOCAL_RADIO = 0
	local LIST_RADIO = {
		{
			Name = "Record Radio", 		
			Link = "http://air.radiorecord.ru:805/rr_320"
		},
		{
			Name = "Record Chill Out", 	
			Link = "http://air.radiorecord.ru:8102/chil_320"
		},
		{
			Name = "Record EDM", 			
			Link = "http://air.radiorecord.ru:8102/club_320"
		},
		{
			Name = "Record Deep", 			
			Link = "http://air.radiorecord.ru:8102/deep_320"
		},
		{
			Name = "Record Breaks", 		
			Link = "http://air.radiorecord.ru:8102/brks_320"
		},
		{
			Name = "Record Dancecore", 	
			Link = "http://air.radiorecord.ru:8102/dc_320"
		},
		{
			Name = "Record Dubstep", 		
			Link = "http://air.radiorecord.ru:8102/dub_320"
		},
		{
			Name = "Record Trap", 			
			Link = "http://air.radiorecord.ru:8102/trap_320"
		},
		{
			Name = "Pirate Station", 		
			Link = "http://air.radiorecord.ru:8102/ps_320"
		},
		{
			Name = "Energy FM", 		
			Link = "http://87.252.227.241:8888/energyfm"
		}
	}
	
	
	AddEvent("OnKeyPress", function(Key)
		if (Key == "Mouse Wheel Down" or Key == "Mouse Wheel Up") then
			local Vehicle = GetPlayerVehicle(GetPlayerId())
			if IsValidVehicle(Vehicle) and PLAYER_SEAT == 1 then
				if Key == "Mouse Wheel Down" then SwitchRadioInVehicle("next")
				elseif Key == "Mouse Wheel Up" then SwitchRadioInVehicle("prev") end
				AddPlayerChat("Radio set to "..LOCAL_RADIO)
				if RADIO_TIMER and IsValidTimer(RADIO_TIMER) then DestroyTimer(RADIO_TIMER) end
				RADIO_TIMER = CreateCountTimer(SetRadioInVehicle, 1000, 1, Vehicle, LOCAL_RADIO)
			end
		end
	end)
	
	
	function SetRadioInVehicle(Vehicle, Radiostation)
		if IsValidVehicle(Vehicle) then
			CallRemoteEvent("SendSetVehicleRadio", Vehicle, Radiostation)
		end
	end
	
	
	function PlayRadioInVehicle(Vehicle, Radiostation)
		if IsValidVehicle(Vehicle) and Radiostation then
			if not LIST_RADIO[Radiostation] then return end
			local Link = LIST_RADIO[Radiostation]["Link"]
			local x, y, z = GetVehicleLocation(Vehicle)
			local Sound = CreateSound3D(Link, x, y, z, 2000, true)
			SetSoundVolume(Sound, 0.2)
			RADIO[Vehicle] = Sound
		end
	end
	
	
	function StopRadioInVehicle(Vehicle)
		if IsValidVehicle(Vehicle) and RADIO[Vehicle] then
			if IsValidSound(RADIO[Vehicle]) then DestroySound(RADIO[Vehicle]) end
			RADIO[Vehicle] = nil 
		end
	end
	
	
	function SwitchRadioInVehicle(Step)
		if Step == "prev" then LOCAL_RADIO = LOCAL_RADIO + 1 end
		if Step == "next" then LOCAL_RADIO = LOCAL_RADIO - 1 end
		if LOCAL_RADIO > #LIST_RADIO then LOCAL_RADIO = 0 end
		if LOCAL_RADIO < 0 then LOCAL_RADIO = #LIST_RADIO end
	end
	
	
	AddEvent("OnVehicleStreamIn", function(Vehicle)
		StopRadioInVehicle(Vehicle)
		PlayRadioInVehicle(Vehicle, GetVehiclePropertyValue(Vehicle, "VehicleRadio"))
	end)
	
	
	AddEvent("OnVehicleStreamOut", function(Vehicle)
		StopRadioInVehicle(Vehicle)
	end)
	
	
	AddEvent("OnVehicleNetworkUpdatePropertyValue", function(Vehicle, PropertyName, PropertyValue)
		if IsValidVehicle(Vehicle) and PropertyName == "VehicleRadio" then
			if PropertyValue == 0 then
				StopRadioInVehicle(Vehicle)
			else
				StopRadioInVehicle(Vehicle)
				PlayRadioInVehicle(Vehicle, GetVehiclePropertyValue(Vehicle, "VehicleRadio"))
			end
		end
	end)
	
	
	AddEvent("OnPlayerEnterVehicle", function(Player, Vehicle, Seat)
		if Player == GetPlayerId() and Seat == 1 then
			LOCAL_RADIO = GetVehiclePropertyValue(Vehicle, "VehicleRadio") or 0
		end
		if Player == GetPlayerId() then
			PLAYER_SEAT = Seat
		end
	end)
	
	
	AddEvent("OnPlayerLeaveVehicle", function(Player, Vehicle, Seat)
		if Player == GetPlayerId() then
			PLAYER_SEAT = 0
			if RADIO_TIMER and IsValidTimer(RADIO_TIMER) then DestroyTimer(RADIO_TIMER) end
		end
	end)
	
	
	AddEvent("OnGameTick", function()
		for Vehicle, Radio in pairs(RADIO) do
			if IsValidVehicle(Vehicle) and IsValidSound(Radio) then
				local x, y, z = GetVehicleLocation(Vehicle)
				SetSound3DLocation(Radio, x, y, z)
			end
			if not IsValidVehicle(Vehicle) then 
				StopRadioInVehicle(Vehicle) 
			end
			if not IsValidSound(Radio) then 
				StopRadioInVehicle(Vehicle) 
			end
		end
	end)
