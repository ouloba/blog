Game = {}
function Game:new(info)
	local o = {info=info,users={},count=0}
	self.__index = self setmetatable(o, self)
	return o 
end

function Game:Info() 
	return self.info
end

function Game:SetInfo(info)
	self.info=info
end

function Game:ID()
	return self.info.gameid
end

function Game:GetUserCount()
	return self.count
end

function Game:Users()
	return self.users
end

function Game:UserList()
	return self.users	
end

function Game:AddUser(info)	
	local user,idx = self:GetUser(info.userid)
	if user then
		self.users[idx]=info
		return
	end
	
	self.count=self.count+1
	self.users[#self.users+1]=info
end

function Game:GetUser(userid)
	for i=1,#self.users,1 do
		local user = self.users[i]
		if user.userid ==userid then
			return user, i
		end
	end
end

function Game:DelUser(userid)
	local user,idx = self:GetUser(userid)
	if user then
		table.remove(self.users,idx)
		self.count=self.count-1
		return user
	end		
end

function Game:GetUserByChairID(chairid)
	for i=1,#self.users, 1 do
		local user = self.users[i]
		if user.chairid==chairid then
			return user
		end
	end	
end

function Game:GetEmptyChairID()
	for i=1,self.info.playerlimit,1 do
		if not self:GetUserByChairID(i) then
			return i
		end
	end		
	return -1
end


Games = {}
function Games:new()
	local o = {games={},count=0 }
	self.__index = self setmetatable(o, self)
	return o 
end

function Games:Get(gameid)
	return self.games[gameid]
end

function Games:Add(info)
	local game = Game:new(info)
	if not self.games[game:ID()] then
		self.count=self.count+1
	end
	self.games[game:ID()]=game
end

function Games:Del(gameid)
	if self.games[gameid] then
		self.count=self.count-1
	end
	self.games[gameid]=nil
end

function Games:Count()
 return self.count
end

function Games:List()
	return self.games
end

function Games:ForEach(fn)
	for k,v in pairs(self.games) do
		fn(k,v)
	end
end

function Games:GenerateID()
	math.randomseed(os.time())
	while true 
	do
		local id =600000+math.mod(math.random(1,1000000),399999)
		if not self.games[id] then
			return id
		end
	end
end

function Games:GetUserGameID(userid)
	for k,game in pairs(self.games) do
		if game:GetUser(userid) then
			return k
		end
	end
	return 0
end

--不同游戏数据
GamesExt={}
function GamesExt:new()
	local o = {games={},count=0 }
	self.__index = self setmetatable(o, self)
	return o 
end

function GamesExt:Get(gameid,create)
	if not self.games[gameid] and create then
		self.games[gameid]=create
	end
	return self.games[gameid]
end

function GamesExt:Add(gameid, info)	
	if not self.games[gameid] then
		self.count=self.count+1
	end
	self.games[gameid]=info
end

function GamesExt:Del(gameid)
	if self.games[gameid] then
		self.count=self.count-1
	end
	self.games[gameid]=nil
end

function GamesExt:Count()
	return self.count
end

