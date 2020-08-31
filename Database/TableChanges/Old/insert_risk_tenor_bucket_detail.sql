IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '0-2 months') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '0-2 months', 'First 2 months', 0, 2)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 0-2 months.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 0-2 months already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '2-6 months') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '2-6 months', '2-6 months', 2, 6)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 2-6 months.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 2-6 months already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '6-12 months') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '6-12 months', '6-12 months', 6, 12)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 6-12 months.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 6-12 months already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '1-2 year') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '1-2 year', '1-2 year', 12, 24)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 1-2 year.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 1-2 year already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '2-3 year') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '2-3 year', '2-3 year', 24, 36)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 2-3 year.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 2-3 year already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '3-4 year') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '3-4 year', '3-4 year', 36, 48)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 3-4 year.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 3-4 year already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '4-5 year') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '4-5 year', '4-5 year', 48, 60)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 4-5 year.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 4-5 year already exist in risk_tenor_bucket_detail.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_detail WHERE tenor_name = '6+ year') 	
BEGIN
	INSERT INTO risk_tenor_bucket_detail(bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to) VALUES (1, '6+ year', '6+ year', 60, 72)
	PRINT 'New Value Inserted in risk_tenor_bucket_detail with tenor_name = 6+ year.'
END
ELSE 
BEGIN
	PRINT 'Value of tenor_name = 6+ year already exist in risk_tenor_bucket_detail.'
END