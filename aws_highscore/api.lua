-- https://api-1602641895.live.andrewcseaman.com/v1/test/whisky
-- curl -v -d '{"action": "get_current_shelf"}' -H 'Content-Type: application/json'  -X POST https://api-1602641895.live.andrewcseaman.com/v1/test/whisky
-- curl -v -d '{"action": "save", "payload": "{\"user\": \"andrew\", \"secret_key\": \"my_secret\", \"game_id\": \"my_game\", \"score\": \"123456\"}"}' -H 'Content-Type: application/json' -X POST http://0.0.0.0:8089/mame_highscore
-- '{"action": "save", "payload": "{\\"user\\": \\"andrew\\", \\"secret_key\\": \\"my_secret\\", \\"game_id\\": \\"my_game\\", \\"score\\": \\"123456\\"}\\"}'

local config = require "./config"
local https = require 'socket.http'
-- local https = require 'ssl.https'
local ltn12 = require 'ltn12'
local json = require 'json'
local api = {}


-- local url = "https://api-1602641895.live.andrewcseaman.com/v1/test/mame_highscore"
local url = "http://0.0.0.0:8099/mame_highscore"
local actions = {
	['save'] = 'add_to_shelf',
	['load'] = 'get_current_shelf'
}
local save_request_format = ""


function post_request(url, request_body)
	local response = {}
	local resp, code, headers = https.request {
		method = "POST",
		url = url,
		source = ltn12.source.string(request_body),
		headers = 
			{
 				["Accept"] = "*/*",
                ["Accept-Language"] = "en-us",
                ["Content-Type"] = "application/json",
                ["Content-Length"] = string.len(request_body),
			},
		sink = ltn12.sink.table(response)
	}
	return response, code
end


function build_load_game_highscores_body(game_id)
	request_body = string.format(
		'{"action": "get_by_game_id", "payload": "{\\"user\\": \\"%s\\", \\"secret_key\\": \\"%s\\", \\"game_id\\": \\"%s\\"}"}',
		config.user,
		config.secret_key,
		game_id
	)
	print(request_body)
	return request_body
end


function build_save_request_body(game_id, score)
	request_body = string.format(
		'{"action": "save", "payload": "{\\"user\\": \\"%s\\", \\"secret_key\\": \\"%s\\", \\"game_id\\": \\"%s\\", \\"score\\": \\"%s\\"}"}',
		config.user,
		config.secret_key,
		game_id, 
		score
	)
	print(request_body)
	return request_body
end


function api.load_highscores_by_game_id(game_id)
	request_body = build_load_game_highscores_body(game_id)
	response, code = post_request(url, request_body)
	return json.decode(response[1])
end


function api.save_highscore(game_id, score)
	request_body = build_save_request_body(game_id, score)
	response, code = post_request(url, request_body)
	return response
end

-- api.save_highscore('space_invadar!', 1000)
response = api.load_highscores_by_game_id('space_invadar!')