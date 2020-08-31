
IF OBJECT_ID(N'[dbo].[spa_user_defined_deal_fields_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_user_defined_deal_fields_template]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Generic stored procedure for user defined field

	Parameters 
	@flag : 
		- i - Inserts UDF
		- u - Updated UDF
		- h - Returns header UDF value of a deal
		- s - Returns UDF info 
		- t - Returns UDF info a deal
		- d - Deletes UDF
		- a - Returns UDF info of a particular UDF
		- g - Returns lists of udfgroup and counts of udf fields inside that group, added for udf tabbing	
	@udf_template_id : Udf Template Id
	@template_id : Template Id
	@field_name : Field Name
	@field_label : Field Label
	@field_type : Field Type
	@data_type : Data Type
	@is_required : Is Required
	@sql_string : Sql String
	@source_deal_header_id : Source Deal Header Id
	@udf_type : Udf Type
	@sequence : Sequence
	@field_size : Field Size
	@field_id : Field Id
	@default_value : Default Value
	@book_id : Book Id
	@udf_group : Udf Group
	@udf_tabgroup : Udf Tabgroup
	@formula_id : Formula Id
	@deleted_deal : Deleted Deal

*/


CREATE PROC [dbo].[spa_user_defined_deal_fields_template]
	@flag NVARCHAR(1),
	@udf_template_id INT=NULL,
	@template_id INT=NULL,
	@field_name NVARCHAR(50)=NULL,
	@field_label NVARCHAR(50)='',
	@field_type NVARCHAR(100)='',
	@data_type NVARCHAR(50)=NULL,
	@is_required NCHAR(1)='n',
	@sql_string NVARCHAR(500)='',
	@source_deal_header_id INT=NULL,
	@udf_type NCHAR(1)= NULL,
	@sequence INT = NULL,
	@field_size INT = NULL,
	@field_id INT = NULL,
	@default_value NVARCHAR(500) = NULL,
	@book_id INT = NULL,
	@udf_group INT = NULL,
	@udf_tabgroup INT=NULL,
    @formula_id INT=NULL,
    @deleted_deal NVARCHAR(1) = 'n'
AS

DECLARE @Sql_Select NVARCHAR(3000), @msg_err NVARCHAR(2000)
DECLARE @stmt NVARCHAR(max)
DECLARE @tmp_field_name INT

SET @sql_string = ISNULL(@sql_string,'')

EXEC spa_print @flag
BEGIN TRY

	IF  @flag = 'i'
		BEGIN
			SELECT  @tmp_field_name= count(field_name) FROM [dbo].[user_defined_deal_fields_template]
				WHERE field_name=LTRIM(RTRIM(@field_name))
			--	AND	  template_id=@template_id
		
		IF(@tmp_field_name=0)
		BEGIN

				INSERT INTO [dbo].[user_defined_deal_fields_template]
					(
					--[template_id]
					[field_name]
					,[Field_label]
					,[Field_type]
					,[data_type]
					,[is_required]
					,[sql_string]
					,[udf_type]
					,[sequence]
					,[field_size]
					,[field_id]
					,[udf_group]
					,[default_value]
					,[book_id]
					,[udf_tabgroup]
					,[formula_id]
				)
				VALUES
				(
					 --@template_id
					@field_name
					,@field_label
					,@field_type
					,@data_type
					,@is_required
					,@sql_string
					,@udf_type
					,@sequence
					,@field_size
					,@field_id
					,@udf_group
					,@default_value 
					,@book_id
					,@udf_tabgroup
					,@formula_id
				)
				
--				IF @@ERROR <> 0
--					EXEC spa_ErrorHandler @@ERROR, 'User Defined Deal Fields Template  Table', 
--							'spa_user_defined_deal_fields_template', 'DB Error', 
--							'Failed inserting Data.', ''
--				ELSE
--					EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
-- 							'spa_sourcedealtemp', 'Success', 
--							'Data insert Success', ''					
		END
	 ELSE
		BEGIN
			EXEC spa_ErrorHandler -1, "The Selected field name Already Exists.", 
				 "spa_user_defined_deal_fields_template", "DB ERROR", 
				 "The Selected field name Already Exists.",''
		
		END
	END
	ELSE IF  @flag = 'u'
		BEGIN
			SELECT  @tmp_field_name= count(field_name) FROM [dbo].[user_defined_deal_fields_template]
				WHERE field_name=LTRIM(RTRIM(@field_name))
				--AND	  template_id=@template_id
				AND   udf_template_id<>@udf_template_id


			IF(@tmp_field_name=0)
			BEGIN

--
--				SET @stmt = '
--				UPDATE [dbo].[user_defined_deal_fields_template]
--				   SET [template_id] ='+CAST((isnull(@template_id, '')) AS NVARCHAR)+'
--					  ,[field_name] ='''+isnull(@field_name,'')+'''
--					  ,[field_label] ='''+isnull(@field_label, '')+'''
--					  ,[field_type] ='''+isnull(@field_type, '')+'''
--					  ,[data_type] ='''+isnull(@data_type, '')+'''
--					  ,[is_required] ='''+isnull(@is_required, '')+'''
--					  ,[sql_string] ='''+isnull(@sql_string, '')+'''
--					  ,[udf_type] = '''+isnull(@udf_type, '')+'''
--					  ,[sequence] = '+CAST((isnull(@sequence, '')) AS NVARCHAR)+' 
--					  ,[field_size] = '+CAST((isnull(@field_size, '')) AS NVARCHAR)+'
--					  ,[field_id] = '+CAST((isnull(@field_id, '')) AS NVARCHAR)+'
--					  ,[udf_group] = ' + CASE WHEN @udf_group IS NULL THEN 'NULL' ELSE CAST(@udf_group AS NVARCHAR) END +'
--					  ,[udf_tabgroup] = ' + CASE WHEN @udf_tabgroup IS NULL THEN 'NULL' ELSE CAST(@udf_tabgroup AS NVARCHAR) END +'
--					  ,[default_value] = '''+isnull(@default_value, '')+'''
--					  ,[book_id] = ' + CASE WHEN @book_id IS NULL THEN 'NULL' ELSE CAST(@book_id AS NVARCHAR) END +'
--					  ,[formula_id] = '+CAST((ISNULL(@formula_id, 'NULL')) AS NVARCHAR)+'
--					 WHERE udf_template_id='+CAST((isnull(@udf_template_id, '')) AS NVARCHAR)+'
--				'
--				EXEC spa_print @stmt
--				EXEC(@stmt)
				
				
				UPDATE [dbo].[user_defined_deal_fields_template]
				   SET 
				   --[template_id] = @template_id
					  [field_name] = @field_name
					  ,[Field_label] = @field_label
					  ,[Field_type] = @field_type
					  ,[data_type] = @data_type
					  ,[is_required] = @is_required
					  ,[sql_string] = @sql_string
					  ,[udf_type] = @udf_type
					  ,[sequence] = @sequence
					  ,[field_size] = @field_size
					  ,[field_id] = @field_id
					  ,[udf_group] = @udf_group
					  ,[udf_tabgroup] = @udf_tabgroup
					  ,[default_value] = @default_value
					  ,[book_id] = @book_id
					  ,[formula_id] = @formula_id
					 WHERE udf_template_id= @udf_template_id
				
			END
		ELSE
			BEGIN
				EXEC spa_ErrorHandler -1, "The Selected field name Already Exists.", 
				 "spa_user_defined_deal_fields_template", "DB ERROR", 
				 "The Selected field name Already Exists.",''
			END
	END
	ELSE IF @flag='h'
	BEGIN 			
				SELECT udft.udf_template_id udf_template_id,
		       uddf.udf_value
		FROM   user_defined_deal_fields uddf
		       JOIN user_defined_deal_fields_template uddft
		            ON  uddf.udf_template_id = uddft.udf_template_id
		       JOIN user_defined_fields_template udft
		            ON  udft.field_name = uddft.field_name
		WHERE  source_deal_header_id = @source_deal_header_id 
	END 

	ELSE IF  @flag = 's'
	BEGIN
		SET @Sql_Select=' 	
		SELECT s.[udf_template_id] [UDF Template ID]
			  --,t.[template_name] [Template Name]
			  ,replace(sdv.code,'' '',''_'') [Field Name]
			  ,[field_label] [Field Label]
			  ,[field_type] [Field Type]
			  ,[data_type] [Data Type]
			  ,[is_required] [Is Required]
			  ,[sql_string] [SQL String]'


		SET @Sql_Select = @Sql_Select + 
			CASE WHEN @source_deal_header_id IS NULL THEN ',NULL [Field Value]' ELSE 
			',f.[udf_value] [Field Value]' END

		SET @Sql_Select = @Sql_Select + ' 
			  ,[udf_type] [UDF Type]
			  ,[sequence] [Sequence]
			  ,[field_size] [Field Size]
			  ,[field_id] [Field Id]
			  ,[default_value] [Default Value]
			  ,s.[udf_group] [UDF Group]  
			  ,ph.[entity_name] [Entity Name]
			  ,ISNULL(sdv_udf.code,''UDF Fields'') [UDF Grouping]
			  ,fe.formula [Formula]
		  FROM [dbo].[user_defined_deal_fields_template] s
			--inner join source_deal_header_template t on s.template_id=t.template_id 
			inner join static_data_value sdv on s.field_id=sdv.value_id
			LEFT JOIN static_data_value sdv_udf ON s.[udf_tabgroup]=sdv_udf.value_id
			left join portfolio_hierarchy ph on s.book_id = ph.entity_id
			LEFT JOIN formula_editor fe ON fe.formula_id=s.formula_id'  + 

			CASE WHEN @source_deal_header_id IS NULL THEN '' ELSE '
						left join '+ CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_user_defined_deal_fields' ELSE 'user_defined_deal_fields' END +' f on s.udf_template_id = f.udf_template_id and source_deal_header_id=' + CAST(@source_deal_header_id AS NVARCHAR) 
			END

			SET @Sql_Select = @Sql_Select + ' where 1=1 '


		IF @template_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and t.template_id = '+CAST(@template_id AS NVARCHAR)+'
			'
		IF @udf_type IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and udf_type = '''+CAST(@udf_type AS NVARCHAR)+'''
			'

		IF @book_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and (book_id = '''+CAST(@book_id AS NVARCHAR)+''' OR book_id  is null)'

		SET @Sql_Select = @Sql_Select + ' order by [UDF Grouping],sequence'  --order of [UDF Grouping] need to be same on 's','l' and 'g' option.

--		if @source_system_id is not null 
--			set @Sql_Select=@Sql_Select +  ' where s.source_system_id='+convert(NVARCHAR(20),@source_system_id)
		exec spa_print @Sql_Select
		EXEC(@Sql_Select)
	END

	ELSE IF  @flag = 't'
	BEGIN
			SET @Sql_Select=' 	
				SELECT udft.[udf_template_id] [UDF Template ID]
					  ,sdht.[template_name] [Template Name]
					  ,replace(sdv.code,'' '',''_'') [Field Name]
					  ,[field_label] [Field Label]
					  ,[field_type] [Field Type]
					  ,[data_type] [Data Type]
					  ,[is_required] [Is Required]
					  ,[sql_string] [SQL String]
					  ,udf.[udf_value] [Field Value]
					  ,[udf_type] [UDF Type]
					  ,[sequence] [Sequence]
					  ,[field_size] [Field Size]
					  ,[field_id] [Field Id]
					  ,udf.[udf_value] [Default Value]
					  ,[udf_group] [UDF Group]
					  ,[book_id] [Book Id]	
					  ,ISNULL(sdv_udf.code,''UDF Fields'') [UDF Grouping]
					  ,fe.formula [Formula]
				FROM '
					+ CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_source_deal_header' ELSE 'source_deal_header' END + ' sdh ' +
					'INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_deal_fields_template udft ON udft.template_id = sdh.template_id
					LEFT JOIN ' + CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_user_defined_deal_fields' ELSE 'user_defined_deal_fields' END + 
					' udf ON udf.udf_template_id = udft.udf_template_id AND udf.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
					LEFT JOIN static_data_value sdv_udf ON udf_tabgroup = sdv_udf.value_id
					LEFT JOIN formula_editor fe ON fe.formula_id=udft.formula_id'

		+' where 1=1 '
		+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id='+CAST(@source_deal_header_id AS NVARCHAR)+')' ELSE '' END

		IF @template_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and sdht.template_id = '+CAST(@template_id AS NVARCHAR)+'
			'

		IF @udf_type IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and udf_type = '''+CAST(@udf_type AS NVARCHAR)+'''
			'
		
		IF @book_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + '
				and (book_id = '''+CAST(@book_id AS NVARCHAR)+''' OR book_id  is null)'
		

		SET @Sql_Select = @Sql_Select + ' order by [UDF Grouping],sequence' --order of [UDF Grouping] need to be same on 's','l' and 'g' option.
		
		exec spa_print @Sql_Select
		EXEC(@Sql_Select)
	END

	ELSE IF  @flag = 'd'
	
		DELETE [dbo].[user_defined_deal_fields_template] WHERE udf_template_id = @udf_template_id
		
	ELSE IF  @flag = 'a'	
	
		SELECT [udf_template_id]
			  --,[template_id]
			  ,[field_name]
			  ,[Field_label]
			  ,[Field_type]
			  ,[data_type]
			  ,[is_required]
			  ,[sql_string]
			  ,[udf_type]
			  ,[sequence]
			  ,[field_size]
			  ,[field_id]
			  ,[default_value]
			  ,[book_id]
			  ,[udf_group]
			  ,[udf_tabgroup]
			  ,udft.formula_id
			  ,fe.formula [Formula]
		  FROM [dbo].[user_defined_deal_fields_template] udft
			LEFT JOIN formula_editor fe ON fe.formula_id = udft.formula_id
			WHERE udf_template_id = @udf_template_id
		
		ELSE IF @flag = 'g' --lists udfgroup and counts of udf fields inside that group, added for udf tabbing.
		  BEGIN
			SELECT  ISNULL(sdv.code, 'UDF Fields') [UDF GROUPING],
					count(udf_template_id) [Counts]
			FROM    [user_defined_deal_fields_template] uddft
					LEFT JOIN static_data_value sdv ON udf_tabgroup = sdv.value_id
					INNER JOIN static_data_value sdv2 ON sdv2.value_id = uddft.field_name
			WHERE   template_id = @template_id
			GROUP BY sdv.code
			ORDER BY [UDF GROUPING] --order of [UDF Grouping] need to be same on 's','l' and 'g' option.
		  END

	DECLARE @msg NVARCHAR(2000)
	SELECT @msg = ''
	IF @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE IF @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE IF @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg <> ''
		EXEC spa_ErrorHandler 0, 'user_defined_deal_fields_template table', 
				'spa_user_defined_deal_fields_template', 'Success', 
				@msg, ''
END TRY
BEGIN CATCH
	DECLARE @error_number INT
	SET @error_number=ERROR_NUMBER()
	SET @msg_err=''


	IF @flag='i'
		SET @msg_err='Fail Insert Data.'
	ELSE IF @flag='u'
		SET @msg_err='Fail Update Data.'
	ELSE IF @flag='d'
		SET @msg_err='Fail Delete Data.'


	--SET  @msg_err=@msg_err +'(Err_No:' +cast(@error_number as NVARCHAR) + '; Description:' + error_message() +'.'
		EXEC spa_ErrorHandler @error_number, 'user_defined_deal_fields_template table', 
					'spa_user_defined_deal_fields_template', 'DB Error', 
					@msg_err, ''
END CATCH






GO


