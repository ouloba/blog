--棋牌通用接口
local json=luaopen_cjson()
json.encode_sparse_array(true)

local now = os.clock()
local clock_info = {}
function clock_init()
	now = os.clock()
	clock_info = {}
end

local function clock_test(a)
	if not clock_info[a] then
		clock_info[a]= 0
	end
	local d = os.clock()
	clock_info[a]=clock_info[a]+d-now
	now = d	
end

--统计数据
function analy_datas(datas, out_t, fn)	
	for k_,v in pairs(datas) do
		local k=fn(v)
		local t_=out_t[k]
		if not t_ then
			t_={}
			out_t[k]=t_
		end
		t_[#t_+1]=v
	end
	return out_t
end

--随机挑选数据
function get_random_one(datas)
	local idx = math.mod(math.random(), #datas)
	local v = datas[idx]
	table.remove(datas, idx)
	return  v
end

function pop_one(datas)
	local v = datas[#datas]
	datas[#datas]=nil
	return v
end

--删除集合
function remove_set(datas, sub, count)
	local cnt = 0
	for t=1,#sub,1 do
		if not count or t<=count then
			for i=1,#datas,1 do
				if sub[t]==datas[i] then
					table.remove(datas, i)
					cnt=cnt+1				
					break
				end
			end
		end
	end
	return cnt
end

--返回子集
function sub_set(datas,  pos, count)
	local t = {}
	for i=pos,pos+count,1 do
		t[#t+1]=datas[i]
	end
	return t
end

--联合
function union_set(datas, subs)
	for i=1,#subs,1 do
		datas[#datas+1]=subs[i]
	end
end

--联合
function union_set_return(datas, subs)
	local t = deepcopy(datas)
	for i=1,#subs,1 do
		t[#t+1]=subs[i]
	end
	return t
end

--返回组合集
function enum_sorted_set(datas, count, fn)
	local t = {}
	for i=1,#datas-count+1,1 do
		if fn(datas, i, i+count-1) then
			t[#t+1]=sub_set(datas, i, count-1)			
		end
	end
	return t
end

--替换
function replace_element(datas, s, d)
	for i=1,#datas,1 do
		if datas[i]==s  then
			datas[i]=d		
		end
	end
end

--集合是否相等
function equal_set(datas, others)
	if #datas~=#others then
		return false
	end
	
	local cnt = 0
	for i=1,#datas,1 do
		for t=1,#others,1 do
			if datas[i]==others[t] then
				cnt=cnt+1
				break
			end
		end
	end	
	return cnt==#datas
end

--枚举所有顺子
function enum_shunzi_set(count_t, value_fn, count, fn)
	local t = {}
	for i=1,#count_t-count+1,1 do
		local d,c = fn(count_t, i, i+count-1)
		if d then
			c = c and c or 1
			for k=1,c,1 do
				t[#t+1]=d
			end
		end
	end
	return t
end

local function combine(pos, cnt, n, k, a,visited,out,fn)
    --已标记了k个数，输出结果
    if (cnt == k) then	
		local t = fn(visited)
		if t then
			out[#out+1]=t
		end
        return true
    end

    --处理到最后一个数，直接返回
    if (pos == n+1) then return end

    --如果a[pos]没有被选中
    if (not visited[pos]) then
        --选中a[pos]
        visited[pos] = true		
        --处理在子串a[pos+1, n-1]中取出k-1个数的子问题
        combine(pos + 1, cnt + 1, n, k, a,visited,out,fn) 		
        --回溯
        visited[pos] = false 		
    end
	
    --处理在子串a[pos+1, n-1]中取出k个数的问题
   combine(pos + 1, cnt, n, k, a, visited,out,fn) 	
end

--枚举组合
function enum_combine_set(datas, count,fn)
	local visited={false,false,false,false,false,false,false,false,false,false,false,false,false,false}--createtable_new(#datas,#datas)
	local out =createtable_new(1024,1024)	
	combine(1, 0, #datas, count, datas,visited,out,fn)
	return out
end

function create_array(size, init)
	local copy = deepcopy
	local t = {}
	for i=1,size,1 do
		t[i]=copy(init)
	end
	return t
end


function get_clock_info()
 return clock_info
end

--判断麻将是否胡牌
function mahjong_ishu(datas, magic, value_fn)
	if (math.floor(#datas/3)*3+2)~=#datas then
		return
	end
	
	if #datas==2 and 
		(value_fn(datas[1]) ==value_fn(datas[2]) or
  		value_fn(datas[1])==value_fn(magic) or 
		value_fn(datas[2])==value_fn(magic))
		   then
			return {}, datas
	end		
	
	local copy = deepcopy
	
	local shunzi_fn = function(s, pos, dstpos)
		if pos>=41 then	return	end
	
		local c=4
		local t = {}
		for i=pos,dstpos,1 do
			if #s[i]<=0 then
				return
			end					
			t[#t+1]=s[i][1]
			c= c>#s[i] and #s[i] or c
		end		
		return t,c
	end
	
	table.sort(datas, function(a,b) 	return  value_fn(a) < value_fn(b)	end)

	local count_t=create_array(0x5F,{}) 
	local count_count_t=create_array(4,{}) 
	analy_datas(datas,count_t, function(a) return value_fn(a)  end)
	analy_datas(count_t, count_count_t, function(a) return #a end)

	local count_t_t = {}
	for i=1,#count_t,1 do
		count_t_t[i]=#count_t[i]
	end
	
	local magic_cnt = (count_t[value_fn(magic)]==nil) and 0 or #count_t[value_fn(magic)]
		
	local threes = {}
	union_set(threes,count_count_t[3])
	union_set(threes,count_count_t[4])	
	union_set(threes, enum_shunzi_set(count_t,	value_fn, 3, shunzi_fn))	

	if magic_cnt>=1 then		
		local shunzi_fn1 = function(s, pos, dstpos)
			if pos>=41 then	return	end
			if #s[pos]<=0 then return end
			if #s[dstpos]<=0 then return end
			if #s[(pos+dstpos)/2]>0 then return end			
			local t = {s[pos][1], s[dstpos][1]}
			return t
		end
	
		local twos = enum_shunzi_set(count_t,	value_fn, 2, shunzi_fn)
		union_set(twos,count_count_t[2])
		
		local two2 = enum_shunzi_set(count_t,	value_fn, 3, shunzi_fn1)
		union_set(twos,two2)

		for i=1,#twos,1 do
			twos[i][#twos[i]+1]=magic				
		end
		union_set(threes, twos)
	end

	if magic_cnt>=2 then		
		local ones = copy(count_count_t[1])		
		for i=1,#ones,1 do			
			ones[i][#ones[i]+1]=magic
			ones[i][#ones[i]+1]=magic			
			threes[#threes+1]=ones[i]			
		end				
	end

	local get_card_cnt= function(cards, card)
		local c = 0
		for i=1,#cards,1 do
			if cards[i]==card then
				c = c+1
			end
		end		
		return c
	end
	
	local summary_t = {}
	for i=1,#threes,1 do
		summary_t[#summary_t+1]=get_card_cnt(threes[i],magic) 
	end
	
	local cc = math.floor(#datas/3)
	local threes_t = enum_combine_set(threes, cc, function(visited)
		local magics = 0
		local t = createtable_new(cc,cc)		
		for i=1,#threes,1 do
			if visited[i] then
				magics=magics+summary_t[i]				
				t[#t+1]=i
			end
		end		
		if magics<=magic_cnt then 
			return t
		end
	end)	
	
	PrintFastLog('threes_t size:', json.encode(threes_t),  ' threes:', json.encode(threes), ' summary_t:', json.encode(summary_t))
	clock_test('a8')	
	
	local out_threes = {}
	for i=1,#threes_t,1 do
		local threes_idx=threes_t[i]
		--PrintFastLog('threes_idx:', json.encode(threes_idx))
		local t_t = (count_t_t)
		local ok = nil
		local c = {}
		for t=1,#threes_idx,1 do
			local three = threes[threes_idx[t]]
			ok = nil
			
			local a = value_fn(three[3])
			if t_t[a]<=0 then break end			
			t_t[a]=t_t[a]-1			
			c[#c+1]=a
			
			local a = value_fn(three[1])
			if t_t[a]<=0 then break end			
			t_t[a]=t_t[a]-1
			c[#c+1]=a
			
			local a = value_fn(three[2])
			if t_t[a]<=0 then break end			
			t_t[a]=t_t[a]-1
			c[#c+1]=a
						
			ok=true
		end		
		clock_test('a88')		
		if  ok then
			--PrintFastLog('threes:', json.encode(threes))
			local datas_t = copy(datas)
			local three_outs = {}
			for kk=1,#threes_idx,1 do
				remove_set(datas_t, threes[threes_idx[kk]], 3)
				three_outs[#three_outs+1]=threes[threes_idx[kk]]
			end
			
			--PrintFastLog('datas_t:', json.encode(datas_t))					
			if t_t[value_fn(magic)]==1 or 
				value_fn(datas_t[1])==value_fn(datas_t[2])
			   then
				clock_test('a9')
				return three_outs, datas_t
			end	
		end
		
		--restort
		for kk=1,#c,1 do
			t_t[c[kk]]=t_t[c[kk]]+1
		end		
	end			
end

--13水自动开牌
function Is_thirteen_shunzi(datas, value_fn)
	local datas_=deepcopy(datas)	
	
	local shunzis = {}
	local shunzis_5_ = enum_shunzi_set(datas_, value_fn, 5)
	if #shunzis_5_<2 then
		return shunzis
	end
	
	local shunzis_3_ = enum_shunzi_set(datas_, value_fn, 3)
	if #shunzis_3_<1 then
		return shunzis
	end
		
	local shunzis = {}	
	for i=1,#shunzis_3_,1 do
		local cards = deepcopy(datas)
		remove_set(cards, shunzis_3_[i])		
		shunzis = {shunzis_3_[i]}		
		for t=1,#shunzis_5_,1 do
			if remove_set(cards, shunzis_5_[t])~=5 then
				break
			end
			
			shunzis[#shunzis+1]=shunzis_5_[t]
			if #shunzis==3 then
				return shunzis
			end			
		end
	end	
	
	return shunzis
end

function thirteen_auto_split(datas, value_fn, color_fn)
	table.sort(datas, function(a,b) 	return  value_fn(a) < value_fn(b)	end)
	local count_t={}
	analy_datas(datas,count_t, function(a) return value_fn(a)  end)
	
end



