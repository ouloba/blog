ExecuteSQL({[1]=[[SELECT a.`id`,
    b.nickname as post_author,
    a.`post_date`,    
    a.`post_title`,
    a.`post_status`,
    a.`category`,
    a.`post_desc`,
	a.`read_count`,
	a.`comment_count`
	FROM `blogs`.`documents` as a,`blogs`.`accounts` as b  where a.post_status=0 and a.post_author=b.userid order by a.post_date desc limit 0,10;]]})