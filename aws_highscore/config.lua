local config_file = '.config'

local file = {}

function file_exists(file)
  	local f = io.open(file, "rb")
  	if f then 
  	   f:close() 
  	end
  	
  	return f ~= nil
end


function read_config(file)
  	if not file_exists(file) then 
  		return {} 
  	end
  	
  	lines = {}
  	
  	for line in io.lines(file) do 
    	lines[#lines + 1] = line
  	end	
  	
  	return lines
end


local config = {}
local config_lines = read_config(config_file)
for _, line in pairs(config_lines) do
	config_key, config_value = string.match(line, "(%w+)=(%w+)")
	config[config_key] = config_value
end

return config