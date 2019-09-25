local json=luaopen_cjson()
local current = lfs.currentdir()
SERVER_DIRECTORY=current
lfs.chdir(current.."/..")
package.path =lfs.currentdir().."/?.lua;"..package.path..';'..current..'/?.lua'
print(package.path)
print( lfs.currentdir())

dofile( lfs.currentdir()..'/core/coremain.lua')
dofile( lfs.currentdir()..'/model/model_main.lua')
MonitorAndDoFile(current..'/logic/data.lua')
MonitorAndDoFile(current..'/logic/logic.lua')

--订单id
UuidsDocMgr=Uuids:new('uuid_document.cfg',1,8000000, 'lobby', true)
UuidsCommentMgr=Uuids:new('uuid_comment.cfg',1,8000000, 'lobby', true)



--更新
function OnServerUpdate()
	--分钟定时器
	HelperUpdateMinuteTimer()
	
	--文件监控器
	HelperUpdateMonitorFile()
	
	--协程	
	HelperUpdateWaitEvent()
end
