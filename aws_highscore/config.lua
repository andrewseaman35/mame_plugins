local config_file = './aws_highscore/.aws_config'

local file = {}
local config = {}

config.DEBUG = false
config.BASE_DIR = io.popen"cd":read'*l'
config.DATA_DIR = config.BASE_DIR .. "\\plugins\\aws_highscore\\data"
config.API_FILE_LOG = config.BASE_DIR .. "\\plugins\\aws_highscore\\data\\aws_highscore_api.log"
config.PLUGIN_FILE_LOG = config.BASE_DIR .. "\\plugins\\aws_highscore\\data\\aws_highscore.log"
config.TEMP_OUT = config.BASE_DIR .. "\\plugins\\aws_highscore\\data\\temp_hiscore.out"
config.CURL = config.BASE_DIR .. "\\plugins\\aws_highscore\\bin\\curl"

function api_file_log(str)
    if config.DEBUG then
        file = io.open("aws_highscore_api.log", "a+")
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

function file_exists(file)
  	local f = io.open(file, "rb")
  	if f then 
  	   f:close() 
  	end
  	
  	return f ~= nil
end


function read_config(file)
  	if not file_exists(file) then 
        api_file_log('CONFIG: ' .. file .. 'does NOT exist!')
  		return {} 
  	end
  	
  	lines = {}
  	
  	for line in io.lines(file) do 
    	lines[#lines + 1] = line
  	end	
  	
  	return lines
end

function config.init(plugin_path)
    config._plugin_path = plugin_path
    config._filepath = plugin_path .. '/.aws_config' 
    local config_lines = read_config(config._filepath)
    for _, line in pairs(config_lines) do
        split_index = string.find(line, "=")
        config_key = string.sub(line, 1, split_index - 1)
        config_value = string.sub(line, split_index + 1)
        config[config_key] = config_value
    end
end

return config