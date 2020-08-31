IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_header WHERE bucket_header_name = 'bucket1') 	
BEGIN
	INSERT INTO risk_tenor_bucket_header(bucket_header_name) VALUES ('bucket1')
	PRINT 'New Value Inserted in risk_tenor_bucket_header with bucket_header_name=bucket1.'
END
ELSE 
BEGIN
	PRINT 'Value of bucket_header_name=bucket1 already exist in risk_tenor_bucket_header.'
END
IF NOT EXISTS (SELECT 'x' FROM dbo.risk_tenor_bucket_header WHERE bucket_header_name = 'bucket2') 	
BEGIN
	INSERT INTO risk_tenor_bucket_header(bucket_header_name) VALUES ('bucket2')
	PRINT 'New Value Inserted in risk_tenor_bucket_header with bucket_header_name=bucket2.'
END
ELSE 
BEGIN
	PRINT 'Value of bucket_header_name=bucket2 already exist in risk_tenor_bucket_header.'
END

