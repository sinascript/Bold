local BASE_URL = 'https://api.telegram.org/bot' .. config.bot_api_key

local function getCode(error)
	error = error:gsub('%[Error : %d%d%d : Bad Request: ', ''):gsub('%]', '')
	error = error:gsub('%[Error : 400 : ', ''):gsub('%]', '')
	for k,v in pairs(config.api_errors) do
		if error == v then
			return k
		end
	end
	return 107 --if unknown
end

local function sendRequest(url, user_id)

	local dat, code = HTTPS.request(url)
	
	if not dat then 
		return false, code 
	end
	
	local tab = JSON.decode(dat)

	if code ~= 200 then
		print(tab.description)
		--403: bot blocked, 429: spam limit ...send a message to the admin, return the code
		if code == 400 then code = api.getCode(tab.description) end --error code 400 is general: try to specify
		client:hincrby('bot:errors', code, 1)
		if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
			return false, code
		end
		return false, false --if the message is not sent because the bot is blocked, then don't return the code
	end
	
	--actually, this rarely happens
	if not tab.ok then
		return false, tab.description
	end

	return tab

end

local function getMe()

	local url = BASE_URL .. '/getMe'

	return sendRequest(url)

end

local function getUpdates(offset)

	local url = BASE_URL .. '/getUpdates?timeout=20'

	if offset then
		url = url .. '&offset=' .. offset
	end

	return sendRequest(url)

end

local function sendMessage(chat_id, text, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound)
	--print(text)
	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	url = url .. '&disable_web_page_preview=true'

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
	
	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end
	
	if not send_sound then
		url = url..'&disable_notification=true'--messages are silent by default
	end
	
	local res, code = sendRequest(url)
	
	if not res and code then --if the request failed and a code is returned (not 403 and 429)
		print('Delivery failed')
		save_log('send_msg', text)
	end
	
	return res, code --return false, and the code

end

local function sendReply(msg, text, markd, send_sound)

	return sendMessage(msg.chat.id, text, markd, true, msg.message_id, send_sound)

end

local function sendChatAction(chat_id, action)
 -- Support actions are typing, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location

	local url = BASE_URL .. '/sendChatAction?chat_id=' .. chat_id .. '&action=' .. action
	return sendRequest(url)

end

local function curlRequest(curl_command)
 -- Use at your own risk. Will not check for success.

	io.popen(curl_command)

end

local function sendInline(inline_query_id, results, cache_time, is_personal, next_offset)

 local url = BASE_URL .. '/answerInlineQuery'
 
 local curl_command = 'curl \'' .. url .. '\' --form-string \'inline_query_id=' .. inline_query_id .. '\' --form-string \'results=' .. json:encode(results) .. '\''
 
 if cache_time then
 
 curl_command = curl_command .. ' --form-string \'cache_time=' .. cache_time .. '\''
 
 end
 
 if is_personal then
 
 curl_command = curl_command .. ' --form-string \'is_personal=' .. is_personal .. '\''
 
 end
 
  if next_offset then
  
   curl_command = curl_command .. ' --form-string \'next_offset=' .. next_offset .. '\''
   
 end
 
  curl_command = curl_command .. ' --form-string \'switch_pm_text=Join Our Bot\''
     
return 	io.popen(curl_command)
 
end

return {
	getMe = getMe,
	getUpdates = getUpdates,
	getCode = getCode,
	
	sendMessage = sendMessage,
	sendReply = sendReply,
	sendRequest = sendRequest,
	sendInline = sendInline,
	sendChatAction = sendChatAction,
	
	curlRequest = curlRequest
}
