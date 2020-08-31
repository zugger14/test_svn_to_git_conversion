
IF OBJECT_ID('[dbo].[spa_user_defined_deal_fields]','p') IS NOT NULL 
DROP PROC [dbo].[spa_user_defined_deal_fields]
GO

/**
	Used to process User defined deal fields
   
	Parameters:
	@flag					:	Operation flag that decides the action to be performed. Does not accept NULL.	
	@udf_deal_id 			:	User defined Deal Id
	@source_deal_header_id 	:	Deal Header Id
	@udf_template_id_list 	:	List of UDF template Ids
	@udf_value_list 		:	List of UDF values
	@disable_select 		:	Disable output message
*/

CREATE PROC [dbo].[spa_user_defined_deal_fields]
	@flag NCHAR(1),
	@udf_deal_id int=null,
	@source_deal_header_id int=null,
	@udf_template_id_list NVARCHAR(max)=null,
	@udf_value_list NVARCHAR(max)=null,
	@disable_select bit = 0
as
DECLARE @sql NVARCHAR(3000), @msg_err NVARCHAR(2000)
declare @stmt NVARCHAR(max)
declare @split_char NCHAR(1)

set @split_char = '|'

create table #t (id int IDENTITY (1,1) NOT NULL , num NVARCHAR(50) COLLATE DATABASE_DEFAULT)

select @stmt = 'insert into #t select '''+
		  replace(@udf_template_id_list, @split_char,''' union all select ''')
set @stmt = @stmt + ''''
exec spa_print @stmt
exec (@stmt)

SET @udf_value_list = replace(@udf_value_list,'''','''''')

create table #t2 (id int IDENTITY (1,1) NOT NULL , num NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)
select @stmt = 'insert into #t2 select '''+
	  replace(@udf_value_list,@split_char,''' union all select ''')
set @stmt = @stmt + ''''
exec spa_print @stmt
exec (@stmt)

EXEC spa_print @flag
BEGIN TRY

begin tran

			
	IF  @flag = 'i'
	BEGIN
	
		   --evaluate formula value for formula type udf field.
		   CREATE TABLE #temp_formula
			(
			  id INT,
			  formula NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			)
		   CREATE TABLE #temp_formula_value
			( 
			  id INT,
			  num NVARCHAR(100) COLLATE DATABASE_DEFAULT 
			)

			 -- extract formula parameters.
			 DECLARE @volume AS MONEY
			 SELECT TOP 1 @volume=deal_volume from source_deal_detail where source_deal_header_id=@source_deal_header_id and Leg=1 --term_start term_end


			DECLARE @sum_volume as money 
			select @sum_volume = sum(deal_volume) from source_deal_detail where source_deal_header_id = @source_deal_header_id AND Leg = 1

		   INSERT   INTO #temp_formula
					SELECT  t.id,
							dbo.FNAFormulaTextContract(sdh.entire_term_start, @volume, @sum_volume, 0, 0, fe.formula, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, sdd.source_deal_detail_id, 0, 0, sdh.entire_term_start,0)
					FROM    #t t
							INNER JOIN user_defined_deal_fields_template udft ON udft.udf_template_id = t.num
							LEFT JOIN formula_editor fe ON fe.formula_id = udft.formula_id
							INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = udft.udf_template_id
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
					WHERE   udft.Field_type = 'f' 
					and		sdh.source_deal_header_id = @source_deal_header_id



			--cursor on #temp_formula, insert evaluated value in #temp_formula_value
			   DECLARE @id INT,
				@formula NVARCHAR(MAX),
				@formula_stmt NVARCHAR(max)

			   DECLARE cur CURSOR
				FOR SELECT  id,
							formula
					FROM    #temp_formula  

			   OPEN cur  

			   FETCH NEXT FROM cur INTO @id, @formula  
			   WHILE @@FETCH_STATUS = 0  
				BEGIN  
					SET @formula_stmt = 'INSERT INTO #temp_formula_value(id,num) SELECT '
						+ CAST(@id AS NVARCHAR) + ',' + @formula ;
					EXEC (@formula_stmt)
					FETCH NEXT FROM cur INTO @id, @formula
				END  
			   CLOSE cur  
			   DEALLOCATE cur  

		   --end of evaluate formula value for formula type udf field.

		    --Updating UDF fields udf_value, in case of formula field, it should be recalculated for eg: 10*Volume
			set @stmt = 
			'
			UPDATE [dbo].[user_defined_deal_fields]
			   SET [udf_value] = CASE WHEN ISNULL(tfv.id,'''')<>'''' THEN tfv.num ELSE case t2.num when ''NULL'' then NULL else t2.num end END
			FROM [user_defined_deal_fields] uddf
				INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name  
				inner join #t t on udft.udf_template_id = t.num
				inner join #t2 t2 on t.id=t2.id
				LEFT JOIN #temp_formula_value tfv ON t.id=tfv.id
			WHERE [source_deal_header_id]='+cast(@source_deal_header_id as NVARCHAR)+'
						
			'
			EXEC spa_print @stmt
			exec(@stmt)			



			EXEC spa_print 'check1'
		
			set @stmt = 
			'INSERT INTO [dbo].[user_defined_deal_fields] (
				[source_deal_header_id],
				[udf_template_id],
				[udf_value]
			)
			SELECT '+CAST(@source_deal_header_id AS NVARCHAR)+',uddft.udf_template_id,CASE WHEN ISNULL(tfv.id,'''')<>'''' THEN tfv.num ELSE CASE t2.num WHEN ''NULL'' THEN NULL ELSE t2.num END END
			FROM   #t t
			       JOIN #t2 t2
			            ON  t.id = t2.id
			       INNER JOIN user_defined_fields_template udft
			            ON  t.num = udft.udf_template_id
			       INNER JOIN user_defined_deal_fields_template uddft
			            ON  udft.field_name = uddft.field_name
			
			LEFT JOIN #temp_formula_value tfv ON t.id=tfv.id
			where uddft.udf_template_id not in (
				select uddft2.udf_template_id 
				FROM [user_defined_deal_fields] uddf
					INNER JOIN user_defined_deal_fields_template uddft2
					ON uddf.udf_template_id = uddft2.udf_template_id
					INNER JOIN user_defined_fields_template udft2 
					ON udft2.field_name = udft2.field_name
					inner join #t t on udft2.udf_template_id = t.num
					inner join #t2 t2 on t.id=t2.id
				WHERE [source_deal_header_id]='+cast(@source_deal_header_id as NVARCHAR)+'
			)			
			'
			EXEC spa_print @stmt

			EXEC spa_print 'check2'
	
	END 




	DECLARE @msg NVARCHAR(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'

	IF @msg<> '' AND @disable_select <> 1
		Exec spa_ErrorHandler 0, 'user_defined_deal_fields table', 
				'spa_user_defined_deal_fields', 'Success', 
				@msg, ''
				
	COMMIT TRAN 
	
END TRY
BEGIN CATCH

	ROLLBACK TRAN 
	DECLARE @error_number int
	SET @error_number=error_number()
	SET @msg_err=''


	if @flag='i'
		SET @msg_err='Failed Inserting Data.'


	--SET  @msg_err=@msg_err +'(Err_No:' +cast(@error_number as NVARCHAR) + '; Description:' + error_message() +'.'
IF  @disable_select <> 1
		Exec spa_ErrorHandler @error_number, 'user_defined_deal_fields table', 
					'spa_user_defined_deal_fields', 'DB Error', 
					@msg_err, ''
					

END CATCH




