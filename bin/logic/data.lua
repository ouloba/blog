
--管理员邮箱
ADMIN_MAIL="<215271461@qq.com>"

--网易邮箱账号
MAIL_ACCOUNT='15001179252@163.com'

--网易邮箱密码(第三方平台密码)
MAIL_PASSWORD='19781103CnmCnm'

--邮箱服务器
MAIL_SERVER='smtp.163.com'

--网易邮箱端口25(ssl 465)
MAIL_SERVER_PORT=465

--是否使用SSL,注意要和MAIL_SERVER_PORT匹配
MAIL_SSL=true

--密码混串(一但变化，之前注册的密码全作废)
MAGIC_CODE='AA%$$###'

--注册是否需要审核
REGISTER_NEED_VERIFY=true

--asset目录下，客户端缓存资源(目录),减少请求
CachePrefixs = {}
CachePrefixs['/images']=600
CachePrefixs['/third-party']=60000
CachePrefixs['/dialog']=60000
CachePrefixs['/_src']=60000
CachePrefixs['/themes']=60000
CachePrefixs['/fonts']=60000
CachePrefixs['/game']=60*60*24

--权限定义
UserRights={}
UserRights['0']={'blog list', 'blog view', 'comment view'}                              --普通游客
UserRights['1']={'blog list', 'blog view', 'comment view', 'comment post'}  --登录用户
UserRights['2']={'blog list', 'blog view', 'blog post', 'blog delete', 'comment view', 'comment post', 'comment delete'}                           --管理员
UserRights['3']={'blog list', 'blog view', 'blog post', 'blog delete', 'comment view', 'comment post', 'comment delete', 'change right'}  --超级管理员


--评论
UserResponeComments={}






