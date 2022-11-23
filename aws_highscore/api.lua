local config = require "./aws_highscore/config"
local sha1 = require "./aws_highscore/sha1/sha1"

local api = {}

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64_encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function base64_decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function get_date_header()
	api_file_log('get_date_header')
	local utc_timestamp = os.time()
	return os.date("!%a, %d %b %Y %H:%M:%S GMT", utc_timestamp)
end

function build_authorization(string_to_sign)
	local aws_access_key_id = config.aws_access_key_id
	local aws_secret_key = config.aws_secret_key
	local signature = base64_encode(sha1.hmac_binary(aws_secret_key, string_to_sign))
	local authorization = "AWS " .. aws_access_key_id .. ':' .. signature
	return authorization
end

function build_put_request(bucket, filepath)
	local response = {}
	local resource = "/" .. bucket .. "/" .. filepath
	local date = get_date_header()
	local content_type = "application/octet-stream"
	local string_to_sign = "PUT\n\n" .. content_type .. "\n" .. date .. "\n" .. resource

	local authorization = build_authorization(string_to_sign)

	local cmd = config.CURL .. ' -v -X PUT -T "' .. filepath .. '" ' ..
				'-H "Host: ' .. bucket .. '.s3.amazonaws.com" ' ..
				'-H "Date: ' .. date .. '" ' ..
				'-H "Content-Type: ' .. content_type .. '" ' ..
				'-H "Authorization: ' .. authorization .. '" ' ..
				'https://' .. bucket .. '.s3.amazonaws.com/' .. filepath
	api_file_log("===== PUT CMD =====")
	api_file_log(cmd)
	api_file_log("===================")
	return cmd
end

function build_get_request(bucket, filepath, temp_file)
	-- Need to make this so it does -o to a file, but we write to the file separately
	local date = get_date_header()
	local resource = "/" .. bucket .. "/" .. filepath
	local content_type = "application/octet-stream"
	local string_to_sign = "GET\n\n" .. content_type .. '\n' .. date .. '\n' .. resource
	local authorization = build_authorization(string_to_sign)

	local cmd = config.CURL .. ' -v https://' .. bucket .. '.s3.amazonaws.com/' .. filepath .. ' ' ..
			    '-H "Authorization: ' .. authorization .. '" ' ..
			    '-H "Content-Type: ' .. content_type .. '" ' ..
				'-H "Host: ' .. bucket .. '.s3.amazonaws.com" ' ..
				'-H "Date: ' .. date .. '" ' ..
				'-o ' .. temp_file
				-- '-o ' .. config._plugin_path .. '/../' .. filepath
	api_file_log("===== GET CMD =====")
	api_file_log(cmd)
	api_file_log("===================")
	return cmd
end

function api_file_log(str)
	if config.DEBUG then
		file = io.open(config.API_FILE_LOG, "a+")
		io.output(file)
		if type(str) == "string" then
			io.write(str)
		else 
			io.write('bad type: ' .. type(str))
		end
		io.write('\n')
		io.close(file)
	end
end

function api.get_highscore_file(filepath)
	api_file_log('API 1 get: ' .. filepath)
	local score_lines = {}
	temp_file = config.TEMP_OUT
	local cmd = build_get_request("aseaman-public-bucket", filepath, temp_file)
	local file_exists = true

	api_file_log('making the GET request!')
	response = os.execute(cmd) 

	for line in io.lines(temp_file) do
		if string.match(line, 'NoSuchKey') then
			file_exists = false
			api_file_log('breaking - NoSuchKey encountered')
			break
		end
		if string.match(line, 'Denied') then
			file_exists = false
			api_file_log('breaking - Access Denied encountered')
			break
		end
	end

	if file_exists then
		local out = assert(io.open(temp_file, 'rb'))
		local data = out:read('*all')
		api_file_log('file exists new read, returning score_lines')
		return data
	end
	api_file_log('aws highscore file does not exist for ' .. filepath)

	return nil
end

function api.save_highscore_file(filename)
	api_file_log('API save: ' .. filename)
	local cmd = build_put_request("aseaman-public-bucket", filename)
	if true then
		api_file_log('making the PUT request!')
		response = os.execute(cmd)
	else
		api_file_log('didnt make the PUT request')
	end

	return "put response"
end

return api
