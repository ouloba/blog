PrintLog = PrintToConsole
local json=luaopen_cjson()

--htmlÄ£°åÄ¿Â¼
__html_path = './template/'
local template = require "html.template"	
  
local function h2n(s)
	return tonumber(s,16); 
end

function HelperStr2Bin(hexstr)	
--    local s = string.gsub(hexstr, "(%x%x)%c", function (n )  return h2n(n);  end)
 --   return s
 	if(hexstr==nil) then
		return "";
	end
	
	local msg = CLXZMessage:new_local();
	for i=1,string.len(hexstr)-1,2 do
		local bb = string.sub(hexstr, i, i+1);
		msg:uint8(h2n(bb));
	end
	return msg:getMsgPtr();
end

function WebRender(view,binstr)
	local str = HelperStr2Bin(binstr)
	local data = json.decode(str)
	--²âÊÔ´úÂë	
	local text=template.render(view, data)		
	return text
end
