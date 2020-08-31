--	This script is used to Map a deal template defined in the application
--	with the new created list of default UDF Fields.
--	
--	Requirements :- 
--	1. check for the existence of Risk Premium, Add-ons, Others and Weight under UDF Group [static_data_type_id : 15600]
--	2. check for the existence of values with negative value_id under User Defined Fields [static_data_type_id : 5500]



-- check if the temporary table #handle_sp_return exists, if true, drop table
IF OBJECT_ID('tempdb..#handle_sp_return', 'u') IS NOT NULL
BEGIN
	DROP TABLE #handle_sp_return
END

IF OBJECT_ID('tempdb..#templates', 'u') IS NOT NULL
BEGIN
	DROP TABLE #templates
END
-- Create temporary table #handle_sp_return to store the return message from the SP call.
CREATE TABLE #handle_sp_return(
	[ErrorCode]	VARCHAR(100),
	[Module]	VARCHAR(500),
	[Area]		VARCHAR(100),
	[Status]	VARCHAR(100),
	[Message]	VARCHAR(500),
	[Recommendation] VARCHAR(100) 	
)

DECLARE @template_id INT,@Others_sdv_id INT
--TODO: Set the deal template_id for which you need to map the UDF fields.
--SET @template_id = 57
CREATE TABLE #templates(template_id INT)
INSERT INTO #templates
SELECT 111
UNION
SELECT 112
UNION
SELECT 113
UNION
SELECT 114
UNION
SELECT 115
UNION
SELECT 116
UNION
SELECT 117
UNION
SELECT 118
UNION
SELECT 119
UNION
SELECT 120
UNION
SELECT 121
UNION
SELECT 122
UNION
SELECT 123
UNION
SELECT 124
UNION
SELECT 125
UNION
SELECT 126

SELECT @Others_sdv_id = sdv.value_id FROM static_data_value sdv WHERE sdv.code = 'Others' AND sdv.[type_id] = 15600


BEGIN TRY

		DELETE udf FROM user_defined_deal_fields_template udft
		INNER JOIN user_defined_deal_fields udf ON udf.udf_template_id = udft.udf_template_id 
		WHERE field_name=-5585

		DELETE FROM user_defined_deal_fields_template WHERE field_name=-5585
		
	---- Insert Pratos time stamp
	DECLARE cursor1 cursor FOR
		SELECT template_id FROM #templates
	OPEN cursor1
	FETCH NEXT FROM cursor1 INTO @template_id
	WHILE @@FETCH_STATUS=0
	BEGIN
		INSERT INTO #handle_sp_return exec spa_user_defined_deal_fields_template 'i',NULL,@template_id,'-5585','Pratos Timestamp','t','varchar(150)','n',NULL,NULL,'s',1,20, -5585,NULL,NULL,NULL,@Others_sdv_id,NULL, NULL
	
	FETCH NEXT FROM cursor1 INTO @template_id
	END	
	CLOSE cursor1
	DEALLOCATE cursor1
	
END TRY
BEGIN CATCH
	PRINT 'Something went wrong, please check the template_id and the presence of UDF fields in the system.'
END CATCH

-- return the status results form the SP.
SELECT * FROM #handle_sp_return
