

Users = {}
function Users:new(size)
	local o = {summarys={},users={},req={},userid={},size=size,count=0}
	self.__index = self setmetatable(o, self)
	return o 
end

function Users:SetSummary(info)
	local t = {}
	t.userid = info.userid
	t.nickname = info.nickname
	t.faceid = info.faceid
	t.headurl=info.headurl
	t.sex = info.sex	
	t.isbot=info.isbot
	self.summarys[info.userid]=t	
end

function Users:GetSummary(userid)
	return self.summarys[userid]
end

function Users:GetSummaryList(userids)
	local t = {}
	for i=1,#userids,1 do
		if   self.summarys[userids[i]] then
			t[#t+1]= self.summarys[userids[i]]
		end
	end	
	return t
end

function Users:Add(info)
	if not self.users[info.userid] then
		self.count=self.count+1
	end
	info.__time = os.time()
	self.users[info.userid]=info
	self:SetSummary(info)
end

function Users:GetUser(userid)
	return self.users[userid]
end

function Users:Del(userid)
	if self.users[userid] then
		self.count=self.count-1
	end
	self.users[userid]=nil
end

function Users:SetDirty(userid)
	if self.users[userid] then
		self.users[userid].__time=os.time()
	end
end

function Users:SetReq(userid, req)
	if __requests[req] then
		self.req[userid]=req
		self.userid[req]=userid
	end
end

function Users:ForEach(fn)
	for k,v in pairs(self.req) do
		local user = self.users[k]
		if user then
			fn(user,v)
		end
	end
end

function Users:GetReq(userid)
	return self.req[userid]
end

function Users:GetUserID(req)
	return self.userid[req]
end

function Users:OnReqDie(req)
	local id = self.userid[req]
	self.userid[req]=nil
	if id then
		self.req[id]=nil
	end
end

function Users:Tick(time)
	if self.count<self.size then
		return
	end
	
	for k,v in pairs(self.users) do
		if v.__time<time then
			self.users[k]=nil
		end
	end	
end


