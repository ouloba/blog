

--时间协程
__timer_thread=nil

--消息泵协程
__pump_threads={}

--泵消息列表
__pump_msgs={}

--协程等待
WaitEvents = {}

--状态锁+时效
--key, lock name
--val, over time
__state_locks={}

--html模板目录
__html_path = './template/'

--http请求
__requests = {}

--Http请求
__HttpCallback={}

--websocket请求
__WebCallback={}
__WebMessageBuffer={}

--游戏记录目录
RECORDS_DIRECTORY = 'd:\\gamerecords\\'

--服务器密钥
SERVER_MAGIC_CODE='@#$$#$#@@#@##$$'
SERVER_WEB_CODE='$%&^%$#Y$%$%^%&'
__server_list = {}

THREADID_CURL=100
THREADID_SQL   =20000
ACCOUNT_MAGIC_CODE='!@#$@!@#@#@@@@'

APPIDS= {}
APPIDS[100]="wx6c0d183f87bb9a61" --三公
APPIDS[140]="wxffb1e226bfbf997e" --柳州麻将
APPIDS[141]="wxffb1e226bfbf997e" --柳州麻将
SECRETS={}
SECRETS[100]='0ecc764f6a3764f0cf2ab9bd8e7c4fd1' 
SECRETS[140]='27dddbffe0c65dba993a203fadb8f416' 
SECRETS[141]='27dddbffe0c65dba993a203fadb8f416' 
--APPID= "wxa0e029f902e8639d"
--SECRET='e4b3891698e7a0071ff1507c0406391d'

APPIDS[10]="wx4b010a2d5ee5d9f6" --无双
SECRETS[10]='41dcc6a6a94453d0d7d3fa36e2bbf96a' 


ERROR_FRAME = 0xFF00
INCOMPLETE_FRAME = 0xFE00

OPENING_FRAME = 0x3300
CLOSING_FRAME = 0x3400

INCOMPLETE_TEXT_FRAME = 0x01
INCOMPLETE_BINARY_FRAME = 0x02

TEXT_FRAME = 0x81
BINARY_FRAME = 0x82

PING_FRAME = 0x19
PONG_FRAME = 0x1A


