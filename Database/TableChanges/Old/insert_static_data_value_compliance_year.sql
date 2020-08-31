if not exists(select 'x' from static_data_value where code in ('2032','2033','2034','2035','2036','2037','2038','2039','2040','2041','2042','2043','2044','2045','2046','2047','2048','2049','2050'))
BEGIN
	set identity_insert static_data_value ON
	insert into static_data_value(value_id,[type_id],code,[description])
	select 5549,10092,2031,2031
	union all select 5550,10092,2032,2032
	union all select 5551,10092,2033,2033
	union all select 5552,10092,2034,2034
	union all select 5553,10092,2035,2035
	union all select 5554,10092,2036,2036
	union all select 5555,10092,2037,2037
	union all select 5556,10092,2038,2038
	union all select 5557,10092,2039,2039
	union all select 5558,10092,2040,2040
	union all select 5559,10092,2041,2041
	union all select 5560,10092,2042,2042
	union all select 5561,10092,2043,2043
	union all select 5562,10092,2044,2044
	union all select 5563,10092,2045,2045
	union all select 5564,10092,2046,2046
	union all select 5565,10092,2047,2047
	union all select 5566,10092,2048,2048
	union all select 5567,10092,2049,2049
	union all select 5568,10092,2050,2050
	set identity_insert static_data_value OFF

END