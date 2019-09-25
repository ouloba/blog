local json=luaopen_cjson()
_socket_t = {}
local _bevs_t = {}

function _socket_t.tcp (ssl)		
	local ret_skt = {__index=ret_skt,ssl=ssl}
	ret_skt.settimeout = function (self,val)	end 	
	ret_skt.setoption=function(self) end
				
	ret_skt.connect = function (self,host, port)
				PrintFastLog('connect', json.encode(host))
				PrintFastLog('connect host:',host and tostring(host) or ' nil',' port:',port and tostring(port) or 'nil')
				self.bev = EventServer:Connect (host, port,self.ssl)	
				if not self.bev or  self.bev==null then
					return
				end				
				
				PrintFastLog('connect host:',host,' port:',port, ' ok!')
				_bevs_t[self.bev]=self						
				self.thread=coroutine.running()		
				coroutine.yield()				
				return self.bev, (self.bev and 'ok' or 'fail')
			end 
			
	ret_skt.send= function(self, data)
					local len = string.len(data)
					Print('send:'..len)		
					if not self.bev then return end					
					local ret,val=EventServer:SendData2Client(self.bev, data)
					return len
				end
				
	ret_skt.recv_frame=function(self)				
		if not self.bev or  self.bev==null then
			return
		end				
		
		local msg = EventServer:GetInputBufferMsg(self.bev)		
		if msg:getMsgSize()==0 then
			self.thread=coroutine.running()		
			coroutine.yield()	
		end
		
		local ret = 0				
		--print('self.bev:', self.bev, msg:getMsgSize())
		while self.bev and msg:getMsgSize()>0 do
			local msg_ = CLXZMessage:new_local()		
			ret,out_len = msg_:GetWebSocketFrame(msg:getMsgPtr())			
			local n = msg_:getMsgSize()
			if ret ==INCOMPLETE_TEXT_FRAME or
			   ret== INCOMPLETE_BINARY_FRAME or
			   ret== INCOMPLETE_FRAME or			   
			   n==0 
			then
				self.thread=coroutine.running()
				--print('recv_frame wait')
				coroutine.yield()	
				ret = 0
			else				
				--print('recv_frame ok:', out_len)
				msg:removeHeadBuffer(out_len)	
				if msg:getMsgSize()==0 then
					msg:ReleaseMemory()
				end
				return ret, msg_		
			end					
		end		
		return ret,nil
	end
					
	ret_skt.receive=function(self, n)		
		if not self.bev or  self.bev==null then
			return
		end				
	
		print('receive', self.bev)
		local msg = EventServer:GetInputBufferMsg(self.bev)
		--Print('recieve:'..n..' bev:'..(self.bev and 'not nil' or 'is nil')..' msg:'..(msg and 'not nil' or 'is nil'))
		print('receive 1:', msg:getMsgSize(), ' n:', n)
		
		local s = n
		while self.bev~=null do
			if type(n)=='number' and msg:getMsgSize()>=n  then
				s=n
				break
			elseif n=='*l' then
				local  p1,p2=string.find(msg:getMsgPtr(), '\n')
				if p1 then
					s=p2
					break
				end
			else
				local  p1,p2=string.find(msg:getMsgPtr(), n)
				if p1 then
					s=p2
					break
				end				
			end		
			self.thread=coroutine.running()
			coroutine.yield()						
		end
				
		local data=string.sub(msg:getMsgPtr(), 1, s)
		--PrintFastLog('receive 2:', msg:getMsgSize(), ' n:', s, ' data->',data, ' trace:', debug.traceback())
		msg:removeHeadBuffer(s)					
		if msg:getMsgSize()==0 then
			msg:ReleaseMemory()
		end		
		 return data
	end

	ret_skt.close = function (self)
			if not  self.bev then
				return
			end
			
			Print('Close')
			_bevs_t[self.bev]=nil				
			local bev = self.bev
			self.bev=nil
			if self.thread then
				local thread = self.thread
				self.thread=nil
				coroutine.resume(thread)
			end
			return EventServer:CloseClient(bev)
		--	end			   					
	end			

	ret_skt.shutdown=function(self)
		self:close()
	end
	
	ret_skt.settimeout=function(self,timeout)
	end
	
	setmetatable(ret_skt, ret_skt)
	return ret_skt
end

function is_coresocket(bev)
	local o = _bevs_t[bev]
	return o~=nil
end

local function socket_resume(bev)
	local o = _bevs_t[bev]
	if not o then
		return
	end
	
	if o.thread and coroutine.status(o.thread)=='suspended' then
		local thread = o.thread
		o.thread=nil
		coroutine.resume(thread)
	end	
	return true
end

function _socket_t.on_connected(bev)
	return socket_resume(bev)
end

function _socket_t.on_read(bev)
	return socket_resume(bev)
end

function _socket_t.on_closed(bev)	
	local o = _bevs_t[bev]
	if not o then
		return
	end	
	o:close()
end

return _socket_t