HTTP = require('socket.http')
HTTPS = require('ssl.https')
URL = require('socket.url')
colors = (loadfile "./libs/ansicolors.lua")()
client = Redis.connect('127.0.0.1', 6379)
json = (loadfile "./libs/JSON.lua")()

function check_config()

	config = dofile('config.lua') -- Load configuration file.
	
	if not config.bot_api_key or config.bot_api_key == '' then
	
		return 'API KEY MISSING!'
		
	elseif not config.admin or config.admin == '' then
	
		return 'ADMIN ID MISSING!'
		
	end
	
end

function get_from(msg)

	local user = msg.from.first_name
	
	if msg.from.last_name then
	
		user = user..' '..msg.from.last_name
		
	end
	
	if msg.from.username then
	
		user = user..' [@'..msg.from.username..']'
		
	end
	
	user = user..' ('..msg.from.id..')'
	
	return user
	
end

function collect_stats(msg)

	if msg.text:match('^/start$') then -- Save Users
		if not client:sismember('BotUsers', msg.from.id)
			client:sadd('BotUsers', msg.from.id)
		end
		client:incr('StartsNumbers')
	end
	
	if msg.text then -- Save Messages Total
		client:incr('MessagesTotal')
	end

end

function get_what(msg)

	if msg.sticker then
		return 'sticker'
	elseif msg.photo then
		return 'photo'
	elseif msg.document then
		return 'document'
	elseif msg.audio then
		return 'audio'
	elseif msg.video then
		return 'video'
	elseif msg.voice then
		return 'voice'
	elseif msg.contact then
		return 'contact'
	elseif msg.location then
		return 'location'
	elseif msg.text then
		return 'text'
	else
		return 'service message'
	end
	
end

function bot_run()

    print(colors("%{red bright}"..logo))

	print(colors('%{cyan bright}Loading config.lua...'))
	
	config = dofile('config.lua') -- Load configuration file.
	
	local error = check_config()
	
	if error then
			print(colors('%{red bright}'..error))
		return
	end

	print(colors('%{cyan bright}Loading utilities.lua...'))
	
	utilities = dofile('utilities.lua') -- Load miscellaneous and cross-plugin functions.
	
	print(colors('%{cyan bright}Loading API functions table...'))
	
	api = require('methods') -- Load telegram api functions 
	
	print(colors('%{blue bright}Connecting To Telegram Servers...'))

	bot = nil

	while not bot do -- Get bot info
		bot = getMe()
	end

	bot = bot.result
		
	print(colors('%{yellow bright}BOT RUNNING : @'..bot.username .. ', AKA ' .. bot.first_name ..' ('..bot.id..')'))

	last_update = last_update or 0

	is_running = true

end

function msg_processor(msg)

	print(colors('\nMessage Info:\t %{red bright}'..get_from(msg)..'%{reset}\n%{magenta bright}In -> '..msg.chat.type..' ['..msg.chat.id..'] %{reset}%{yellow bright}('..get_what(msg)..')%{reset}\n%{cyan bright}Date -> ('..os.date('on %A, %d %B %Y at %X')..')%{reset}'))		

	collect_stats(msg) -- Saving Stats

	if msg == nil then return end

	if msg.date < os.time() - 5 then return end -- Do not process old messages.
	
	if msg.text:match('^/start$') then
		api.sendMessage(msg.chat.id, '*Test*', true)
	end
	
	return
	
end

bot_run() -- Run main function

while is_running do -- Start a loop witch receive messages.
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response then
		for i,msg in ipairs(response.result) do
			last_update = msg.update_id
			msg_processor(msg.message)
		end
	else
		print(colors("%{red bright}Conection Failed!"))
	end

end

print('Halted.')
