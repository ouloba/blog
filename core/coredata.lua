

--ʱ��Э��
__timer_thread=nil

--��Ϣ��Э��
__pump_threads={}

--����Ϣ�б�
__pump_msgs={}

--Э�̵ȴ�
WaitEvents = {}

--״̬��+ʱЧ
--key, lock name
--val, over time
__state_locks={}

--htmlģ��Ŀ¼
__html_path = './template/'

--http����
__requests = {}

--Http����
__HttpCallback={}

--websocket����
__WebCallback={}
__WebMessageBuffer={}

--��Ϸ��¼Ŀ¼
RECORDS_DIRECTORY = 'd:\\gamerecords\\'

--��������Կ
SERVER_MAGIC_CODE='@#$$#$#@@#@##$$'
SERVER_WEB_CODE='$%&^%$#Y$%$%^%&'
__server_list = {}

THREADID_CURL=100
THREADID_SQL   =20000
ACCOUNT_MAGIC_CODE='!@#$@!@#@#@@@@'

APPIDS= {}
APPIDS[100]="wx6c0d183f87bb9a61" --����
APPIDS[140]="wxffb1e226bfbf997e" --�����齫
APPIDS[141]="wxffb1e226bfbf997e" --�����齫
SECRETS={}
SECRETS[100]='0ecc764f6a3764f0cf2ab9bd8e7c4fd1' 
SECRETS[140]='27dddbffe0c65dba993a203fadb8f416' 
SECRETS[141]='27dddbffe0c65dba993a203fadb8f416' 
--APPID= "wxa0e029f902e8639d"
--SECRET='e4b3891698e7a0071ff1507c0406391d'

APPIDS[10]="wx4b010a2d5ee5d9f6" --��˫
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


