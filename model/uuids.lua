
Uuids = {}
function Uuids:new(cfgname,id, size, name,server)	
	--load
	if server then
		local cfg = ILXZCoreCfg:new_local()
		if cfg:load(lfs.currentdir()..cfgname) then
			local nowid=cfg:GetInt('nowid'..name,nil, -1)
			local endid =cfg:GetInt('endid'..name,nil, -1)	
			id = nowid
			size = endid-nowid
		end
	end
	print(cfgname..' new id:', id, ' size:', size)
	local o = {nowid=id,endid=id+size,server=server,name=name,cfg=cfgname}
	self.__index = self setmetatable(o, self)
	return o 
end

function Uuids:NewID(size)
	size = size and size or 1

	local s = self:Size()
	--print('Uuids:NewID size:', size, ' s:', s, ' nowid:', self.nowid, ' endid:', self.endid)
	if s==0 then
		if not self.callback then
			return
		end
		
		local nowid,endid=self.callback()
		self.nowid=nowid
		self.endid=endid		
		s = self:Size()		
	end
	
	if size>s then
		size=s
	end
	
	local id = self.nowid
	self.nowid=self.nowid+(size and size or 1)
	if self.server then
		local cfg = ILXZCoreCfg:new_local()
		cfg:SetInt('nowid'..self.name, -1, self.nowid)
		cfg:SetInt('endid'..self.name, -1, self.endid)
		local name = lfs.currentdir()..self.cfg
		print(name)
		cfg:save(name)			
	end
	return id,size
end

function Uuids:Size()
	return self.endid-self.nowid
end

function Uuids:SetCallback(callback)
	self.callback=callback
end

