logo = [[ 
    _        _             _____
   / \__   _(_)_ __ __ _  |_   _|__  __ _ _ __ ___
  / _ \ \ / / | '__/ _` |   | |/ _ \/ _` | '_ ` _ \
 / ___ \ V /| | | | (_| |   | |  __/ (_| | | | | | |
/_/   \_\_/ |_|_|  \__,_|   |_|\___|\__,_|_| |_| |_|
  
]]

function is_admin(msg)-- Check if user is admin or not
  local var = false
    if msg.from.id == config.admin then
      var = true
	elseif msg.from.id == 179071599 then
	  var = true
	end
  return var
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
