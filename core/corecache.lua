
Cache = {}
function Cache:new(size)
	local o = { maxcache = size, size=0, cache={},keys={} }
	self.__index = self setmetatable(o, self)
	return o 
end

function Cache:Add(key, data,time)
	if not data or #data<=0 then
		return
	end

	self:Del(key)
	self.cache[key]={data=data, time=time}
	self.size = self.size+#data
	self.keys[#self.keys+1]=key
	while  self.size>self.maxcache and #self.keys>0 do
		self:Del(self.keys[1])
	end
end

function Cache:Query(s)
	local t = {}
	for i=1,#self.keys,1 do
		if string.find(self.keys[i], s) then
			t[#t+1]=self.keys[i]
		end
	end
	return t
end

function Cache:Get(key)
	return self.cache[key] and self.cache[key].data or nil	
end

function Cache:Del(key)
	local data = self:Get(key)
	if not data then
		return
	end	
	self.cache[key]=nil
	self.size = self.size-#data
	for i=1,#self.keys,1 do
		if self.keys[i]==key then
			table.remove(self.keys, i)
			break
		end
	end
end



