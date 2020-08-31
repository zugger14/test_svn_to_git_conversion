DECLARE @year VARCHAR(200),
		@ins_del VARCHAR(200),
		@dst_gv_id VARCHAR(200)

SELECT @year = [year],
	@ins_del = insert_delete,
	@dst_gv_id = dst_group_value_id
FROM mv90_dst
GROUP BY year,insert_delete,dst_group_value_id
HAVING count(year) > 1

--PRINT @year + @ins_del + @dst_gv_id
DELETE FROM mv90_dst
WHERE year = @year 
	AND insert_delete = @ins_del 
	AND dst_group_value_id = @dst_gv_id