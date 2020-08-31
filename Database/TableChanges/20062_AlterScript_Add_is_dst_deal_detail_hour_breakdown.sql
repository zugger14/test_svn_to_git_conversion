IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns  c on t.object_id = c.object_id WHERE t.name = 'deal_detail_hour_breakdown'  AND c.name = 'is_dst')
BEGIN
	AlTER TABLE deal_detail_hour_breakdown	ADD is_dst INT NOT NULL Default (0)
END 
ELSE 
BEGIN
	PRINT 'IS_dst is already present.'
END