--delete junk data
DELETE rmvu
FROM report_manager_view_users rmvu
INNER JOIN data_source ds 
	ON ds.data_source_id = rmvu.data_source_id
WHERE ds.type_id = 2