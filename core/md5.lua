----------------------------------------------------------------------------
-- $Id: md5.lua,v 1.4 2006/08/21 19:24:21 carregal Exp $
----------------------------------------------------------------------------

local core = package.loadlib("md5.dll","luaopen_md5_core")()

local string = string or require"string"


----------------------------------------------------------------------------
-- @param k String with original message.
-- @return String with the md5 hash value converted to hexadecimal digits

function core.sumhexa (k)
	k = core.sum(k)  
	local msg = CLXZMessage:new_local()
	msg:Write(k)
	return msg:tohex()  	
end

return core
