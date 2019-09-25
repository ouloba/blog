
local PrintLog = print

-- return true if os is windows
local function get_is_windows()
    return "\\" == package.config:sub(1,1)
end

local is_windows = get_is_windows()
  
local function h2n(s)
	return tonumber(s,16); 
end

local function HelperStr2Bin(hexstr)	
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

	PrintLog('TestCURL')
	local ffi = require 'ffi'
	local url = [[https://www.baidu.com]]
	ffi.cdef [[
		int curl_version();
		void *curl_easy_init();
		int curl_easy_setopt(void *curl, int option, ...); // here was the error!
		int curl_easy_perform(void *curl);
		void curl_easy_cleanup(void *curl);
		size_t curlreceive_data(void *, size_t , size_t , void*);
		int curl_global_init(long flags );
		void curl_global_cleanup(void);
	]]
		
	PrintLog('TestCURL222')
	msg = CLXZMessage:new()
	print('msg:', msg, msg:topointer())

	CURL_GLOBAL_WIN32=2
	CURLOPT_WRITEDATA=10001
	CURLOPT_URL = 10002
	CURLOPT_WRITEFUNCTION = 20011
	CURLOPT_VERBOSE = 41
	CURLOPT_POST=10024
	CURLOPT_GET=10080
	CURLOPT_POSTFIELDS=10015
	CURLOPT_SSL_VERIFYPEER=64
	CURLOPT_SSL_VERIFYHOST=81
	
	if is_windows then
		libcurl = ffi.load("libcurl.dll")
	else
		libcurl = ffi.load("libcurl.so")
	end
	
	PrintLog('TestCURL4')
	PrintLog("cURL Version: "..libcurl.curl_version(), ffi.C.curlreceive_data)

local time = 0
local curl=nil
local function init_curl()
	if curl then				
		if os.time()<time  then
			return
		end
		libcurl.curl_easy_cleanup(curl)
		libcurl.curl_global_cleanup()		
		curl=nil
	end
	
	time = os.time()+60
	libcurl.curl_global_init(CURL_GLOBAL_WIN32)
	curl = libcurl.curl_easy_init()
	if curl then		
		libcurl.curl_easy_setopt(curl, CURLOPT_VERBOSE, 1)		
		libcurl.curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0)
		libcurl.curl_easy_setopt(curl,  CURLOPT_SSL_VERIFYHOST, 0)
		libcurl.curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, ffi.C.curlreceive_data)
		libcurl.curl_easy_setopt(curl, CURLOPT_WRITEDATA, msg:topointer())		
	end
end

function ExecuteURL(binstr,binpost)
	init_curl()

	local url_ = HelperStr2Bin(binstr)
	PrintLog("**************************************Core ExecuteURL: "..url_)
	if curl then		
		libcurl.curl_easy_setopt(curl, CURLOPT_URL, url_)	

		if binpost then
			local post  = HelperStr2Bin(binpost)
			--print('post:', post)
			--libcurl.curl_easy_setopt(curl, CURLOPT_POST, 1)		
			libcurl.curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post)		
			--print('post ok')
		else
			--print('get')
			libcurl.curl_easy_setopt(curl, CURLOPT_GET, 1)		
		end
		local result = libcurl.curl_easy_perform(curl)		
		--PrintLog('***********************Core ExecuteURL result:', result and result or 'nil')
		local s = msg:getMsgPtr()
		msg:removeHeadBuffer(msg:getMsgSize())
		msg:setMode(SM_WRITE)
		msg:setMsgPos(0)
		if msg:getMsgSize()==0 then
			msg:ReleaseMemory()
		end
		PrintLog('***********************Core ExecuteURL s:', s and s or 'nil')
		return s
	end	
	return 'error'
end
	
