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

--����id
UuidsDocMgr=Uuids:new('uuid_document.cfg',1,8000000, 'lobby', true)
UuidsCommentMgr=Uuids:new('uuid_comment.cfg',1,8000000, 'lobby', true)



--����
function OnServerUpdate()
	--���Ӷ�ʱ��
	HelperUpdateMinuteTimer()
	
	--�ļ������
	HelperUpdateMonitorFile()
	
	--Э��	
	HelperUpdateWaitEvent()
end
