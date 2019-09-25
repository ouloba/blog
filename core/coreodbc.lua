local json=luaopen_cjson()
print("***********************************************odbc********************************************")
DB_PWD='123456'
DB_NAME = "fanpaiji"
DB_ACCOUNT='sa'
--package.cpath = "./?.so"
print("***********************************************will load mysql********************************************")
local luasql = require "luasql.mysql" 	
print("luasql", luasql, '*************lua********************')
local env = luasql.mysql()                 --创建环境对象
PrintLog=PrintToConsole
dofile('core/ZZBase64.lua')
local conn = nil
local iconv = require("iconv")
--local cd = iconv.open('UCS-2', 'UTF-8')
PrintToConsole('cd:'..(cd and 'ok' or 'nil'))

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

function  SetPackageCPath(binstr)
	package.cpath=HelperStr2Bin(binstr)
	PrintToConsole('SetPackageCPath:'..package.cpath..' IP:'..DB_IP);
end

function  SetDBIP(binstr)
	DB_IP=HelperStr2Bin(binstr)
	PrintToConsole('DB_IP:'..DB_IP);
end

function SetDBPassword(binstr)
	--123taweyer456789
	DB_PWD = HelperStr2Bin(binstr)
end

local function Log(s)
	local date = os.date('*t', time)
	local file = io.open(lfs.currentdir()..'/log/'..date.month..date.day..'_db.log', 'a+')
	if file then
		local ss = os.date("%m-%d-%y %H:%M:%S ", os.time())	
		PrintToConsole(ss)
		file:write(ss..' coreodbc error:'..s..'\r\n')
		file:close()
	end
end

--set SQL_SAFE_UPDATES=0
--"SET NAMES UTF8"	
function ExecuteSQL(sqls)
	PrintToConsole('coreodbc ExecuteSQL**************11111111111*******************')
	if not conn then
		conn,err = env:connect(DB_NAME, DB_ACCOUNT, DB_PWD,DB_IP,3306); --连接数据库
		if not conn then
			local err = 'cannot connect to DB_NAME:'..DB_NAME..' DB_IP:'..DB_IP..' DB_PWD:'..DB_PWD..' err:'..err
			Log(err)
			CurrentTask:SetUserResult(err)
			return ''
		end
		conn:execute("SET NAMES utf8mb4")
	end
	
	PrintToConsole('coreodbc ExecuteSQL**************22222222222222222222*******************')
	--PrintToConsole('Execute2')		
	local cursor, errorString
	for i=1,#sqls,1 do
		cursor, errorString = conn:execute(sqls[i])	
		if errorString then
			PrintToConsole("errorString**************************"..errorString)
			Log(errorString)
			CurrentTask:SetUserResult('Execute errorString:'..errorString)
			conn:close()
			conn=nil
			return
		end
	end
		
	PrintToConsole('coreodbc ExecuteSQL**************3333333333333333333*******************')
	local return_t={}
	--PrintToConsole('type(cursor):'..type(cursor))
	if type(cursor)== 'userdata' then
		local row = cursor:fetch({}, "a");
		while row do	
			--PrintToConsole('Executeaaa5')
			return_t[#return_t+1]=row			
			row = cursor:fetch({}, "a");
		end		
		 cursor:close()
	else
		return_t ={cursor}
		--PrintToConsole('coredb error:'..cursor)
		
	end
	
	--conn:close();
	
	--PrintToConsole('Execute5')
	local str = json.encode(return_t)
	return str
end
