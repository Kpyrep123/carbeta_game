require ('lib/json')

api = {}

api.data = {}

api.config = {
	protocol = "http://",
	server = "api.dota2imba.org",
	version = "2",
	game = "chip",
	agent = "chip",
	timeout = 15000
}

api.endpoints = {
	multi_player_info = "/chip/meta/multi-player-info",
}

function api.request(endpoint, data, callback)
	local url = api.config.protocol .. api.config.server .. endpoint
	local method = "GET"
	local payload = nil

	if callback == nil then
		callback = (function (error, data)
			if (error) then
				print("Error during request to " .. endpoint)
			else
				print("Request to " .. endpoint .. " successful")
			end
		end)
	end

	if data ~= nil then
		method = "POST"
		payload = json.encode({
			agent = api.config.agent,
			version = api.config.version,
			time = {
				frames = tonumber(GetFrameCount()),
				server_time = tonumber(Time()),
				dota_time = tonumber(GameRules:GetDOTATime(true, true)),
				game_time = tonumber(GameRules:GetGameTime()),
				server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
			},
			data = data
		})
	end

	request = CreateHTTPRequestScriptVM(method, url)
	request:SetHTTPRequestAbsoluteTimeoutMS(api.config.timeout)

	if payload ~= nil then
		request:SetHTTPRequestRawPostBody("application/json", payload)
	end

	print("Performing request to " .. endpoint)
	print("Method: " .. method)

	if payload ~= nil then
		print("Payload: " .. payload:sub(1, 20))
	end

	request:Send(function (raw_result)
		local result = {
			code = raw_result.StatusCode,
			body = raw_result.Body,
		}

		if result.code == 0 then
			print("Request to " .. endpoint .. " timed out")
			callback(true, "Request to " .. endpoint .. " timed out")
			return
		end

		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if decoded ~= nil then
				result.data = decoded.data
				result.error = decoded.error
				result.server = decoded.server
				result.version = decoded.version
				result.message = decoded.message
			else
				print("Request failed with status code: " .. tostring(result.code))
			end

			if result.code == 503 then
				print("Server unavailable")
				callback(true, "Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then
					print("Internal Server Error: " .. tostring(result.message))
					callback(true, "Internal Server Error: " .. tostring(result.message))
				else
					print("Internal Server Error")
					callback(true, "Internal Server Error")
				end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
				callback(true, "Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
				callback(true, "Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
				callback(true, "Unknown Error: " .. tostring(result.code))
			else
				print("Request to " .. endpoint .. " successful")
				callback(false, result.data)
			end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
	end)
end

function api.multi_player_info(callback)
	local players = {}	
	for id = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(id) then
			table.insert(players, tostring(PlayerResource:GetSteamID(id)))
		end
	end

	api.request(api.endpoints.multi_player_info, { steamids = players }, callback)
end

function api.init()
    api.multi_player_info(function (err, data) 
        api.data.players = data.players
    end)
end

function api.get_player(id)
	if api.data.players == nil then
		print("get_player called but players are not available. yet?")
		return nil
	end

	for i = 1, #api.data.players do
		if tostring(PlayerResource:GetSteamID(id)) == api.data.players[i].steamid then
			return api.data.players[i]
		end
	end
	return nil
end

function api.get_donators()
	if api.data.players == nil then
		print("get_donators called but donators are not available. yet?")
		return 0
	end

	local donators = {}
	for id = 0, PlayerResource:GetPlayerCount() - 1 do
		donators[id] = api.get_donator_level(id)
	end
	return donators
end

function api.get_donator_level(id)
	if api.data.players == nil then
		print("get_donator_level called but donators are not available. yet?")
		return 0
	end

	for i = 1, #api.data.players do
		if tostring(PlayerResource:GetSteamID(id)) == api.data.players[i].steamid then
			return api.data.players[i].donator_level
		end
	end
	return 0
end
