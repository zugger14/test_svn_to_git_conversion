IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_risk_tenor_bucket_header_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_risk_tenor_bucket_header_detail]
go
CREATE PROCEDURE [dbo].[spa_risk_tenor_bucket_header_detail]
	@flag CHAR(1) ,
	@bucket_header_id INT = null,
	@bucket_header_name VARCHAR(50) = null 
AS 
IF @flag ='s'
BEGIN
		SELECT bucket_header_id 'ID', bucket_header_name 'Name'  FROM  risk_tenor_bucket_header
END
ELSE IF @flag ='i' 
BEGIN
	IF EXISTS (SELECT bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name = @bucket_header_name)
		BEGIN
			Exec spa_ErrorHandler -1, 'Tenor Bucket already exsists.',
				'spa_risk_tenor_bucket_header_detail', 'DB_Error',
				'This bucket header name already exists. Please enter another name.',''
			RETURN
		END
	ELSE 
		BEGIN
			INSERT INTO risk_tenor_bucket_header(bucket_header_name) VALUES (@bucket_header_name)
			Exec spa_ErrorHandler 0, 'Tenor Bucket Added Successfully.',
				'spa_risk_tenor_bucket_header_detail', 'DB_Error',
				'Tenor Bucket Added Successfully.',''
			RETURN		
		END
		
END
ELSE IF @flag ='u'
BEGIN
	IF EXISTS (SELECT bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name = @bucket_header_name AND bucket_header_id <> @bucket_header_id)
		BEGIN
			Exec spa_ErrorHandler -1, 'Tenor Bucket already exsists.',
				'spa_risk_tenor_bucket_header_detail', 'DB_Error',
				'This bucket header name already exists. Please enter another name.',''
			RETURN
		END
	ELSE 
		BEGIN
			UPDATE risk_tenor_bucket_header SET bucket_header_name = @bucket_header_name WHERE bucket_header_id = @bucket_header_id
			Exec spa_ErrorHandler 0, 'Tenor Bucket Updated Successfully.',
				'spa_risk_tenor_bucket_header_detail', 'DB_Error',
				'Tenor Bucket Updated Successfully.',''
			RETURN	
		END
		
END
ELSE IF @flag ='d'
BEGIN
	IF EXISTS (SELECT 1 FROM risk_tenor_bucket_detail WHERE bucket_header_id = @bucket_header_id )
	BEGIN
		SELECT 'Error', 'risk_tenor_bucket_header', 
		'spa_risk_tenor_bucket_header_detail', 'DB Error', 
		'Tenor Bucket(s) in the selected Tenor Group should be deleted first.'
		RETURN
	END
	DELETE FROM  risk_tenor_bucket_header WHERE bucket_header_id = @bucket_header_id
		SELECT 'Success', 'risk_tenor_bucket_header', 
			'spa_risk_tenor_bucket_header_detail', 'Success', 
			'Data Deleted Successfully'

END
IF @flag ='a'
BEGIN
	SELECT bucket_header_name FROM  risk_tenor_bucket_header WHERE bucket_header_id = @bucket_header_id
END