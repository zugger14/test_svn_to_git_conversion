IF OBJECT_ID('tempdb..#temp_dp_detail') IS NOT NULL
	DROP TABLE #temp_dp_detail
	
IF OBJECT_ID('tempdb..#temp_delivery_detail') IS NOT NULL
	DROP TABLE #temp_delivery_detail	

IF OBJECT_ID('tempdb..#temp_unique_path') IS NOT NULL
	DROP TABLE #temp_unique_path	

CREATE TABLE #temp_dp_detail (dp_id INT IDENTITY(1, 1), group_path VARCHAR(1000), path_code VARCHAR(1000), order_id INT)
CREATE TABLE #temp_delivery_detail (detail_id INT IDENTITY(1,1), group_path VARCHAR(1000), path_code VARCHAR(1000))
CREATE TABLE #temp_unique_path(path_id int,path_name int,detail_id int)

INSERT INTO #temp_dp_detail (group_path)
SELECT RTRIM(LTRIM(a.groupPath))
FROM [temp_process_table] a
WHERE a.groupPath IS NOT NULL
GROUP BY a.groupPath

INSERT INTO delivery_path (path_code, path_name, isactive, groupPath, commodity)
SELECT a.group_path, a.group_path, 'y', 'y', sco.source_commodity_id
FROM #temp_dp_detail a
LEFT JOIN delivery_path dp ON dp.path_code = a.group_path
LEFT JOIN source_commodity sco ON sco.commodity_id = 'Natural Gas'
WHERE a.group_path IS NOT NULL AND dp.path_code IS NULL
	 
INSERT INTO #temp_delivery_detail (group_path, path_code)
SELECT s.group_path, b.path_code
FROM #temp_dp_detail AS s 
INNER JOIN [temp_process_table] b ON s.group_path = b.groupPath 
ORDER BY group_path, CHARINDEX(b.path_code, s.group_path)

INSERT INTO #temp_unique_path(path_id,path_name,detail_id)
(
	SELECT dp_group.path_id, dp.path_id,temp.detail_id
	FROM #temp_delivery_detail temp 
	INNER JOIN delivery_path dp_group ON dp_group.path_code = temp.group_path
	INNER JOIN delivery_path dp ON dp.path_code = temp.path_code
	LEFT JOIN delivery_path_detail dpd ON dpd.Path_id = dp_group.path_id AND dpd.Path_name = dp.path_id
	AND dpd.Path_id is null
)

INSERT INTO delivery_path_detail (Path_id, Path_name)
Select up.path_id,up.path_name FROM #temp_unique_path up
LEFT JOIN delivery_path_detail dpd on dpd.Path_id = up.path_id 
LEFT JOIN delivery_path_detail dpd1 on dpd1.Path_name = up.path_name
WHERE dpd.Path_id is null And dpd1.Path_name is null
ORDER BY detail_id

INSERT INTO counterparty_contract_rate_schedule(counterparty_id, contract_id, rate_schedule_id, path_id)
SELECT DISTINCT counterparty,[CONTRACT],value_id,path_id
FROM
(
	SELECT dp.counterparty,dp.[CONTRACT],sdv.value_id,dp.path_id
	FROM  [temp_process_table]  a
	INNER JOIN delivery_path dp ON dp.path_code = a.path_code
	INNER JOIN static_data_value sdv ON sdv.code = a.rateSchedule AND sdv.[type_id]= 1800
	LEFT JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id 
	 AND ccrs.counterparty_id = dp.counterParty AND ccrs.contract_id = dp.[CONTRACT]
	WHERE ccrs.counterparty_contract_rate_schedule_id IS NULL
	UNION ALL
	SELECT distinct dp.counterparty,dp.[CONTRACT],sdv.value_id,dp.path_id
	FROM #temp_unique_path up
	LEFT JOIN delivery_path_detail dpd on dpd.Path_id = up.path_id 
	LEFT JOIN delivery_path_detail dpd1 on dpd1.Path_name = up.path_name
	INNER JOIN delivery_path dp ON dp.path_id = up.path_name
	LEFT JOIN [temp_process_table] temp ON dp.path_code = temp.path_code
	LEFT JOIN static_data_value sdv ON sdv.code = temp.rateSchedule AND sdv.[type_id]= 1800
	LEFT JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id 
	 AND ccrs.counterparty_id = dp.counterParty AND ccrs.contract_id = dp.[CONTRACT]
	WHERE ccrs.counterparty_contract_rate_schedule_id IS NULL
) a

UPDATE ccrs
SET counterparty_id = dp.counterparty,
contract_id = dp.[CONTRACT],
rate_schedule_id = sdv.value_id,
path_id = dp.path_id
FROM  [temp_process_table]  a
INNER  JOIN delivery_path dp ON dp.path_code = a.path_code
INNER JOIN static_data_value sdv ON sdv.code = a.rateSchedule AND sdv.[type_id]= 1800
INNER JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id 
 AND ccrs.counterparty_id = dp.counterParty AND ccrs.contract_id = dp.[CONTRACT]

UPDATE ccrs
SET counterparty_id = dp.counterparty,
contract_id = dp.[CONTRACT],
rate_schedule_id = sdv.value_id,
path_id = dp.path_id
FROM #temp_unique_path  up
LEFT JOIN delivery_path_detail dpd on dpd.Path_id = up.path_id 
LEFT JOIN delivery_path_detail dpd1 on dpd1.Path_name = up.path_name
INNER JOIN delivery_path dp ON dp.path_id = up.path_name
LEFT JOIN  [temp_process_table]  temp ON dp.path_code = temp.path_code
LEFT JOIN static_data_value sdv ON sdv.code = temp.rateSchedule AND sdv.[type_id]= 1800
INNER JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id 
 AND ccrs.counterparty_id = dp.counterParty AND ccrs.contract_id = dp.[CONTRACT]