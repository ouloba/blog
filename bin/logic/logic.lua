local json=luaopen_cjson()
local template = require "html.template"

-- return true if os is windows
local function get_is_windows()
    return "\\" == package.config:sub(1,1)
end

local md5  = nil
local is_windows = get_is_windows()
if is_windows then
	md5  = require('core.md5')
else
	md5  = require('md5')
end
	
local content_type_table = {
  ["txt"]= "text/plain", 
  ["c"]=  "text/plain", 
  ["h"]=  "text/plain", 
  ["html"]=  "text/html", 
 ["htm"]=  "text/html",
 ["css"]=  "text/css" ,
 ["gif"]=  "image/gif" , 
 ["jpg"]= "image/jpg" , 
 ["jpeg"]=  "image/jpeg", 
 ["png"]=  "image/png" , 
 ["pdf"]=  "application/pdf" , 
 ["ps"]=  "application/postscript" 
}

local get_file_ext = get_file_ext 

--猜测文件类型
function guess_content_type(pathname)
	local ext = get_file_ext(pathname)
	PrintFastLogWithCap(' ',"pathname:",pathname, 'ext:', ext, 'type:', ext and content_type_table[ext] or 'ext:nil')
	return content_type_table[ext] or "text/plain"
end

--加载文件
local function load_static_file(filename)
	local file = io.open(filename, 'rb')
	if file then
		local text = file:read('*a')
		file:close()
		return text
	end
end

local cachefile = Cache:new(1024*1024*10)

--发送文件
local function reply_send_file(req, filename,cache)
	 if not IsRequestStillOk(req) then
		return
	 end
	 
	local text = cachefile:Get(filename)
	
	--已缓存
	if text and #text>0 then
		PrintFastLog('reply_send_file filename:',filename, ' ', #text)
		evhttp_add_header(req, 'Content-Type',  guess_content_type(filename))
		
		if cache then
			evhttp_add_header(req, 'Cache-Control',  'max-age='..cache)
		end		
		
		evhttp_send_reply(req,200,'ok', text)	
		return
	end
	
	

	--加载
	local text = load_static_file(filename)
	if text and #text>0 then
		PrintFastLog('reply_send_file filename:',filename, ' ', #text)
		cachefile:Add(filename, text,gettime())
		
		--监听文件改动
		HelperMonitorFile(filename, function()
			local text_ = load_static_file(filename)
			cachefile:Add(filename, text_,gettime())
		end, 
		gettime())
		
		if cache then
			evhttp_add_header(req, 'Cache-Control',  'max-age='..cache)
		end		

		evhttp_add_header(req, 'Content-Type',  guess_content_type(filename))
		evhttp_send_reply(req,200,'ok', text)		
		return
	end
	
	--文件不存在
	evhttp_add_header(req, 'Content-Type', 'text/css')
	evhttp_send_reply(req,404,'file not found', '文件:'..filename..'不存在')	
end

--跳转
function http_redirect(req, url)
	evhttp_add_header(req, 'Location', url)
	evhttp_send_reply(req,302,'file not found', '跳转')		
end

--注册
local function http_html_register(req)
	print('http_html_register*****************注册**************************')
	local context = {title=convert2utf8('注册'),articles={{},{},{},{}} }
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/register.html", context, "no-cache" ) 
	evhttp_add_header(req, 'Content-Type',  "text/html")
	evhttp_send_reply(req,200,'ok', res)	
end

--重新加载热门文章
function load_hot_docs()
	if	HotDocs and
		#HotDocs~=0 and
		load_hot_docs_time and
		load_hot_docs_time>os.time()
	then		
		return HotDocs
	end
	
	local id = math.random(1, 100)
	load_hot_docs_time = os.time()+60*10
	
	local sql = [[SELECT a.`id`,
    a.`post_title`,
    a.`post_status`,
    a.`category`,
    a.`post_desc`,
	a.`read_count`,
	a.`comment_count`
	FROM `blogs`.`documents` as a  where a.post_status=0 order by a.read_count desc limit 0,20;]]
	local ret,rows=ExecuteSQLBatch(THREADID_SQL+math.mod(id,10), {sql},true)		
	if not ret then
		print('http_html_index ************************')
		return
	end	
	
	HotDocs=rows	
	return HotDocs
end

--刷新
local function http_refresh_cache(req)
	load_bookmark_docs_time=0
	load_hot_docs_time=0
	local res = 'ok'
	evhttp_add_header(req, 'Content-Type',  "text/json")		
	evhttp_send_reply(req,200,'ok', res)		
end

--重新加载收藏网站
function  load_bookmarks()
	if	BookmarksDocs and
		#BookmarksDocs~=0 and
		load_bookmark_docs_time and
		load_bookmark_docs_time>os.time()
	then		
		return BookmarksDocs
	end
	
	local id = math.random(1, 100)
	load_bookmark_docs_time = os.time()+60*10
	
	local sql = [[SELECT * FROM blogs.bookmarks order by `order` desc;]]
	local ret,rows=ExecuteSQLBatch(THREADID_SQL+math.mod(id,10), {sql},true)		
	if not ret then
		print('http_html_index ************************')
		return
	end	
	
	BookmarksDocs=rows	
	return BookmarksDocs
end

--登录
local function http_html_login(req)
	print('http_html_login')
	local context = {title=convert2utf8('登录'),articles={{},{},{},{}} }
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/login.html", context, "no-cache" ) 
	evhttp_add_header(req, 'Content-Type',  "text/html")
	evhttp_send_reply(req,200,'ok', res)	
end

--首页
local function http_html_index(req)
	print('http_html_index')
	local header = evhttp_get_input_headers(req)
	local ip = evhttp_get_remote_host(req)
	local id = evhttp_hash(ip)

	local parameter = evhttp_parse_query(req)	
	local page = tonumber(parameter.page and parameter.page or 1)	
	page = (page<=0) and 1 or page
	
	local tab = parameter.tab	
	local and_str = tab and ' and a.category=\''..tab..'\'' or ''
	
	local hots = load_hot_docs()
	local bookmarks = load_bookmarks()
		
	local sql = [[SELECT count(1) as cnt FROM blogs.documents as a where a.post_status=0]]..and_str..[[ ;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id,10), sql,true)		
	if not ret then
		print('http_html_index ************************')
		return
	end	
		
	local pages=math.floor(tonumber(rows[1].cnt)+9/10)
	local offset = (page-1)*10
	local sql = [[SELECT a.`id`,
    b.nickname as post_author,
    a.`post_date`,    
    a.`post_title`,
    a.`post_status`,
    a.`category`,
    a.`post_desc`,
	a.`read_count`,
	a.`comment_count`
	FROM `blogs`.`documents` as a,`blogs`.`accounts` as b  where a.post_status=0 and a.post_author=b.userid]]..and_str..[[ order by a.post_date desc limit ]]..offset..[[,10;]]
	local ret,rows=ExecuteSQLBatch(THREADID_SQL+math.mod(id,10), {sql},true)		
	if not ret then
		print('http_html_index ************************')
		return
	end	

	
	local tabs = {
	{name=GetUtf8ByGBK('全部'), url='index.html' },
	{name=GetUtf8ByGBK('EventServer'), url='index.html?tab='.. GetUtf8ByGBK('EventServer') },
	{name=GetUtf8ByGBK('Python'), url='index.html?tab=Python' },
	{name=GetUtf8ByGBK('AI'), url='index.html?tab=AI' },
	{name=GetUtf8ByGBK('Game'), url='index.html?tab='.. GetUtf8ByGBK('Game') },	
	{name=GetUtf8ByGBK('写文章'), url='edit.html'}}
		
	local context = {title=convert2utf8('首页'), page=page,pages=pages,count=QUERY_COUNT,tabs=tabs,bookmarks=bookmarks,hots=hots,tab=tab and tab or GetUtf8ByGBK('全部'),articles=rows}	
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/index.html", context, "no-cache" ) 
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")	
		evhttp_send_reply(req,200,'ok', res)			
	end)
	print('********************Cookie', json.encode(header), header.cookie)	
end



function HttpResponeError(req, errcode, errmsg)	
	HttpRespone(req, function(req)
		local res = json.encode({errcode=errcode, errmsg=errmsg})
		print('HttpResponeError******************************************************',res)
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)		
	end)
end

--激活账号
local function http_blog_active(req)
	print('http_blog_active******************************')
	local parameter = evhttp_parse_query(req)	
	local token = md5.sumhexa(parameter.account..parameter.code..MAGIC_CODE)
	if parameter.token~=token then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('激活码无效'))		
	end	
	
	local id = math.random(evhttp_hash(parameter.account), 10)
	local sql = [[SELECT * FROM blogs.accounts where account=']]..escape_sql(parameter.account) ..[[';]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)	
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	if #rows==0 then
		HttpResponeError(req, 1000, GetUtf8ByGBK('账号未注册'))		
		return
	end	
	
	local sql=[[update blogs.accounts set state=1 where account=']].. escape_sql(parameter.account)..[[';]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)	
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end	
	
	http_redirect(req, '/login.html')
end

--注册
local function http_blog_register(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	local ip = evhttp_get_remote_host(req)
	local uri = evhttp_request_get_uri(req)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_blog_login******************************************************', json.encode(obj))
	
	local header = evhttp_get_input_headers(req)
	local host = header['Host']
	
	local id = math.random(evhttp_hash(obj.account), 10)
	local sql = [[SELECT * FROM blogs.accounts where account=']]..escape_sql(obj.account) ..[[';]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)	
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	if #rows>0 then
		HttpResponeError(req, 1000, GetUtf8ByGBK('该账号已注册'))		
		return
	end	
	
	local code = math.random(10000, 100000)
	local token = md5.sumhexa(obj.account..code..MAGIC_CODE)
	
	HelperCoroutine(function(thread)
		local link = [[href="https://]]..host..[[/blog/active?code=]]..code..[[&token=]]..token..[[&account=]]..obj.account..[["]]
		print('http_blog_login link=', link)
		local context = {link=link,code=code, token=token,nickname=obj.nickname,account=obj.account,ip=ip, date=GetNowDateString(os.time())}	
		local template = require "html.template"
		local res = template.render(SERVER_DIRECTORY.."/asset/html/activecode.html", context, "no-cache" ) 
		
		--需要审核
		if REGISTER_NEED_VERIFY then
			mailto("<15001179252@163.com>", ADMIN_MAIL , '注册账号申请', res)
					
			--'<'..obj.account..'>'
			local context = {link=link,code=code, token=token,nickname=obj.nickname,account=obj.account,ip=ip, date=GetNowDateString(os.time())}	
			local template = require "html.template"
			local res = template.render(SERVER_DIRECTORY.."/asset/html/regnote.html", context, "no-cache" ) 
			mailto("<15001179252@163.com>", '<'..obj.account..'>' , '注册账号请求已发出', res)
			print('http_blog_register', json.encode(obj))	
		else
			mailto("<15001179252@163.com>",  '<'..obj.account..'>'  , '注册账号激活', res)
		end
	end)

	--
	local value = {
		escape_sql(obj.account),
		escape_sql(obj.nickname),
		GetNowDateString(os.time()),
		ip,
		GetNowDateString(os.time()),
		ip,
		0,
		0,
		'',
		escape_sql(obj.password),
		token,
		'',
		'',
		0,
		'',
		0,
		tonumber(obj.sex and obj.sex or 0),
		0,
		0,
		0,
		0,
		0}
	local sql = [[INSERT INTO `blogs`.`accounts`
					(`account`,
					`nickname`,
					`reg_date`,
					`reg_ip`,
					`login_date`,
					`login_ip`,
					`score`,
					`insurescore`,
					`insurepassword`,
					`loginpassword`,
					`dynamicpassword`,
					`phonepassword`,
					`spreadids`,
					`spreadid`,
					`headurl`,
					`faceid`,
					`sex`,
					`isbot`,
					`right`,
					`scorepoint`,
					`forbid`,
					`state`)
					VALUES
					(]].. table.concat(table2code(value), ',') ..[[);
					]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
						
	HttpResponeError(req, 0, GetUtf8ByGBK('激活邮件已发出,请打开邮件激活'))		
end

--登录
local function http_blog_login(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_blog_login******************************************************', json.encode(obj))
	
	local sql = [[SELECT * FROM blogs.accounts where account=']].. escape_sql(obj.account)  ..[[';]]
	local ret,rows=ExecuteSQL(THREADID_SQL, sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	if #rows==0 then		
		print('http_blog_modify******************************************************',res)
		HttpResponeError(req, 1000, GetUtf8ByGBK('账号未注册'))
		return
	end
	
	if rows[1].loginpassword ~= obj.password then
		HttpResponeError(req, 1001, GetUtf8ByGBK('密码错误'))		
		return
	end	
	
	if rows[1].state=='0' then
		HttpResponeError(req, 1002, GetUtf8ByGBK('账号未激活'))		
		return
	end
		
	HttpRespone(req, function(req)		
		local time = os.time()+60*60*24
		local token = md5.sumhexa(rows[1].userid..MAGIC_CODE..time..rows[1].right)
		local cookies = {userid=rows[1].userid, logintime=time, token=token, sex=rows[1].sex, right=rows[1].right} --'userid='..rows[1].userid..';'..'logintime='..time..';token='..token
		local base64 = ZZBase64.encode(json.encode(cookies))
		local res = json.encode({errcode=0, errmsg=GetUtf8ByGBK('登录成功'), cookie='login='..base64})
		print('http_blog_login******************************************************',res)
		evhttp_add_header(req, 'Content-Type',  "text/json")		
		evhttp_send_reply(req,200,'ok', res)		
	end)	
end

local function http_blog_delete(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_blog_delete******************************************************', json.encode(obj))
	
	local id = tonumber(obj.id)
	
	local sql = [[
	delete from `blogs`.`documents` where id=]]..obj.id..[[
	]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_blog_deletexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	local res = json.encode({id=id, msg=convert2utf8('删除成功')})
	print('http_blog_delete******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)			
	end)
end

--修改
local function http_blog_modify(req)	
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_blog_modify******************************************************', json.encode(obj))
	--local template = require "html.template"
	--local res = template.render(SERVER_DIRECTORY.."/asset/html/article.html", context, "no-cache" ) 
	--print('http_blog_post******************************************************', res)
	local id = tonumber(obj.id)
	
	local ret,userid=is_logined(req)
	if not ret then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('没有修改权限'))
	end
	
	local sql = [[
	update `blogs`.`documents` set `post_title`=]]..tocode(escape_sql(obj.title))..[[, `post_desc`=]].. tocode(escape_square_brackets(obj.desc))..[[, `post_content`=]].. tocode(escape_square_brackets(obj.doc))..[[,  `category`=]].. tocode(escape_sql(obj.category)) ..[[
	where id=]]..obj.id..[[
	]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	local res = json.encode({id=id, errcode=0, msg=convert2utf8('提交成功')})
	print('http_blog_modify******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)			
	end)	
end

function escape_square_brackets(s)
	local c = '([%[%]\'])'
	return (string.gsub(s, c, function(d) return '\\'..d end))
end

	
--提交
local function http_blog_post(req)	
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	
	local ret,userid=is_logined(req)
	if not ret then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('没有提交权限'))
	end
	
		
	local id = UuidsDocMgr:NewID()
	local value = {
		id,
		userid,
		GetNowDateString(os.time()),
		escape_square_brackets(obj.title),
		escape_square_brackets(obj.desc),
		escape_square_brackets(obj.doc),
		0,
		escape_sql(obj.category),
	}
	
	local sql = [[
	INSERT INTO `blogs`.`documents`
	(`id`,
	`post_author`,
	`post_date`,
	`post_title`,
	`post_desc`,
	`post_content`,	
	`post_status`,
	`category`)
	VALUES
	(]].. table.concat(table2code(value), ',')..[[);
	]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	
	
	local res = json.encode({id=id,errcode=0, msg=convert2utf8('提交成功')})
	print('http_blog_post******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)			
	end)	
end

--赞评论
local function http_comment_like(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	local ip = evhttp_get_remote_host(req)
	obj.id = tonumber(obj.id)

	local ret,userid,user = is_logined(req)
	if not ret then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('没有登录，无法点赞'))
	end
	
	if UserResponeComments[userid..obj.id] then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('你已评论'))
	end
		
	local sql = [[update `blogs`.`comments`	set `like`=`like`+1 where id=]]..obj.id..[[;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(obj.id, 10), sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	UserResponeComments[userid..obj.id]='like'
	
	local res = json.encode({id=obj.id,errcode=0, msg=convert2utf8('点赞成功')})
	print('http_blog_post******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)			
	end)	
end

--反对评论
local function http_comment_refuse(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	local ip = evhttp_get_remote_host(req)
	obj.id = tonumber(obj.id)

	local ret,userid,user = is_logined(req)
	if not ret then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('没有登录，无法点赞'))
	end
	
	if UserResponeComments[userid..obj.id] then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('你已评论'))
	end
		
	local sql = [[update `blogs`.`comments`	set `refuse`=`refuse`+1 where id=]]..obj.id..[[;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(obj.id, 10), sql,true)		
	if not ret then
		print('http_blog_postxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', rows)
		return
	end
	
	UserResponeComments[userid..obj.id]='refuse'
	local res = json.encode({id=obj.id,errcode=0, msg=convert2utf8('点赞成功')})
	print('http_blog_post******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)			
	end)	
	
end


--提交评论
local function http_comment_post(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	local ip = evhttp_get_remote_host(req)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_comment_post******************************************************', json.encode(obj))
	local ret,userid,user = is_logined(req)
	if not ret then
		return HttpResponeError(req, 1000, GetUtf8ByGBK('没有登录，无法评论'))
	end
	
	if tonumber(user.right)<=0 then
		print('user.right',user.right)
		return HttpResponeError(req, 1001, GetUtf8ByGBK('权限不够，无法评论'))
	end
	
	if #obj.content==0 then
		return HttpResponeError(req, 1001, GetUtf8ByGBK('评论内容不可为空')) 
	end
	
	local id = UuidsCommentMgr:NewID()	
	local value ={
		id,
		userid,
		tonumber(obj.id),
		escape_sql(obj.content),
		tonumber(obj.parentid),
		GetNowDateString(os.time()),
		0,
		0,
		ip}
	
	local sql = [[INSERT INTO `blogs`.`comments`	
						(`id`,
						`userid`,
						`docid`,
						`content`,
						`parentid`,
						`logtime`,
						`like`,
						`refuse`,
						`ip`)
						VALUES
						(]].. table.concat(table2code(value), ',')..[[);
						]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_comment_delete', rows)
		return
	end				

	local res = json.encode({id=id,errcode=0, errmsg=convert2utf8('评论成功')})
	print('http_comment_delete******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/json")
		evhttp_send_reply(req,200,'ok', res)		
	end)
	
	local sql = [[update `blogs`.`documents` set comment_count=(select count(1) from `blogs`.`comments`	where docid=]]..tonumber(obj.id)..[[ ) where id=]]..tonumber(obj.id)..[[ ]]
	ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql)
end


--获取评论列表
local function http_comment_list(req)
	local buffer = evhttp_get_input_buffers(req)	
	local obj = json.decode(buffer)
	--local context = {title=obj.title, doc=obj.doc}
	print('http_comment_list******************************************************', json.encode(obj))
	local id = tonumber(obj.id)
	
	local ret,userid,user = is_logined(req)	
	
	local sql = [[SELECT a.`id`,		
		a.`userid`,
		b.`nickname`,
		b.`sex`,
		a.`docid`,
		a.`content`,
		a.`parentid`,
		a.`logtime`,
		a.`like`,
		a.`refuse`,
	    a.`ip`
	FROM `blogs`.`comments` as a,`blogs`.`accounts` as b  where  a.userid=b.userid and a.docid=]]..id..[[ order by a.logtime asc;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret then
		print('http_comment_list ************************')
		return
	end	

	local context = {comments=rows,sex=user and user.sex or 0}	
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/comment.html", context, "no-cache" ) 	
	print('http_comment_list******************************************************',res)
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")
		evhttp_send_reply(req,200,'ok', res)			
	end)		
end

--修改页
local function http_html_modify(req)
	print('http_html_modify***************')
	local parameter = evhttp_parse_query(req)	
	local id = tonumber(parameter.id)	
	if not is_logined(req) then
		return http_redirect(req, '/login.html')
	end
		
	local sql = [[SELECT * FROM blogs.documents where id=]]..id..[[;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret or #rows==0 then
		print('http_html_modify ************************', id)
		return
	end	
	
	local categorys = {		
	{name=GetUtf8ByGBK('EventServer')},
	{name=GetUtf8ByGBK('Python')},
	{name=GetUtf8ByGBK('AI')},
	{name=GetUtf8ByGBK('Game') }}
	
	local context = rows[1]
	context.title=convert2utf8('修改文章')
	context.docid=rows[1].id
	context.categorys=categorys
	--context.post_content=function() return tocode(string.gsub(rows[1].post_content,'\'', '\\\''), '\'') end
	
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/modify.html", context, "no-cache" ) 
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")
		evhttp_send_reply(req,200,'ok', res)			
	end)
end

--是否有权限
function is_has_right(right, name)
	right = right and right or '0'
	if not UserRights[right] then
		return
	end
	
	for i=1,#UserRights[right],1 do
		if UserRights[right][i]==name then
			return true
		end
	end	
end

--是否已登录
function is_logined(req)
	local header = evhttp_get_input_headers(req)
	if not header.Cookie then
		return
	end
	
	local cookies = {}
	string.gsub(header.Cookie, "%s*(%w+)%s*=%s*(%w+=*);?", function (key,val)  
		print('key',key, 'val',val)
		cookies[key]=val 
	end)
	
	print('is_logined', header.Cookie, json.encode(cookies))
	if not cookies or not cookies.login then
		print('is_logined 1**************************1')
		return
	end
	
	local obj = json.decode(ZZBase64.decode(cookies.login))
	if not obj then
		print('is_logined 2**************************2')
		return
	end
	
	if  os.time()>obj.logintime or 
        not obj.right	
   then
		print('is_logined userid:', obj.userid,  ' cookies.token:', obj.token)
		return
	end
	
	local token = md5.sumhexa(obj.userid..MAGIC_CODE..obj.logintime..obj.right)
	if obj.token~=token then
		PrintFastLog('is_logined token:', token, ' obj.token:', obj.token)
		return
	end
	
	return true, obj.userid,obj
end

--编辑
local function http_html_edit(req)
	print('http_html_edit')		
	if not is_logined(req) then
		return http_redirect(req, '/login.html')
	end
	
	local categorys = {	
	{name=GetUtf8ByGBK('EventServer')},
	{name=GetUtf8ByGBK('Python')},
	{name=GetUtf8ByGBK('AI')},
	{name=GetUtf8ByGBK('Game') }}
	
	local context = {}
	context.title=convert2utf8('编辑文章')
	context.categorys=categorys
	
	local template = require "html.template"
	local res = template.render(SERVER_DIRECTORY.."/asset/html/edit.html", context, "no-cache" ) 
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")
		evhttp_send_reply(req,200,'ok', res)			
	end)
	print('********************Cookie', json.encode(header), header.Cookie)	
end

--文章
local function http_html_article(req)
	print('http_html_article')
	local parameter = evhttp_parse_query(req)	
	local headers = evhttp_get_input_headers(req)
	print('headers', json.encode(headers))
		
	local id = tonumber(parameter.id)	
	
	local sql = [[SELECT * FROM blogs.documents where id=]]..id..[[;]]
	local ret,rows=ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql,true)		
	if not ret or #rows==0 then
		print('http_html_article ************************', id)
		return
	end	
	
	local tabs = {
	{name=GetUtf8ByGBK('首页'), url='index.html?'},
	{name=GetUtf8ByGBK('修改'), url='modify.html?id='..id},
	{name=GetUtf8ByGBK('删除'), url='javascript:void(0)', onclick='javascript:delete_doc()'}}
	
	local context = {title=rows[1].post_title, tabs=tabs, tab=tab, docid=id, doc=rows[1].post_content,category=rows[1].category}
	local res = template.render(SERVER_DIRECTORY.."/asset/html/article.html", context, "no-cache" ) 
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")
		evhttp_send_reply(req,200,'ok', res)			
	end)		
	
	local sql = [[update blogs.documents set read_count=read_count+1 where id=]]..id..[[;]]
	ExecuteSQL(THREADID_SQL+math.mod(id, 10), sql)
end

--安装iOS app
local function http_html_plist(req)
	print('http_html_plist')
	local context = {appname=convert2utf8('龙城麻将'),applogourl='www.baidu.com',ipaurl='https://app.tsgl.me/uploads/20190505/2d591986cac02401f8d4a15fbb5ba4ae.ipa',appbundle='com.lae.world', appversion='1.0.1'}
	--local res = template.render(SERVER_DIRECTORY.."/template/plist.xml", context, "no-cache" ) 
	local out = [[<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>{ipaurl}</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>display-image</string>
                    <key>needs-shine</key>
                    <true/>
                    <key>url</key>
                    <string>{applogourl}</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>{appbundle}</string>
                <key>bundle-version</key>
                <string>{appversion}</string>
                <key>kind</key>
                <string>software</string>
                <key>subtitle</key>
                <string>App Subtitle</string>
                <key>title</key>
                <string>{appname}</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>]]
	
	for k,v in pairs(context) do
		local var = v
		out = string.gsub(out, '{'..k..'}', v)
	end
	
	HttpRespone(req, function()
		evhttp_add_header(req, 'Content-Type',  "text/html")
		evhttp_send_reply(req,200,'ok', out)			
	end)	
end

--发送邮件
--from="<15001179252@163.com>" 
--to=<liaoxizhou@lua-web.com>
function mailto(from, to, title, utf8text)
		local smtp = require("resty.smtp")
		local mime = require("resty.smtp.mime")
		local ltn12 = require("resty.smtp.ltn12")
		print('http_test&*************************************************http_test2222')
		-- ...
		-- Suppose your mail data in table `args` and default settings
		-- in table `config.mail`
		-- ...		
		--发送列表
		rcpts = {	
				to
		}

		local mesgt = {
			headers= {
				subject= mime.ew(title, nil,
							 { charset= "gbk" }),
				["content-transfer-encoding"]= "BASE64",
				["content-type"]= "text/html; charset='utf8'",				
				to = to, --收件人                
			},
			body= mime.b64(utf8text)
		}
		
		print('http_test&*************************************************http_tes3333')
		local ssl_fn = function() 
			local  proxy_create = require('core.coresocket').tcp
			return proxy_create(true)
		end
		
		local ret, err = smtp.send {
			from= from ,
			rcpt= rcpts,
			user           = MAIL_ACCOUNT,
			password = MAIL_PASSWORD,					
			source= smtp.message(mesgt),
			server       = MAIL_SERVER,
			domain       = MAIL_SERVER,
			port = MAIL_SERVER_PORT,
			create=MAIL_SSL and ssl_fn or require('core.coresocket').tcp
		}
end

--测试接口
local function http_test(req)
		print('http_test&*************************************************http_test111')
	
end

--百度读取配置
local function ueditor_controller_config(req, parameter)
	PrintFastLog('***************************ueditor_controller_config**********************')
	print(json.encode(parameter))
	local filename = SERVER_DIRECTORY.."/asset/config.json"
	PrintFastLog('ueditor_controller_config', filename)
	local file = io.open(filename, "r")
	if file then
		local data = file:read('*a')
		print('data', data)
		file:close()
		local obj = json.decode(data)
		HttpReplySend(req, json.encode(obj))		
	end	
end

local function get_boundary(header)
    local m = string.match(header, ";%s*boundary=\"([^\"]+)\"")
    if m then
        return m
    end
    return string.match(header, ";%s*boundary=([^\",;]+)")
end

local function parser_form_data(buffer, boundary)
	print('parser_form_data', boundary)	
	local offset = 1
	local formdata_t = {}
	while true do
		local s,e= string.find(buffer,'--'..boundary, offset)
		if not s then
			print('parser_form_data 1', s, e)
			return
		end
		
		local s1,e1= string.find(buffer, '\r\n\r\n', e+1)
		if not s1 then
			print('parser_form_data 2', s1, e1, string.sub(buffer, e+1, #buffer), buffer)
			return
		end
		
		local s2,e2= string.find(buffer, '--'..boundary, e1+1)
		if not s2 then
			print('parser_form_data 3', s2, e2, string.sub(buffer, s1, e1))
			return
		end
				
		--content
		local t = {header=string.sub(buffer, e+1, s1-1), content=string.sub(buffer, e1+1, s2-1)}				
		formdata_t[#formdata_t+1]=t
		print('section',t.header, t.content)
		
		local ss= string.sub(buffer, e2+1, e2+2)
		if ss=='--' then
			print('parser_form_data 4', s2, e2)
			break
		end
		
		offset=s2
	end
	
	print('formdata_t', #formdata_t)
	return formdata_t
end

local function find_formdata_section(formdata_t, name)
	local s = [[name="]]..name..[["]]
	print('find_formdata_section', s)
	for i=1,#formdata_t,1 do
		local t = formdata_t[i]
		local k = string.find(t.header, s)		
		if k then
			return t
		end
	end
end	

--百度上传图片
local function ueditor_controller_uploadimage(req, parameter)
	PrintFastLog('***************************ueditor_controller_uplaodimage**********************')	
	local header = evhttp_get_input_headers(req)
	local buffer = evhttp_get_input_buffers(req)
	local ip = evhttp_get_remote_host(req)
	
	print(json.encode(parameter))
	
	local boundary = get_boundary(header['Content-Type'])
	print('header****************:', json.encode(header), boundary)
	--PrintFastLog('api_upload_file filename:', filename, ' ip:', evhttp_get_remote_host(req), ' content-type:', header['Content-Type'])
	
	local formdata_t = parser_form_data(buffer, boundary)
	if not formdata_t then
		return HttpReplySend(req, json.encode({errcode=1000,userid=userid, filename=filename, errmsg=convert2utf8("数据错误")}))		
	end
	
	PrintFastLog('buffer************* length:', #buffer)	
	--for i=1,#formdata_t,1 do
		local section_file = find_formdata_section(formdata_t, 'upfile')
		if not section_file then
			return HttpReplySend(req, json.encode({errcode=1001,userid=userid, filename=filename, errmsg=convert2utf8("未找到文件名")}))		
		end
		
		local filename = string.match(section_file.header, '; filename="(.+)"')	
		print('filename:', filename)
		if not filename then
			return HttpReplySend(req, json.encode({errcode=1003, userid=userid, filename=filename, errmsg=convert2utf8("非法文件名")}))		
		end
		
		local ext,shortname = get_file_ext(filename)
		print('ext', ext, shortname)
		if not string.find('png,jpg,rar', ext) then
			return HttpReplySend(req, json.encode({errcode=1004,userid=userid, filename=filename, errmsg=convert2utf8("非法文件名")}))		
		end
			
		local pathname = SERVER_DIRECTORY..'/asset/upload/'..filename
		PrintFastLog('api_upload_file pathname:', pathname, ip)
		local file = io.open(pathname, 'wb+')	
		if file then	
			file:write( section_file.content)
			file:close()			
		end
	--end
	
	HttpReplySend(req, json.encode({state="SUCCESS", url=filename,title=filename,original=filename, error=convert2utf8("上传成功")}))			
end

function dir_img_files(path,prefix)
	print('dir_img_files', path, prefix)
	local files = {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then            
            files[#files+1]=prefix..'/'..file           
         end
     end
	 return files
end

--百度抓取图片
local function ueditor_controller_listimage(req, parameter)
	PrintFastLog('***************************ueditor_controller_uplaodscrawl**********************')
	print(json.encode(parameter))
	local header = evhttp_get_input_headers(req)
	local uri = header['Host']
	local files = dir_img_files(SERVER_DIRECTORY..'/asset/upload/','https://'..uri..'/upload')
	local list = {}
	local start = tonumber(parameter.start)
	local size = tonumber(parameter.size)
	for i=start+1, start+size, 1 do
		if not files[i] then break end
		list[#list+1]={url=files[i]}
		print('file:', files[i])
	end	
	HttpReplySend(req, json.encode({state="SUCCESS", list=list,start=start,size=size,total=#files}))			
end

--百度获取图片列表
local function ueditor_controller_uploadscrawl(req, parameter)
	PrintFastLog('***************************ueditor_controller_listimage**********************')
	print(json.encode(parameter))
end

--百度ueditor
local ueditor_callback={}
ueditor_callback['config']=ueditor_controller_config
ueditor_callback['uploadimage']=ueditor_controller_uploadimage
ueditor_callback['uploadscrawl']=ueditor_controller_uploadscrawl
ueditor_callback['listimage']=ueditor_controller_listimage
local function ueditor_controller(req)	
	local parameter = evhttp_parse_query(req)	
	print('***************************ueditor_controller**********************')
	print(json.encode(parameter))	
	local headers = evhttp_get_input_headers(req)
	print('headers', json.encode(headers))
	
	if ueditor_callback[parameter.action] then
		xpcall(ueditor_callback[parameter.action], print_debug, req, parameter)
	end
end



--需要处理模板
local htmlcallback={}
htmlcallback['/register.html']=http_html_register
htmlcallback['/login.html']=http_html_login
htmlcallback['/index.html']=http_html_index
htmlcallback['/article.html']=http_html_article
htmlcallback['/plist.html']=http_html_plist
htmlcallback['/edit.html']=http_html_edit
htmlcallback['/modify.html']=http_html_modify
htmlcallback['/ueditor/controller.html']=ueditor_controller

--处理html模板
local function http_html_callback(req, filename)	
	print('http_html_callback*************** file:', filename)
	
	--需要单独处理
	if htmlcallback[filename] then
		return htmlcallback[filename](req)
	end
	
	--直接返回静态页面
	reply_send_file(req,SERVER_DIRECTORY..'/asset'..filename)
end

--请求文件处理
local function http_file(req,filename)
	print('http_file', filename)
	
	--不可以有'..'符号,拒绝访问其他目录
	if string.find(filename, '%.%.') then
		filename='/error.html'
	end
	
	--默认页面
	if not filename or filename=='/' then
		filename='/index.html'
	end
	
	--html需要渲染
	local ext = get_file_ext(filename)
	if ext=='html' then
		QUERY_COUNT=QUERY_COUNT+1
		return http_html_callback(req, filename)
	end
	
	--其他问题
	local _,__,prefix = string.find(filename,  '([/].-)/')
	local file = table.concat({SERVER_DIRECTORY, '/asset', filename})
	PrintFastLog(' http_file:',filename, ' abs:', file, prefix)
	reply_send_file(req, file, CachePrefixs[prefix])
end




__HttpCallback['/file']=http_file
__HttpCallback['/']=http_file
__HttpCallback['/test']=http_test
__HttpCallback['/blog/post']=http_blog_post
__HttpCallback['/blog/modify']=http_blog_modify
__HttpCallback['/blog/login']=http_blog_login
__HttpCallback['/blog/register']=http_blog_register
__HttpCallback['/blog/active']=http_blog_active
__HttpCallback['/blog/delete']=http_blog_delete
__HttpCallback['/blog/comment/post']=http_comment_post
__HttpCallback['/blog/comment/like']=http_comment_like
__HttpCallback['/blog/comment/refuse']=http_comment_refuse
__HttpCallback['/blog/comment/list']=http_comment_list
__HttpCallback['/blog/refresh/cache']=http_refresh_cache

if not QUERY_COUNT then
	QUERY_COUNT=0
end


local s = '[a=b, c=\'d\', dd=[[]]]'
print(s, escape_square_brackets(s))


