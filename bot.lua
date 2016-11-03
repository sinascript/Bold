HTTP = require('socket.http')
HTTPS = require('ssl.https')
URL = require('socket.url')
JSON = (loadfile "./libs/dkjson.lua")()
redis = require('redis')
colors = (loadfile "./libs/ansicolors.lua")()
client = Redis.connect('127.0.0.1', 6379)
json = (loadfile "./libs/JSON.lua")()
serpent = require('serpent')

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

	if not msg.text then return nil end

	if msg.text:match('^/start$') then -- Save Users
		if not client:sismember('BotUsers', msg.from.id) then
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

	utilities = dofile('utilities.lua') -- Load miscellaneous and cross-plugin functions.

    print(colors("%{red bright}"..logo))

	print(colors('%{cyan bright}Loading config.lua...'))
	
	config = dofile('config.lua') -- Load configuration file.
	
	local error = check_config()
	
	if error then
			print(colors('%{red bright}'..error))
		return
	end

	print(colors('%{cyan bright}Loading utilities.lua...'))
	
	print(colors('%{cyan bright}Loading API functions table...'))
	
	api = require('methods') -- Load telegram api functions 
	
	print(colors('%{blue bright}Connecting To Telegram Servers...'))

	bot = nil

	while not bot do -- Get bot info
		bot = api.getMe()
	end

	bot = bot.result
		
	print(colors('%{yellow bright}BOT RUNNING : @'..bot.username .. ', AKA ' .. bot.first_name ..' ('..bot.id..')'))

	math.randomseed(os.time())
	math.random()
	
	last_update = last_update or 0
	last_cron = last_cron or os.time()

	is_running = true

end

function on_type(msg)

	if msg.text then
		return 'Text -> [ "'..msg.text..'" ]'
	elseif msg.sticker then
		return 'Sticker Id -> [ "'..msg.sticker.file_id..'" ]'
	elseif msg.document.mime_type == 'video/mp4' then
		return 'Gif Id -> [ "'..msg.document.file_id..'" ]'
	elseif msg.document then
		return 'Document Id -> [ "'..msg.document.file_id..'" ]'
	elseif msg.audio then
		return 'Audio Id -> [ "'..msg.audio.file_id..'" ]'
	elseif msg.video then
		return 'Video Id -> [ "'..msg.video.file_id..'" ]'
	elseif msg.voice then
		return 'Voice Id -> [ "'..msg.voice.file_id..'" ]'
	elseif msg.contact then
		return 'Phone Number -> [ "'..msg.contact.phone_number..'" ]'
	elseif msg.location then
		return 'Coordinates Location -> [ '..msg.location.longitude..'X'..msg.location.latitude..' ]'
	elseif msg.photo then
		return ''
	else
		return 'Service Message!!!'
	end

end

function is_text_inline(inline)

	if inline.query then
		if inline.query == '' then
			return ''
		else
			return '\nText -> [ "'..inline.query..'" ]'
		end
	else
		return ''
	end

end

function msg_processor(msg)

	if msg.date < os.time() - 5 then return end -- Do not process old messages.
	
	if not msg then
		api.sendMessage(config.admin, 'Shit, a loop without msg!')
		return
	end
	
	if not msg.text then msg.text = msg.caption or '' end
	
	if msg.text:match('^/start .+') then
		msg.text = '/' .. msg.text:input()
	end
	
	collect_stats(msg) -- Saving Stats
	
	print(colors('\nMessage Info:\t %{red bright}'..get_from(msg)..'%{reset}\n%{magenta bright}In -> '..msg.chat.type..' ['..msg.chat.id..'] %{reset}%{yellow bright}('..get_what(msg)..')%{reset}\n%{cyan bright}Date -> ('..os.date('on %A, %d %B %Y at %X')..')%{reset}\n%{green bright}'..on_type(msg)..'%{reset}'))		

	if msg.text then
	
		if msg.text:match('^/start$') then
			api.sendMessage(msg.chat.id, '*Test*', true)
		end
		
		if is_admin(msg) then
		
			if msg.text:match('^/reload$') then
				bot_run()
				api.sendReply(msg, '*Bot Reloaded!*', true)
			end
		
			if msg.text:match('^/update$') then
				io.popen('git pull'):read('*all')
				api.sendReply(msg, '*Source Updated!*', true)
			end
		end
	end
	
	return
	
end

function inline_processor(inline)

	if not inline then
		api.sendMessage(config.admin, 'Shit, a loop without inline!')
		return
	end
	
	if not inline.query or inline.query == '' then
		return false
	end

	print(colors('\nInline Info:\t %{red bright}'..get_from(inline)..'%{reset}\n%{cyan bright}Date -> ('..os.date('on %A, %d %B %Y at %X')..')%{reset}%{yellow bright}'..is_text_inline(inline)..'%{reset}'))		
	
	if inline.query then
	
		local text = inline.query
	
		if not text:match('^(%p+)(.*)(%p+)(%p+)(.*)(%p+)$') then
		
		local qresult = {{},{},{}}
		
		qresult[1].id= '1'
		qresult[1].title = 'Bold'
		qresult[1].type = 'article'
		qresult[1].description = '*'..text..'*'
		qresult[1].thumb_url = 'http://s6.picofile.com/file/8247733176/B.png'
		qresult[1].message_text = '*'..text..'*'
		qresult[1].parse_mode = 'Markdown'
		
		qresult[2].id= '2'
		qresult[2].title = 'Italic'
		qresult[2].type = 'article'
		qresult[2].description = '_'..text..'_'
		qresult[2].thumb_url = 'http://s7.picofile.com/file/8247733234/I.png'
		qresult[2].message_text = '_'..text..'_'
		qresult[2].parse_mode = 'Markdown'
		
		qresult[3].id= '3'
		qresult[3].title = 'Fixedsys'
		qresult[3].type = 'article'
		qresult[3].description = '`'..text..'`'
		qresult[3].thumb_url = 'http://s7.picofile.com/file/8247733776/C2.png'
		qresult[3].message_text = '`'..text..'`'
		qresult[3].parse_mode = 'Markdown'
		
			api.sendInline(inline.id, qresult, 'Markdown')
		
		else
		
		local qresult = {{},{},{},{}}
		
		qresult[1].id= '1'
		qresult[1].title = 'Custom'
		qresult[1].type = 'article'
		qresult[1].description = text
		qresult[1].thumb_url = 'http://s6.picofile.com/file/8247733200/custom.png'
		qresult[1].message_text = text
		qresult[1].parse_mode = 'Markdown'
		
		qresult[2].id= '2'
		qresult[2].title = 'Bold'
		qresult[2].type = 'article'
		qresult[2].description = '*'..text..'*'
		qresult[2].thumb_url = 'http://s6.picofile.com/file/8247733176/B.png'
		qresult[2].message_text = '*'..text..'*'
		qresult[2].parse_mode = 'Markdown'
		
		qresult[3].id= '3'
		qresult[3].title = 'Italic'
		qresult[3].type = 'article'
		qresult[3].description = '_'..text..'_'
		qresult[3].thumb_url = 'http://s7.picofile.com/file/8247733234/I.png'
		qresult[3].message_text = '_'..text..'_'
		qresult[3].parse_mode = 'Markdown'
		
		qresult[4].id= '4'
		qresult[4].title = 'Fixedsys'
		qresult[4].type = 'article'
		qresult[4].description = '`'..text..'`'
		qresult[4].thumb_url = 'http://s7.picofile.com/file/8247733776/C2.png'
		qresult[4].message_text = '`'..text..'`'
		qresult[4].parse_mode = 'Markdown'
		
			api.sendInline(inline.id, qresult, 'Markdown')

		end
	end
		
	return
	
end

function rethink_reply(msg)
	msg.reply = msg.reply_to_message
	if msg.reply.caption then
		msg.reply.text = msg.reply.caption
	end
	return msg_processor(msg)
end

function inline_to_msg(inline)
	local msg = {
		id = inline.id,
    	chat = {
      		id = inline.id,
      		type = 'inline',
      		title = inline.from.first_name
    	},
    	from = inline.from,
		message_id = math.random(1,800),
    	text = '###inline:'..inline.query,
    	query = inline.query,
    	date = os.time() + 100
    }
    return msg_processor(msg)
end

function forward_to_msg(msg)
	if msg.text then
		msg.text = '###forward:'..msg.text
	else
		msg.text = '###forward'
	end
    return msg_processor(msg)
end

bot_run() -- Run main function

while is_running do -- Start a loop witch receive messages.
	local response = api.getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response then
		for i,msg in ipairs(response.result) do
			last_update = msg.update_id
			if msg.message then
				if msg.message.reply_to_message then
					rethink_reply(msg.message)
				elseif msg.message.forward_from then
					forward_to_msg(msg.message)
				else
					msg_processor(msg.message)
				end
			end
			if msg.inline_query then
				inline_processor(msg.inline_query)
			end
		end
	else
		print(colors("%{red bright}Conection Failed!"))
	end

end

print('Halted.')
