local json=luaopen_cjson()
local co = HelperCoroutine

CMD_EVENT_READ           = 0x01
CMD_EVENT_ERROR        = 0x02
CMD_EVENT_ACCEPT     = 0x03
CMD_EVENT_TIMER          = 0x04
CMD_EVENT_NOTIFY        = 0x05
CMD_EVENT_HTTPGET   = 0x06
CMD_EVENT_HTTPPOST= 0x07
CMD_EVENT_CONNECTED= 0x08
CMD_EVENT_HTTPREQ  = 0x09
CMD_EVENT_READ2   = 0x0B
CMD_EVENT_WRITE2   =0x0C 
CMD_EVENT_ERROR2   =0x0D
CMD_EVENT_REQUEST_ERROR= 0x0F

--外部接口
--OnClientMessage
--OnClientConnect
--OnClientError
--OnServerUpdate()
local function print_debug()
	PrintLog(debug.traceback())
end

local function cmd_event_read(bev,msg)
	Print("cmd_event_read")
	
	--like cocosocket.
	if is_coresocket(bev) then
		--PrintFastLog('coresocket on read:', msg:getMsgSize(), ' data:', msg:getMsgPtr())
		_socket_t.on_read(bev)
		return
	end
	
	while true do
		local ret,msg0=HelperPopMessage(msg)
		if ret==0 then
			msg0:setMode(SM_READ)			
			local wMain = msg0:uint16()
			local wSub  = msg0:uint16()					
			OnClientMessage(wMain,wSub,bev,msg0)
		elseif ret<0 then
			local err = msg0;
			Print('data packet error:'..ret..', '..err);
			OnClientError(bev,ret)			
			break;
		else				
			Print('data packet :'..ret..', '..ret);			
			break;
		end
	end
end

local function cmd_event_error(bev,msg)
	OnClientError(bev)
end

local function cmd_event_connected(bev,msg)
	print('cmd_event_connected', bev)	
	_socket_t.on_connected(bev)
end

local function cmd_event_error2(bev,msg)
	PrintLog('cmd_event_error2')
	--OnClientError(bev)
	_socket_t.on_closed(bev)
end

local function cmd_event_accept(bev,msg)	
	OnClientConnect(bev,msg);
end

local function cmd_event_timer()
	--Print('cmd_event_timer')
	if not OnServerUpdate then
		return
	end
	
	PrintFlushLogFile()
	

	if __timer_thread then
		--Print('cmd_event_timer resume')
		return coroutine.resume(__timer_thread)
	end
	
	__timer_thread = co(function(thread)
		while true do
				local time = os.clock()
				--Print('OnServerUpdate')
				xpcall(OnServerUpdate, print_debug)
				coroutine.yield()
				--Print('OnServerUpdate:'..(os.clock()-time))
			end
		end)
end

local function cmd_event_notify(code,msg)	

end

local function cmd_event_httpget(code,msg)

end

local function cmd_event_httppost(code,msg)

end

local content_type_table = {
  ["txt"]= "text/plain", 
  ["c"]=  "text/plain", 
  ["h"]=  "text/plain", 
  ["html"]=  "text/html", 
 ["htm"]=  "text/html",
 ["css"]=  "text/css" ,
 ["gif"]=  "image/gif" , 
 ["jpg"]= "image/jpg" , 
 ["jpeg"]=  "image/jpeg", 
 ["png"]=  "image/png" , 
 ["pdf"]=  "application/pdf" , 
 ["ps"]=  "application/postscript" 
}

local function cmd_event_httpreq_error(req, err)
	PrintFastLog('cmd_event_httpreq_error:', err)
	print('cmd_event_httpreq_error')
	if not __requests[req] then
		return
	end
	
	__requests[req]=nil
	__WebMessageBuffer[req]=nil
	if OnOffline then
		--OnOffline(req)		
		co(function(thread)			
			xpcall(OnOffline, print_debug, req)
		end)
		
	end	
end



local get_file_ext = get_file_ext 
local function cmd_event_httpreq(req)
	__requests[req]=req
	--local headers = evhttp_get_input_headers(req)
	local uri = evhttp_request_get_uri(req)
	print('uri:', uri)
	local path = evhttp_uri_get_path(req)
	if not path then
		print('path is null.')
		return
	end
		
	--print('uri:', uri)
	local decoded_path = evhttp_uridecode(path)
	local ext = get_file_ext(decoded_path)
	local req_cmd = decoded_path
	local _,__,cmd,path_ = string.find(req_cmd, '(/%w+)(/.+)')	
	print('req_cmd:', req_cmd, ' cmd:', cmd, path_)
	
	local ext = get_file_ext(decoded_path)	
	local req_cmd = ext and '/file' or (__HttpCallback[req_cmd] and decoded_path or '/file')
		
	if __HttpCallback[req_cmd] then
		co(function(thread)
			print('callback decoded_path:',decoded_path)
			xpcall(__HttpCallback[req_cmd], print_debug, req, decoded_path)
		end)
		return
	end
	
	if cmd and __HttpCallback[cmd] then
		co(function(thread)
			print('callback cmd:',cmd)
			xpcall(__HttpCallback[cmd], print_debug, req, path_)
		end)
		return
	end
end

function server_dispacher(cmd,msg,bev,code)	
	--Print(cmd);
	if cmd==CMD_EVENT_READ then	
		xpcall(cmd_event_read, print_debug,bev,msg)
	elseif cmd==CMD_EVENT_ERROR then
		xpcall(cmd_event_error, print_debug,bev,msg)		
	elseif cmd==CMD_EVENT_READ2 then	
		xpcall(cmd_event_read, print_debug,bev,msg)
	elseif cmd==CMD_EVENT_ERROR2 then
		xpcall(cmd_event_error, print_debug,bev,msg)		
	elseif cmd==CMD_EVENT_ACCEPT then
		xpcall(cmd_event_accept, print_debug,bev,msg)	
	elseif cmd==CMD_EVENT_TIMER then
		xpcall(cmd_event_timer, print_debug)	
	elseif cmd==CMD_EVENT_NOTIFY then
		xpcall(cmd_event_notify, print_debug,code,msg)
	elseif cmd==CMD_EVENT_HTTPGET   then
		xpcall(cmd_event_httpget, print_debug,code,msg)
	elseif cmd==CMD_EVENT_HTTPPOST then
		xpcall(cmd_event_httppost, print_debug,code,msg)
	elseif cmd==CMD_EVENT_HTTPREQ then
		xpcall(cmd_event_httpreq, print_debug,msg)
	elseif cmd == CMD_EVENT_REQUEST_ERROR then
		xpcall(cmd_event_httpreq_error, print_debug,msg,bev)
	elseif cmd == CMD_EVENT_CONNECTED then
		xpcall(cmd_event_connected, print_debug,bev,msg)
	end--]]
end


