
IF OBJECT_ID(N'[dbo].[spa_generate_document_word]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generate_document_word]
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- flag 'g' to generate
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pamatya@pioneersolutionsglobal.com
-- Create date: 04-14-2016
-- Description:	Takes process table as an input and generates document being based on it. 
--SELECT * FROM adiha_process.dbo.Deal_243531_2016_4_19_10382

-- =============================================

CREATE PROCEDURE [dbo].[spa_generate_document_word]
	@flag CHAR(1) = 'g'
	,@process_table VARCHAR(250) = NULL
	,@is_xml_needed CHAR(1) ='y'	
	,@document_category_id INT = NULL
	,@criteria VARCHAR(500) = NULL
	,@process_id VARCHAR(200) = NULL
	,@temp_path VARCHAR(200) = NULL
AS
/*
	DECLARE @flag CHAR(1) = 'g'
	DECLARE @process_table VARCHAR(250) = 'adiha_process.dbo.Invoice_D9574638_9A87_47BF_A8A5_5B0C6E9C0A03'
	DECLARE @is_xml_needed CHAR(1) ='y'
	DECLARE @criteria VARCHAR(500) = 'calc_id = 21318'
--	DECLARE @template_id INT = 8
	DECLARE @document_category_id INT = NULL
	DECLARE @process_id VARCHAR(200)  = '123123123123'
	DECLARE @temp_path VARCHAR(200) = '\\SG-D-WEB01\shared_docs_TRMTracker_Trunk\temp_Note\'
	--EXEC  [dbo].[spa_generate_document_word] 'g','adiha_process.dbo.Deal_0DA4C601_8F89_45CF_8767_FDB11AF2BE88','y',NULL, 'source_deal_header_id=37255','1231231231231'
--*/

--SELECT * FROM adiha_process.dbo.Schedule_Match_0C905209_D13A_495C_8CA8_A6B615A01467




BEGIN
	SET NOCOUNT ON
	DECLARE @xml_table VARCHAR(250)
			,@new_process_id VARCHAR(250)
			,@template_name VARCHAR(500)
	DECLARE @int_variable int
	DECLARE @sql_string nvarchar(500)
	DECLARE @parm_definition nvarchar(500);
	DECLARE @template_out varchar(30);
	DECLARE @generic_path VARCHAR(1000)
	DECLARE @xml_path VARCHAR(200)
	DECLARE @template_path VARCHAR(200),@document_path VARCHAR(200)
	DECLARE @xml_created  NVARCHAR(1024)
	DECLARE @doc_created VARCHAR(30)
	DECLARE @xml_filename VARCHAR(200)
	DECLARE @file_name VARCHAR(200)
	DECLARE @table_names VARCHAR(200)
	DECLARE @xml_var XML 
	DECLARE @final_xml VARCHAR(MAX)
	DECLARE @sql nVARCHAR(4000)
	DECLARE @tsql VARCHAR(MAX)
	DECLARE @data_source_id INT
	DECLARE @data_source_name VARCHAR(300)
	DECLARE @file_exists INT 
	DECLARE @xml_file_name VARCHAR(50)
	DECLARE @outputvar NVARCHAR(4000)
	DECLARE @template_id INT 
	DECLARE @xsd_path NVARCHAR(500)	
	DECLARE @sign VARCHAR(500)
	--DECLARE @criteria VARCHAR(500) = 'source_deal_header_id=37255'
			
		
	IF OBJECT_ID('tempdb..#data_source_list') IS NOT NULL
		DROP TABLE #data_source_list
IF @flag = 'g' 
BEGIN 
BEGIN TRY

	SET @int_variable = 197;
	
	SET @sql_string = N'SELECT @templateOut = template_id
	   FROM '+@process_table 
	   
	SET @parm_definition = N'@level tinyint, @templateOut varchar(2000) OUTPUT';

	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@template_id OUTPUT;
	
	SET @sql_string = N'SELECT @templateOut = template_name 
	   FROM '+@process_table 
	   
	SET @parm_definition = N'@level tinyint, @templateOut varchar(2000) OUTPUT';

	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@template_name OUTPUT;

	SELECT @new_process_id = dbo.FNAGETnewID();
	SELECT @xml_table = 'adiha_process.dbo.'+ @template_name+'_'+@new_process_id 

	SELECT @sql_string = N'SELECT @templateOut = file_location 
	   FROM '+@process_table
	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@generic_path OUTPUT;

	SELECT @sql_string = N'SELECT @templateOut = xml_map_filename 
	   FROM '+@process_table
	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@xml_filename OUTPUT;

	SELECT @sql_string = N'SELECT @templateOut = filename 
	   FROM '+@process_table
	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@file_name OUTPUT;

	SELECT @sql_string = N'SELECT @templateOut = xsd_file 
		   FROM '+@process_table
		EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@xsd_path OUTPUT;


	SELECT @sql_string = N'SELECT @templateOut = template_id
	   FROM '+@process_table
	EXECUTE sp_executesql @sql_string, @parm_definition, @level = @int_variable, @templateOut=@template_id OUTPUT;

	

	SELECT * INTO #data_source_list 
		FROM contract_report_template_views 
	WHERE template_id = @template_id

	SELECT @xml_path = @generic_path +'\xmls\'+@xml_filename+'.xml'
	SELECT @template_path = @generic_path +'\Template'+REPLACE(@template_name,' ','_')+'.docx'
	SELECT @document_path = @generic_path + '\'+@file_name


	EXEC master.dbo.xp_fileexist @xml_path,@file_exists OUT 
	
	
	SET @xml_table = REPLACE(@xml_table,' ','_')
	IF @is_xml_needed = 'y'  --AND @file_exists = 0 
	BEGIN 
	

	DECLARE xml_file CURSOR FOR 
	SELECT data_source_id FROM #data_source_list

	OPEN xml_file

	FETCH NEXT FROM xml_file 
	INTO @data_source_id

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SELECT @tsql = tsql,@data_source_name = REPLACE(name,' ','_') 
			 FROM #data_source_list dsl INNER JOIN data_source ds ON dsl.data_source_id = ds.data_source_id
			WHERE dsl.data_source_id = @data_source_id

		SET @table_names = 'adiha_process.dbo.xml_file_'+@data_source_name+'_'+@process_id
		
		EXEC('IF OBJECT_ID('+''''+@table_names+''''+') IS NOT NULL
				DROP TABLE '+ @table_names)
				
		SELECT @tsql = REPLACE(@tsql,'--[__batch_report__]','into '+@table_names)
		
		SELECT @tsql = dbo.FNARFXReplaceReportParams(@tsql,@criteria,null)

		EXEC(@tsql)
		
		SET @parm_definition = N'@level tinyint, @xmlout XML OUTPUT';
		SET @sql = N'SELECT @xmlout = (SELECT * FROM ' + @table_names + ' FOR XML PATH('+''''+@data_source_name+''''+'),Root('+''''+@data_source_name+'s'+''''+'))' 
		
		

		
		EXECUTE sp_executesql @sql, @parm_definition, @level = @int_variable, @xmlout=@xml_var OUTPUT;
		
		SELECT @final_xml = ISNULL(@final_xml,'')  + CAST(ISNULL(@xml_var,'') as VARCHAR(MAX))
		
		

		FETCH NEXT FROM xml_file INTO @data_source_id
	END
	CLOSE xml_file

	DEALLOCATE xml_file
	
	SET @final_xml = '<Order>'+ CAST(ISNULL(@final_xml,'') as VARCHAR(MAX)) + '</Order>'
	

	IF EXISTS (SELECT 1 FROM #data_source_list)
		EXEC spa_write_to_file  @final_xml,'n', @xml_path, @outputvar output
	END
	SELECT @template_name = @generic_path+'\Template\'+Replace(Rtrim(ltrim(@template_name)),' ','_')+'.docx'
	SELECT @file_name = ISNULL(@temp_path,@generic_path)+'\'+Rtrim(ltrim(@file_name))
	SELECT @xsd_path = @generic_path+'\xmls\'+ Rtrim(ltrim(@xsd_path))
SELECT @sign = @generic_path+'\'+ 'sign.jpg'

	
	IF EXISTS (SELECT 1 FROM #data_source_list)
		BEGIN
	
			EXEC spa_generate_doc_using_xml @xml_path,@xsd_path,@template_name,@file_name,@template_id	
			--EXEC spa_insert_a_picture @file_name,@sign

		END
	ELSE 
	BEGIN
		DECLARE @result VARCHAR(1000)
		EXEC spa_copy_file @template_name, @file_name, @result OUTPUT	
	
		
	END
	SELECT 'Sucess' [status],'Document Created' [Message] 
END TRY
BEGIN CATCH
	SELECT 'error' [status],'Error while creating document' [Message] 
END CATCH
END

END



