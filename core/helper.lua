local json=luaopen_cjson()
json.encode_sparse_array(true)


-- return true if os is windows
local function get_is_windows()
    return "\\" == package.config:sub(1,1)
end

local md5  = nil
local is_windows = get_is_windows()
if is_windows then
	md5  = require('core.md5')
else
	md5  = require('md5')
end
	
	
local coresocket = require('core.coresocket')



local function h2n(s)
	return tonumber(s,16); 
end

--LogInfo日志数据,GameID,UserID等
local LogInfo={}
local LogInfo_Tag = ''
local logfile=nil
function HelperSetLogContext(name, value)
	LogInfo[name]=value
	LogInfo_Tag=json.encode(LogInfo)
end

--日志接口
function HelperPrintLog(s)
	local ss = os.date()..' '..LogInfo_Tag..' '..s;
	Print(ss);
end

function FlushLogFile()
	if logfile then
		logfile:close()
		logfile=nil
	end
end

function PrintFlushLogFile()
	local time = os.time()
	if not __logtime or  time>__logtime then
		__logtime = time+5
		if logfile then
			logfile:close()
			logfile=nil
		end
	end	
end

function PrintFastLog(a,...)
	local time = os.time()
	local date = os.date('*t', time)
	local ss = os.date("%m-%d-%y %H:%M:%S ", os.time())	
	local t = {ss,LogInfo_Tag,'   ',a,...}
	t[#t+1]='\r\n'
	local s = table.concat(t)
	if not logfile then
		local dir = SERVER_DIRECTORY and SERVER_DIRECTORY or lfs.currentdir()
		logfile = io.open(dir..'/log/'..date.month..date.day..'.log', 'a+')
	end
	
	if logfile then
		
		if LOG_PRINT then print(s) end
		
		logfile:write(s)
		--logfile:close()
	end		
	
	if not __logtime or  time>__logtime then
		__logtime = time+5
		if logfile then
			logfile:close()
			logfile=nil
		end
	end	
end

local local_PrintFastLog=PrintFastLog

function print_debug()
	local s = debug.traceback()
	print(s)
	local_PrintFastLog(s)
end

--监视文件
local filemodify_callback = {}
function HelperMonitorFile(filename, fn, modify)
	filemodify_callback[filename]={fn=fn,modify=modify and modify or 0}
end

function get_file_ext(pathname)
	local _,__,file,ext=string.find(pathname,'(.+)%.(%w+)')
	return ext,file
end

--Update调用
local timer_monitor = gettime()
function HelperUpdateMonitorFile()
	local time_ = gettime()
	if time_>(timer_monitor+1000*1) then
		timer_monitor = time_
		for k,v in pairs(filemodify_callback) do
			local attr = lfs.attributes(k);			
			if attr and attr and attr.modification>v.modify then
				if v.modify>0 then
					v.modify=attr.modification
					HelperCoroutine(function()
						xpcall(v.fn, print_debug, k)
					end)
				else
					v.modify=attr.modification
				end				
			end
		end	
	end
end

--定时分钟触发,用于慢调用.
--fn返回true,结束循环触发.
local timercallback = {}
function HelperSetMinuteTimer(time,fn,cnt)
	timercallback[#timercallback+1]={fn=fn,cnt=cnt and cnt or 0,delta=time, time=gettime()+time}			
end

--Update调用
local timer_minute = gettime()
function HelperUpdateMinuteTimer()
	local time_ = gettime()
	if time_>(timer_minute+1000) then
		timer_minute = time_
		for i=1,#timercallback,1  do
			local time_callback = timercallback[i]
			if time_callback and time_>time_callback.time then				
				time_callback.time=time_callback.time+time_callback.delta
				HelperCoroutine(function()
						if time_callback.cnt<=1 then
							table.remove(timercallback, i)
						end
						time_callback.cnt=time_callback.cnt-1
						local ret = xpcall(time_callback.fn, print_debug)						
				end)
			end
		end
	end
end

--协程辅助接口
function HelperCoroutine(func,thread)
	local func_ = function(co)		
		xpcall(func,debug.traceback,co)		
		if thread then
			coroutine.resume(thread)
		end		
	end	
	
	local co = coroutine.create(func_);	
	local res,err = coroutine.resume(co,co);	
	return co
end

--协程辅助接口
function HelperCoroutineWithParam(func,thread,param1,param2)
	local func_ = function(co)		
		xpcall(func,debug.traceback,co,param1,param2)		
		if thread then
			coroutine.resume(thread)
		end		
	end	
	
	local co = coroutine.create(func_);	
	local res,err = coroutine.resume(co,co);	
	return co
end

function PrintFastLogWithCap(a,...)
	local time = os.time()
	local date = os.date('*t', time)
	local ss = os.date("%m-%d-%y %H:%M:%S ", os.time())	
	local t = {ss,LogInfo_Tag,...}
	t[#t+1]='\r\n'
	local s = table.concat(t,a)
	if not logfile then
		logfile = io.open('log/'..date.month..date.day..'.log', 'a+')
	end
	
	if logfile then
		logfile:write(s)
		--logfile:close()
	end		
	
	if not __logtime or  time>__logtime then
		__logtime = time+10
		if logfile then
			logfile:close()
			logfile=nil
		end
	end	
end

PrintLog=local_PrintFastLog


--协义解包
--网狐协议
function HelperPopMessage(msg)
	--PrintLog('PopMessage')	
	if msg:getMsgSize()<8 then
		return 2,'数据头未完成';
	end
	
	msg:setMode(SM_READ);
	msg:setMsgPos(0);
		
	local cbDataKind    =msg:uint8()    --数据类型
	local cbCheckCode=msg:uint8()	--效验字段
	local wPacketSize  =msg:uint16(); --数据大小				
	if wPacketSize>16834  then
		return  -1,"数据包长度,wPacketSize:"..wPacketSize
	end
	
	if wPacketSize<8 then
		return  -2,"数据包非法,wPacketSize:"..wPacketSize
	end
	
	if cbDataKind ~= 0x01 then
		return  -2,"数据包非法,cbDataKind:"..cbDataKind
	end
			
	if msg:getMsgSize()<wPacketSize then
		return  1,"数据包未完成,wPacketSize:"..wPacketSize..' getMsgSize:'..msg:getMsgSize()
	end
		
	local msg0 = CLXZMessage:new_local();	
	msg:removeHeadBuffer(4);--丢弃cbDataKind，cbCheckCode，wPacketSize	
	msg0:Write(msg:getMsgPtr(), wPacketSize-4);
	msg0:setData(msg:getData())
	msg0:MapKind(0, wPacketSize-4, true)  --MapKing解密
	msg:removeHeadBuffer(wPacketSize-4);
	
	--HelperPrintLog('pop msg size:'..wPacketSize..' msg0:'..msg0:getMsgSize())
	return 0,msg0;	
end

--协议头
--BYTE	cbDataKind;	//数据类型
--BYTE	cbCheckCode;	//效验字段
--WORD	wPacketSize;	//数据大小
function HelperPacketHead(msg,wMain,wSub)
	msg:uint8(0x01)
	msg:uint8(0x00)
	msg:uint16(0x00)
	msg:uint16(wMain)
	msg:uint16(wSub)
end

--协议尾
function HelperPacketTail(msg)
	local len = msg:getMsgSize()
	msg:setMsgPos(2)
	msg:uint16(len)
	msg:MapKind(4,len-4,false)
end

function HelperResetMessageHead(msg0,wMain,wSub)
	local msg=CLXZMessage:new_local()		
	msg:uint8(0x01)
	msg:uint8(0x00)
	msg:uint16(0x00)
	msg:Write(msg0:getMsgPtr(),msg0:getMsgSize())
	msg:setMsgPos(4)
	msg:uint16(wMain)
	msg:uint16(wSub)
	HelperPacketTail(msg)
	return msg
end

--json协议内容
function HelperPacketJSONCmd(wMain,wSub,obj)
	local str = json.encode(obj)
	local msg = CLXZMessage:new_local()
	HelperPacketHead(msg,wMain,wSub)
	msg:lstring(str,2)
	HelperPacketTail(msg)
	return msg
end

--发送接口
function Send2Client(userid, msg)
	if Users and Users[userid] and Users[userid].bev then
		local bev = Users[userid].bev
		if bev and Bevs and Bevs[bev] then
			EventServer:Send2Client(bev, msg)
		end
	end
end

--线程异步调用
function HelperNetExecute(threadid,co,funcname, ...)
	--PrintLog('HelperNetExecute:'..funcname)
	local arg = { ... }
	local t = {}
	t[#t+1]='return '
	t[#t+1]=funcname
	t[#t+1]='('	
	for i=1,#arg,1 do
		--PrintToConsole('arg:'..#arg..' :'..type(arg[i]))
		if type(arg[i])=='string' then
				t[#t+1]='\''
				t[#t+1]=escape_sql(arg[i], '\'')
				t[#t+1]='\''	
				--print(arg[i])
		elseif type(arg[i])=='table'  then
			t[#t+1]=table2string(arg[i])
		else
			if type(arg[i])=='boolean' then
				t[#t+1]= arg[i] and 'true' or 'false'
			else
				t[#t+1]=arg[i]
			end
		end
		
		if arg[i+1] then
			t[#t+1]=','
		end		
	end
	t[#t+1]=')'

	local code = table.concat(t)
	PrintLog('HelperNetExecute:'..code)
	local tasks=EventServer:ThreadExecute(threadid,co, code)	
	if(co~=nil) then
		PrintLog('yield')
		local ret,str=coroutine.yield();
		PrintLog('yield 2 ret:'..type(ret)..' str:'..type(str))
		return ret,str,tasks
	end
	return nil,nil,tasks
end

function HelperBin2Str(data)
	if(data==nil) then
		return "";
	end

	local msg = CLXZMessage:new_local()
	msg:Write(data)
	return msg:tohex()  	
end


function HelperStr2Bin(hexstr)	
--    local s = string.gsub(hexstr, "(%x%x)%c", function (n )  return h2n(n);  end)
 --   return s
 	if(hexstr==nil or type(hexstr)~='string') then
		return "";
	end
	
	local msg = CLXZMessage:new_local();
	for i=1,string.len(hexstr)-1,2 do
		local bb = string.sub(hexstr, i, i+1);
		msg:uint8(h2n(bb));
	end
	return msg:getMsgPtr();
end

function HelperGetFileContent(name)
	PrintLog('HelperGetFileContent:'..name)
	local file = io.open(name, 'r')
	if file then
		file:seek('set')
		local text = file:read('*a')
		file:close()
		return text
	end
	
	return '{}'
end

--获取状态锁
function HelperGetStateLock(name,locktime)
	--print('HelperGetStateLock:',name)
	if __state_locks[name] and os.clock()<__state_locks[name] then
		return true
	end	
	--print('HelperGetStateLock:',name, locktime)
	__state_locks[name]=os.clock()+locktime	
end

function tocode(value,c,d)
	c = c and c or '\''
	d = d and d or '\''
	if value then
		return  type(value)=='string' and c..value..d or value
	end
	return c..d
end

function UnionTable(a,b)
	for k,v in pairs(b) do
		a[k]=v
	end
	return a
end

function table2code(t)
	local to = tocode
	for i=1,#t,1 do
		t[i]=to(t[i])
	end
	return t
end

function table2string(data)	
	local t = {}
	t[#t+1]='{'
	for k,v in pairs(data) do
		print(k,v)
		if type(k)=='string' then
			t[#t+1]=tocode(k)
		else
			t[#t+1]='['
			t[#t+1]=k
			t[#t+1]=']'
		end
		t[#t+1]='='	
		
		if type(v)=='table' then									
			t[#t+1]=table2string(v)					
		else
			if type(v)=='string' then
				t[#t+1]=tocode(v, '[[', ']]')
			else				
				t[#t+1]=v				
			end			
		end
		
		t[#t+1]=','
	end
	if t[#t]==',' then
		t[#t]='}'
	else
		t[#t+1]='}'
	end		
	return table.concat(t)
end

function HelperNetSetGlobalVariable(threadid, varname)	
	local s = varname..'='..tocode(_G[varname])
	PrintLog('SetGlobalVariable:'..s)
	EventServer:ThreadExecute(threadid,nil, s)
end

function escape_sql(s,c)
	--print('escape_sql', s)
	c = c and c or '\''
	return (string.gsub(s, GetUtf8ByGBK(c),GetUtf8ByGBK('\\'..c)))
end

function ExecuteSQL(threadid,sql,wait)	
	return ExecuteSQLBatch(threadid,{sql},wait)	
end

function ExecuteSQLBatch(threadid,sqls,wait)	
	local thread = EventServer:GetLuaThread(threadid)
	if not thread then	
		local code = HelperGetFileContent(lfs.currentdir().."/core/coreodbc.lua")
		PrintLog('Init LuaThread:'..threadid, ' ', #code)
		local co = coroutine.running()
		EventServer:ThreadExecute(threadid,co, code)
		coroutine.yield()		
		
		local path = HelperBin2Str(package.cpath)
		PrintLog('path:'..path..' DB_IP:'..DB_IP)		
		HelperNetSetGlobalVariable(threadid, 'DB_IP')
		HelperNetSetGlobalVariable(threadid, 'DB_PWD')
		HelperNetSetGlobalVariable(threadid, 'DB_ACCOUNT')
		HelperNetSetGlobalVariable(threadid, 'DB_NAME')						
		HelperNetExecute(threadid,co,'SetPackageCPath', path)				
	end
		
	local time = gettime()
	--local_PrintFastLog('sql:',sql)	
	local co =  wait and coroutine.running() or nil
	local ret,return_str = HelperNetExecute(threadid, co,'ExecuteSQL', sqls)
	local_PrintFastLog('ExecuteSQLBatch, Time:'..(gettime()-time)..' threadid:'..threadid..' SQL:'..sqls[1]..'\r\n return_str:'..(return_str and return_str or 'nil'))
	
	if ret and return_str and wait and string.len(return_str)>=2  then
		--PrintLog('ExecuteSQL return_str:'..return_str)
		local json=luaopen_cjson();
		local return_t=json.decode(return_str)		
		--返回json数据
		return true,return_t		
	end		
		
	return ret,return_str	
end

function ExecuteURL(threadid,url,wait,binpost)	
	--local_PrintFastLog('ExecuteURL wait:', wait and 'true' or 'false', ' threadid:', threadid, ' url:',url)
	local thread = EventServer:GetLuaThread(threadid)
	if not thread then	
		local file = lfs.currentdir().."/core/corecurl.lua"
		local_PrintFastLog(file)
		local code = HelperGetFileContent(file)
		--local_PrintFastLog('code:', code)
		local_PrintFastLog('Init LuaThread:',threadid)
		local co = wait and coroutine.running() or nil
		EventServer:ThreadExecute(threadid,co, code)		
		if co then
			coroutine.yield()
		end
	end
		
	local co = wait and coroutine.running() or nil
	--local_PrintFastLog('ExecuteURL wait:', wait and ' true' or ' false', co and ' true' or ' false', ' threadid:', threadid, ' url:',url)
	local ret,return_str = HelperNetExecute(threadid, co,'ExecuteURL', HelperBin2Str(url),binpost)
	--print('ExecuteSQL threadid:'..threadid..' SQL:'..url..' return_str:'..(return_str and return_str or 'nil'))
	return ret,return_str	
end


--消息处理泵
--先存放列表中安顺序执行
function HelperMessagePump(key, func, param)
	--PrintLog('HelperMessagePump 1:'..key)
	if not __pump_msgs[key] then						
			__pump_msgs[key]={}
	end

	--加入用户消息列表
	param.func=func
	__pump_msgs[key][#__pump_msgs[key]+1]=param	
	--PrintLog('HelperMessagePump 2:'..key)
	
	--消息处理泵
	if not __pump_threads[key] or coroutine.status(__pump_threads[key])=='dead' then
		--PrintLog('HelperMessagePump 22:'..key)
		__pump_threads[key]=HelperCoroutine(function(thread)				
			while #__pump_msgs[key]>0 do
				--PrintLog('HelperMessagePump 3:'..key)
				local param = __pump_msgs[key][1]
				table.remove(__pump_msgs[key], 1)
				--PrintLog('HelperMessagePump 4:'..key)
				xpcall(param.func, print_debug, param)					
				--PrintLog('HelperMessagePump 5:'..key)
			end
			__pump_threads[key]=nil
		end)		
		--PrintLog('HelperMessagePump 55:'..key)
	end
end

--统计SQL返回
function GetSumOfSQLSelect(sql,name)
	local sum = 0							
	local ret,rows=ExecuteSQL(10,sql, true)
	if not ret or #rows==0 then
		return 0
	end
	
	local row = rows[1]
	if not row[name] then
		return 0
	end
		
	return tonumber(row[name])
end

--拷贝表
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  -- for
        return setmetatable(new_table, getmetatable(object))
    end  -- function _copy
    return _copy(object)
end  -- function deepcopy


--等待事件
--等待对象bev
--等待主命令
--等待副命令
--等待时间
function HelperWaitEvent(Timeout,thread,key1,key2,key3,key4)
	local t = {thread=thread,timeout=Timeout+gettime(),keys={key1,key2,key3,key4}}		
	for i=1,#t.keys,1 do
		WaitEvents[t.keys[i]]=t
	end	
	return coroutine.yield()
end

function HelperTriggerWaitEvent(key,param)
	if not WaitEvents[key] then
		return
	end
	
	local wait_event=WaitEvents[key]
	local thread = wait_event.thread
	wait_event.thread=nil		
	
	for i=1,#wait_event.keys,1 do
		WaitEvents[wait_event.keys[i]]=nil
	end
		
	if coroutine.status(thread)~='dead' then
		PrintLog('Trigger thread:'..key..' keys:'..(wait_event.keys and #wait_event.keys or 'nil'))
		coroutine.resume(thread,key,param)
	end
end

function HelperUpdateWaitEvent()
	local time =gettime()
		
	local t = {}
	local k_t = {}
	for k,v in pairs(WaitEvents) do		
		if v.timeout and  time>v.timeout and v.thread then			
			local thread = v.thread
			v.thread=nil
			PrintLog('resume k:'..k)
			--coroutine.resume(thread)
			t[#t+1]=thread
			k_t[#k_t+1]=k
		end
	end	
	
	for i=1,#k_t,1 do
		WaitEvents[k_t[i]]=nil
	end
	
	for i=1,#t,1 do
		coroutine.resume(t[i], 'timeout')
	end
end

--分页处理
function HelperPageProc(pagesize, rows, func, empty)
	PrintLog('HelperPageProc pagesize:'..pagesize..' rows:'..#rows)

	local t = {}
	for i=1,#rows,1 do			
		t[#t+1]=rows[i]
		if #t>=pagesize then
			func(t)
			t={}
		end
	end
	
	if #t>0 or empty then
		func(t)
	end
end

--转换成utf8
local iconv = require("iconv")
local cd = iconv.open('UTF-8','GBK')
function convert2utf8(s)
	local_PrintFastLog('convert2utf8:', #s, ' ',s)
	if not cd then return end
	local nstr, err = cd:iconv(s)
	if not err then
		local_PrintFastLog('convert2utf8 nstr:', #nstr, ' ',s)
		return nstr
	end
	
	local_PrintFastLog('convert2utf8:', err)
	return ''
end

local cd1 = iconv.open('GBK','UTF-8')
function convert2gbk(s)
	local_PrintFastLog('convert2gbk:', #s, ' ',s)
	if not cd then return end
	local nstr, err = cd1:iconv(s)
	if not err then
		local_PrintFastLog('convert2gbk nstr:', #nstr, ' ',s)
		return nstr
	end
	
	local_PrintFastLog('convert2gbk:', err)
	return ''
end

--服务器间发送请求
function send2gameserver(ip, port, api, data, id, not_needret)	
	local s = json.encode(data)	
	local ss=ZZBase64.encode(s)	
	local check_sign = md5.sumhexa(ss..SERVER_MAGIC_CODE)
	if not id then
		id = math.floor(math.random(1, 10))
	end
	local curlid=THREADID_CURL+id
	local url = 'http://'..ip..':'..port..'/'..api..'?'.. Table2URL({data=ss,sign=check_sign})
	local_PrintFastLog('send2gameserver ip:', ip, ' port:', port, ' api:', api, ' data:', s, ' url:', url)
	if not_needret then		
		return ExecuteURL(curlid, url)
	else
		return ExecuteURL(curlid, url, true)
	end
end

local function http_headers(request)
	  local headers = {}
	  if not request:match('.*HTTP/1%.1') then
		return headers
	  end
	  request = request:match('[^\r\n]+\r\n(.*)')
	  local empty_line
	  for line in request:gmatch('[^\r\n]*\r\n') do
		local name,val = line:match('([^%s]+)%s*:%s*([^\r\n]+)')
		if name and val then
		  name = name:lower()
		  if not name:match('sec%-websocket') then
			val = val:lower()
		  end
		  if not headers[name] then
			headers[name] = val
		  else
			headers[name] = headers[name]..','..val
		  end
		elseif line == '\r\n' then
		  empty_line = true
		else
		  assert(false,line..'('..#line..')')
		end
	  end
	  return headers,request:match('\r\n\r\n(.*)')
end

--连接websocket
function ConnectWebsocketServer(host, port, path)
	print('ConnectWebsocketServer host:', host, ' port:', port, ' path:', path)
	
	print('coresocket:',coresocket)
	local sock = coresocket.tcp()
	print('sock:',sock)
	local ok, err = sock:connect(host, port)
	print('ConnectWebsocketServer ok:', ok, err)
	
	local char =string.char
	local rand = math.random
	
    local bytes = char(rand(256) - 1, rand(256) - 1, rand(256) - 1,
                       rand(256) - 1, rand(256) - 1, rand(256) - 1,
                       rand(256) - 1, rand(256) - 1, rand(256) - 1,
                       rand(256) - 1, rand(256) - 1, rand(256) - 1,
                       rand(256) - 1, rand(256) - 1, rand(256) - 1,
                       rand(256) - 1)

    local key = ZZBase64.encode(bytes)
    local req = "GET " .. path .. " HTTP/1.1\r\nUpgrade: websocket\r\nHost: "
                .. host .. ":" .. port
                .. "\r\nSec-WebSocket-Key: " .. key
                .. (proto_header or "")
                .. "\r\nSec-WebSocket-Version: 13"
                .. (origin_header or "")
                .. "\r\nConnection: Upgrade\r\n\r\n"

	print('ConnectWebsocketServer send req:', req)
    local bytes, err = sock:send(req)
    if not bytes then
        return nil, "failed to send the handshake request: " .. err
    end

    local header_reader = sock:receive("\r\n\r\n")
    -- FIXME: check for too big response headers
    local header, err = http_headers(header_reader)
    if not header then
        return nil, "failed to receive response header: " .. err
    end	
	return sock	
end

function Send2WebSocket(req, s,not_log)
	if not req or not __requests[req] then
		return local_PrintFastLog('Send2WebSocket error:', s)
	end
	
	if not not_log then
		local_PrintFastLog('Send2WebSocket:',s)
	end
	
	--print('Send2WebSocket:', s)
	
	local msg = CLXZMessage:new_local()
	msg:SetWebSocketFrame(129, s)	
--	evhttp_add_header(req, "Connection", "keep-alive")	
	evhttp_send_raw(req, msg:getMsgPtr())
	msg:ReleaseMemory()
	--local_PrintFastLog('evhttp_send_raw')
end

function IsRequestStillOk(req)
	if not __requests[req] then
		return
	end	
	return true
end

function HttpRespone(req, func)
	if not __requests[req] then
		return
	end	
	func(req)	
end

function HttpReplySend(req, s, not_log)
	if not __requests[req] then
		return
	end

	if not not_log then
		--local_PrintFastLog('HttpReplySend:',s)
	end	
	--evhttp_clear_headers(req)
    evhttp_add_header(req, "Access-Control-Allow-Origin", "*");
    evhttp_add_header(req, "Access-Control-Allow-Headers", "X-Requested-With");
    evhttp_add_header(req, "Access-Control-Allow-Methods","PUT,POST,GET,DELETE,OPTIONS");
    evhttp_add_header(req, "X-Powered-By",' 3.2.1')
	evhttp_add_header(req, "Content-Type", "application/json;charset=utf-8");		
	evhttp_send_reply(req,200,'ok', s)
end

function HelperCloseWebSocket(req)
	local_PrintFastLog('HelperCloseWebSocket')	
	if logic_offline then
		logic_offline(req)
	end
	
	UsersMgr:OnReqDie(req)	
	if __requests[req] then
		__requests[req]=nil
		__WebMessageBuffer[req]=nil
		EventServer:CloseReq(req)
		evhttp_add_header(req, 'Connection', 'close')
		evhttp_send_reply(req,200,'ok', [[{type='close',data='ok'}]])		
		local_PrintFastLog('CloseReq ok')
	end

end

function HelperGetWebSocketFrame(req)	
	if not __requests[req] then
		return
	end

	 local s = evhttp_get_input_buffers(req)	
	 
	 if s and #s>0 then
		 if not  __WebMessageBuffer[req] then
			 __WebMessageBuffer[req]= s
		else
			 __WebMessageBuffer[req]= __WebMessageBuffer[req]..s
		 end
	 end
	 
	 local msg = CLXZMessage:new_local()
	 local ret,out_len = msg:GetWebSocketFrame(__WebMessageBuffer[req])	 
	 if ret==129 then		
		__WebMessageBuffer[req]=string.sub(out_len, #__WebMessageBuffer[req])
		return json.decode(msg:getMsgPtr())
	elseif ret==ERROR_FRAME or ret==CLOSING_FRAME then
		HelperCloseWebSocket(req)
		--Send2WebSocket(req, 'close')
		--EventServer:CloseReq(req)
	 end
end

function int64op(a,op,b)
	assert(a)
	assert(b)
	return evhttp_int64_op(a,op,b)
end

--监听文件修改
function MonitorAndDoFile(name,not_immediately)
	print('MonitorAndDoFile')
	if not not_immediately then
		local_PrintFastLog('Execute file1:',name)
		xpcall(dofile, print_debug, name)
		--dofile(name)
	end

	HelperMonitorFile(name, function(name)
		local_PrintFastLog('Execute file2:',name)
		xpcall(dofile, print_debug, name)
	end)
end

function HelperDecodeURI(s)
	if s == nil then return; end
    return string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)    
end

function HelperEncodeURI(s)
	if s == nil then return; end
    s=string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function Table2URL(data)
	local str_url = ''
	for k,v in pairs(data) do
		if str_url~='' then
			str_url=str_url..'&'
		end
		
		if type(v)=="number" then
			str_url = str_url ..k.."=".. v		
		elseif type(v)=="string" then
			str_url = str_url ..k.."=".. HelperEncodeURI(v)
		elseif type(v)=="table" then
			str_url = str_url ..k.."=".. HelperEncodeURI(json.encode(v))
		end				
	end	
	return str_url
end

--
local service_host = nil;
function Send2Nginx(api,data,thread,print_)

	local str_url = Table2URL(data)	
	if print_ then
		PrintLog(service_host..api.."?"..str_url);
	end
	
	EventServer:SendHttpGet(service_host..api..'?'..str_url,thread);	
end

function generate_sign(openid)
	local a = 'wx'..openid..ACCOUNT_MAGIC_CODE
	local_PrintFastLog('generate_sign:', a)
	local sign = md5.sumhexa(a)
	return sign
end

--检查数据是否正确
function check_parameter(parameter)
	local sign = parameter.sign	
	parameter.data=string.gsub(parameter.data, " ", "+")	
	local check_sign = md5.sumhexa(parameter.data..SERVER_MAGIC_CODE)
	if check_sign~=sign then
		local_PrintFastLog('check_parameter sign:', sign, ' check_sign:', check_sign)		 
		return nil, s
	end	
	return true
end

--加密消息
function PacketClientWebSocketFrame(api, data)
	local s = json.encode(data)	
	local t = {type=api,data=data}
	local ss = json.encode(t)
	--if api=='game_error' then
	--	print('PacketClientWebSocketFrame:', ss)
	--end
	return ss
end

--发送消息(websocket)
function Send2ClientWebsocket(req, api, data, not_log)
	local s = PacketClientWebSocketFrame(api, data)
	Send2WebSocket(req, s,not_log)
end

--效验并解释
function ParserServerParameter(parameter)
	if not check_parameter(parameter) then
		return
	end
	return json.decode(ZZBase64.decode(parameter.data))	
end

--获取当前时间字符串
function GetNowDateString(time)
	local date = os.date('%Y-%m-%d %H:%M:%S', time and time or os.time())
	return date
end

function GetTodayDateString()
	local date = os.date('%Y-%m-%d', os.time())
	return date
end

--删除
function array_remove(arr, key, value)
	for i=1,#arr,1 do
		local a=arr[i]
		if a[key]==value then
			table.remove(arr, i)
			break
		end
	end
end

--统计
function array_sum(arr, key)
	local sum=0
	for i=1,#arr,1 do
		local a=arr[i]
		sum=sum+a[key]	
	end
	return sum
end

function array_for_each(arr, fn)
	for i=1,#arr,1 do
		fn(arr[i], i)		
	end
end

function array_fill(arr, value)
	for i=1,#arr,1 do
		arr[i]=value		
	end
end

--查找
function array_find(arr, key, value)
	for i=1,#arr,1 do
		local a=arr[i]
		if a[key]==value then
			return a,i
		end
	end
end

function array_find1(arr, value)
	for i=1,#arr,1 do
		local a=arr[i]
		if a==value then
			return a,i
		end
	end
end

--浅拷贝
function array_copy(arr)
	local t={}
	for i=1,#arr,1 do
		t[#t+1]=arr[i]		
	end
	return t
end

--过滤属性
function array_query(arr, key)
	local t = {}
	for i=1,#arr,1 do
		local a=arr[i]
		t[#t+1]=a[key]
	end
	return t
end

function GetUtf8ByGBK(s)
	if not s then
		return ''
	end
	
	if tonumber(s) then
		return s
	end
	
	if not _ChangeUserScoreReason then
		_ChangeUserScoreReason = {}
	end

	if _ChangeUserScoreReason[s] then
		return _ChangeUserScoreReason[s]
	end
	_ChangeUserScoreReason[s]=convert2utf8(s)
	return _ChangeUserScoreReason[s]
end

PrintLog = PrintFastLog

