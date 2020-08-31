/****** Object:  StoredProcedure [dbo].[spa_report_column_definition]    Script Date: 07/28/2009 11:48:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_column_definition]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_column_definition]
GO

CREATE PROC [dbo].[spa_report_column_definition]
	@flag char(1)='i',
    @report_id varchar(100)=null,
	@xmltext TEXT
	
as
SET NOCOUNT ON 
--exec spa_report_column_definition 123,'<Root><PSRecordset  report_id="1" column_id="0" column_name="content_type" columns="content_type" column_alias="Content" filter="true" max_function="false" min_function="false" count_function="false" sum_function="false" avg_function="false"></PSRecordset><PSRecordset  report_id="1" column_id="1" column_name="Internal_type_value_id" columns="Internal_type_value_id" column_alias="Internal" filter="true" max_function="false" min_function="false" count_function="false" sum_function="false" avg_function="false"></PSRecordset><PSRecordset  report_id="1" column_id="2" column_name="notes_subject" columns="notes_subject" column_alias="notes_subject" filter="false" max_function="false" min_function="false" count_function="false" sum_function="false" avg_function="false"></PSRecordset></Root>'

DECLARE @sqlStmt VARCHAR(8000)
DECLARE @tempdetailtable varchar(100)
DECLARE @user_login_id varchar(100), @process_id varchar(50)

set @user_login_id = dbo.FNADBUser()

set @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @idoc int
DECLARE @sqlStmt1 varchar(5000)
DECLARE @sqlStmt2 varchar(5000)
DECLARE @error_num int 


exec sp_xml_preparedocument @idoc OUTPUT, @xmltext

SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH (
         report_id varchar(100)	'@report_id',      
		 column_id varchar(100)    '@column_id',
         column_selected varchar(50) '@column_selected',
		 column_name varchar (250)    '@column_name',
         columns varchar(250)    '@columns',
         column_alias varchar(250) '@column_alias',
         filter_column varchar(50) '@filter',
         max varchar(50) '@max_function',
         min varchar(50) '@min_function',
         count varchar(50) '@count_function',
         sum  varchar (50) '@sum_function',
         average varchar(50) '@avg_function',
		 report_column_id varchar(50) '@report_column_id',
		 data_type varchar(50) '@data_type',
		 control_type varchar(250) '@control_type',
		 data_source varchar(8000) '@data_source',
		 default_value varchar(500) '@default_value'
       )

UPDATE #ztbl_xmlvalue SET report_id=@report_id

SELECT * FROM #ztbl_xmlvalue

IF(@flag='u')
BEGIN

	BEGIN TRY
	SET @sqlStmt1 = 'UPDATE  report_writer_column
   
    					SET  
							 --report_writer_column.report_id = B.report_id ,
							 report_writer_column.column_id = B.column_id,
							 report_writer_column.column_selected = B.column_selected,
							 report_writer_column.column_name= B.column_name,
							 report_writer_column.columns= B.columns,
							 report_writer_column.column_alias = B.column_alias, 
							 report_writer_column.filter_column= B.filter_column,
							 report_writer_column.max= B.max,
							 report_writer_column.min= B.min,
							 report_writer_column.count= B.count,
							 report_writer_column.sum= B.sum,
							 report_writer_column.average= B.average,
							 report_writer_column.update_user= dbo.FNADBUser(),
							 report_writer_column.update_ts=getdate(),
							 report_writer_column.data_type = B.data_type,
							 report_writer_column.control_type = B.control_type ,
							 report_writer_column.data_source = B.data_source,
							 report_writer_column.default_value = B.default_value
									
						FROM report_writer_column A
					   INNER JOIN #ztbl_xmlvalue B ON A.report_id = ' + CAST(@report_id as varchar) 
						+ ' AND A.report_column_id = B.report_column_id ' 
                                      
						   
	--PRINT(@sqlStmt1)
    EXEC(@sqlStmt1)
    
    EXEC spa_ErrorHandler 0, 'report_writer_column', 
		'spa_report_column_definition', 'Success', 
		'Report Writer Columns successfully updated.',''
    
    END TRY
    BEGIN CATCH 
		SET @error_num = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_num, 'report_writer_column', 
		'spa_report_column_definition', 'DB Error', 
		'Error updating Report Writer Columns.', ''
    END CATCH

END
ELSE 
BEGIN		 

	BEGIN TRY
	SET	@sqlStmt2 = 'INSERT  INTO report_writer_column(
                                                       report_id
													   , column_id
													   , column_selected
													   , column_name
													   , [columns]
													   , column_alias
													   , filter_column
													   , [max]
													   , [min]
													   , [count]
													   , [sum]
													   , [average]
													   , [create_user]
													   , [create_ts]
													   , data_type
													   , control_type
													   , data_source 
													   , default_value)	

    												SELECT
													   '''+@report_id+''',
													   cast(X.column_id as int),
                                                       X.column_selected,
													   X.column_name,
													   X.columns,
													   X.column_alias, 
													   X.filter_column,
													   X.max,
													   X.min,
													   X.count,
													   X.sum,
													   X.average,
													   dbo.FNADBUser() create_user,
													   getdate()  create_ts,
													   X.data_type,
													   X.control_type,
													   X.data_source, 
													   X.default_value										
												FROM   #ztbl_xmlvalue  X
												--LEFT OUTER JOIN  report_writer_column Y   on X.report_id = Y.report_id 
												'
											          

	--PRINT(@sqlStmt2)
	EXEC(@sqlStmt2)
	
	EXEC spa_ErrorHandler 0, 'report_writer_column', 
		'spa_report_column_definition', 'Success', 
		'Report Writer Columns successfully inserted.',''

	END TRY
	BEGIN CATCH
		EXEC spa_print 'ERROR: ' --+ ERROR_MESSAGE()
		SET @error_num = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_num, 'report_writer_column', 
		'spa_report_column_definition', 'DB Error', 
		'Error inserting Report Writer Columns.', ''
	END CATCH
	
END












