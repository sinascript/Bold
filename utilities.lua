logo = [[ 
    _        _             _____
   / \__   _(_)_ __ __ _  |_   _|__  __ _ _ __ ___
  / _ \ \ / / | '__/ _` |   | |/ _ \/ _` | '_ ` _ \
 / ___ \ V /| | | | (_| |   | |  __/ (_| | | | | | |
/_/   \_\_/ |_|_|  \__,_|   |_|\___|\__,_|_| |_| |_|
  
]]

function is_admin(msg)-- Check if user is admin or not
  local var = false
  for k,v in pairs(config.admin) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

function write_file(path, text, mode)
	if not mode then
		mode = "w"
	end
	file = io.open(path, mode)
	if not file then
		return false --path uncorrect
	else
		file:write(text)
		file:close()
		return true
	end
end

function clone_table(t) --doing "shit = table" in lua is create a pointer
  local new_t = {}
  local i, v = next(t, nil)
  while i do
    new_t[i] = v
    i, v = next(t, i)
  end
  return new_t
end

function download_to_file(url, file_path)
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return false, code end

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path, code
end

function file_exists(name)
  local f = io.open(name,"r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end
