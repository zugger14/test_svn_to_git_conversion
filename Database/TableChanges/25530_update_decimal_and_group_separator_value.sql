UPDATE application_users
	SET group_separator = CASE group_separator 
								 WHEN '112800' THEN ','
								 WHEN '112801' THEN '.'
								 WHEN '112802' THEN ''''
								 WHEN '112803' THEN 's'
								 WHEN '112804' THEN 'n'
								 WHEN '0' THEN NULL
							ELSE NULL END
WHERE CAST(ISNULL(NULLIF(group_separator,''),'-1') AS VARCHAR(10)) IN ('112800','112801','112802','112803','112804','0')

UPDATE application_users
	SET decimal_separator = CASE decimal_separator 
								 WHEN '112800' THEN ','
								 WHEN '112801' THEN '.'
								 WHEN '0' THEN NULL
							ELSE NULL END
WHERE CAST(ISNULL(NULLIF(decimal_separator,''),'-1') AS VARCHAR(10)) IN ('112800','112801','0')
