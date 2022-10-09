local QRCore = exports["qr-core"]:GetCoreObject()
local CurrentWeather = Config.StartWeather
local lastWeather = CurrentWeather
local baseTime = Config.BaseTime
local timeOffset = Config.TimeOffset
local timer = 0
local freezeTime = Config.FreezeTime
local blackout = Config.Blackout
local blackoutVehicle = Config.BlackoutVehicle
local disable = Config.Disabled

RegisterNetEvent("QRCore:Client:OnPlayerLoaded", function()
	disable = false
	TriggerServerEvent("qr-weathersync:server:RequestStateSync")
	-- TriggerServerEvent("qr-weathersync:server:RequestCommands")
end)

RegisterNetEvent("qr-weathersync:client:EnableSync", function()
	disable = false
	TriggerServerEvent("qr-weathersync:server:RequestStateSync")
end)

RegisterNetEvent("qr-weathersync:client:SyncWeather", function(NewWeather, newblackout)
	CurrentWeather = NewWeather
	blackout = newblackout
end)

RegisterNetEvent("qr-weathersync:client:SyncTime", function(base, offset, freeze)
	freezeTime = freeze
	timeOffset = offset
	baseTime = base
end)

CreateThread(function()
	while true do
		if not disable then
			if lastWeather ~= CurrentWeather then
				lastWeather = CurrentWeather
				Citizen.InvokeNative(0x59174F1AFE095B5A, GetHashKey(CurrentWeather), false, true, true, 45.0, false) -- SetWeatherType
				Wait(15000)
			end
			Wait(100) -- Wait 0 seconds to prevent crashing.
			SetArtificialLightsState(blackout)
			Citizen.InvokeNative(0xFA3E3CA8A1DE6D5D, GetHashKey(lastWeather), GetHashKey(CurrentWeather), 0.7, 1) -- SetCurrWeatherState
			if lastWeather == "SNOW" or lastWeather == "WHITEOUT" then
				Citizen.InvokeNative(0xF6BEE7E80EC5CA40, 0.9) -- SetSnowLevel
			end
			if lastWeather == "DRIZZLE" or lastWeather == "SLEET" then
				Citizen.InvokeNative(0x193DFC0526830FD6, 0.2) -- SetRain
			elseif
				lastWeather == "RAIN"
				or lastWeather == "HAIL"
				or lastWeather == "SHOWER"
				or lastWeather == "THUNDER"
			then
				Citizen.InvokeNative(0x193DFC0526830FD6, 0.5)  -- SetRain
			elseif lastWeather == "THUNDERSTORM" then
				Citizen.InvokeNative(0x193DFC0526830FD6, 0.7) -- SetRain
			else
				Citizen.InvokeNative(0x193DFC0526830FD6, 0.0) -- SetRain
				Citizen.InvokeNative(0xF6BEE7E80EC5CA40, 0) -- -- SetSnowLevel
			end
		else
			Wait(1000)
		end
	end
end)

CreateThread(function()
	local hour = 0
	local minute = 0
	local second = 0 --Add seconds for shadow smoothness
	while true do
		if not disable then
			Wait(0)
			local newBaseTime = baseTime
			if GetGameTimer() - 22 > timer then --Generate seconds in client side to avoid communiation
				second = second + 1 --Minutes are sent from the server every 2 seconds to keep sync
				timer = GetGameTimer()
			end
			if freezeTime then
				timeOffset = timeOffset + baseTime - newBaseTime
			end
			baseTime = newBaseTime
			hour = math.floor(((baseTime + timeOffset) / 60) % 24)
			if minute ~= math.floor((baseTime + timeOffset) % 60) then --Reset seconds to 0 when new minute
				minute = math.floor((baseTime + timeOffset) % 60)
				second = 0
			end
			NetworkClockTimeOverride(hour, minute, second) --Send hour included seconds to network clock time
		else
			Wait(1000)
		end
	end
end)
