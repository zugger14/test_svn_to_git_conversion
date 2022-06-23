
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_user_defined_fields_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_user_defined_fields_template]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Generic stored procedure for UDF

	Parameters 
		@flag : 
			-i - Inserts UDF
			-u - Updates UDF
			-s - Returns UDF data according to different filters
			-t - Returns UDF data of deal
			-d - Deletes UDF
			-a - Returns UDF data of a particular UDF
			-g - Returns lists udfgroup and counts of udf fields inside that group, added for udf tabbing					   
			-c - Returns list charge type combo field data
		@udf_template_id : Udf Template Id
		@field_name : Field Name
		@field_label : Field Label
		@field_type : Field Type
		@data_type : Data Type
		@is_required : Is Required
		@sql_string : Sql String
		@source_deal_header_id : Source Deal Header Id
		@udf_type : Udf Type
		@udf_category : Udf Category
		@sequence : Sequence
		@field_size : Field Size
		@field_id : Field Id
		@default_value : Default Value
		@book_id : Book Id
		@udf_group : Udf Group
		@udf_tabgroup : Udf Tabgroup
		@formula_id : Formula Id
		@deleted_deal : Deleted Deal
		@internal_field_type : Internal Field Type
		@currency_field_id : Currency Field Id
		@window_id : Window Id
		@leg : Leg

*/



CREATE PROC [dbo].[spa_user_defined_fields_template]
	@flag NVARCHAR(1),
	@udf_template_id INT=null,
	@field_name NVARCHAR(50)=null,
	@field_label NVARCHAR(100)='',
	@field_type NVARCHAR(100)='',
	@data_type NVARCHAR(50)=null,
	@is_required NCHAR(1)='n',
	@sql_string NVARCHAR(500)='',
	@source_deal_header_id INT=NULL,
	@udf_type NCHAR(1)= NULL,
	@udf_category INT= NULL,
	@sequence int = NULL,
	@field_size int = NULL,
	@field_id int = NULL,
	@default_value NVARCHAR(500) = NULL,
	@book_id INT = NULL,
	@udf_group INT = NULL,
	@udf_tabgroup INT=NULL,
    @formula_id INT=NULL,
    @deleted_deal NVARCHAR(1) = 'n',
    @internal_field_type INT=NULL,    
    @currency_field_id INT=NULL,
    @window_id INT = NULL ,
    @leg INT = NULL
as

DECLARE @Sql_Select NVARCHAR(3000), @msg_err NVARCHAR(2000)
declare @stmt NVARCHAR(max)
DECLARE @tmp_field_name int

set @sql_string = isnull(@sql_string,'')

EXEC spa_print @flag
BEGIN try

	IF  @flag = 'i'
		BEGIN			
			IF EXISTS(
				   SELECT 1
				   FROM   user_defined_fields_template udft
				   WHERE  udft.Field_label = @field_label
				   AND udft.udf_type = @udf_type
			   )
			BEGIN
				EXEC spa_ErrorHandler -1,
					 'The Selected Field Name Already Exists.',
					 'spa_user_defined_fields_template',
					 'DB Error',
					 'The Selected Field Label Already Exists.',
					 ''
			    
				RETURN
			END
			
			IF EXISTS(SELECT 1 FROM maintain_field_deal mfd WHERE mfd.default_label = @field_label)
			BEGIN
				 EXEC spa_ErrorHandler -1,
			         'The Selected Field Name Already Used As System Field Label.',
			         'spa_user_defined_fields_template',
			         'DB Error',
			         'The Selected Field Name Already Used As System Field Label.',			         
			         ''
			    
			    RETURN
			END
			
		SELECT  @tmp_field_name= count(field_name) FROM [dbo].[user_defined_fields_template]
				WHERE field_name=ltrim(rtrim(@field_name))
		
		IF(@tmp_field_name=0)
		BEGIN

				INSERT INTO [dbo].[user_defined_fields_template]
					(
					[field_name]
					,[field_label]
					,[field_type]
					,[data_type]
					,[is_required]
					,[sql_string]
					,[udf_type]
					,[udf_category]
					,[sequence]
					,[field_size]
					,[field_id]
					,[udf_group]
					,[default_value]
					,[book_id]
					,[udf_tabgroup]
					,[formula_id]
					,[internal_field_type]
					,[currency_field_id]
					,[window_id]
					,leg
				)
				VALUES
				(
					@field_name
					,@field_label
					,@field_type
					,@data_type
					,@is_required
					,@sql_string
					,@udf_type
					,@udf_category
					,@sequence
					,@field_size
					,@field_id
					,@udf_group
					,@default_value 
					,@book_id
					,@udf_tabgroup
					,@formula_id
					,@internal_field_type
					,@currency_field_id
					,@window_id
					,@leg
				)
				
					
		END
	 ELSE
		BEGIN
			EXEC spa_ErrorHandler -1, 'The Selected Field Name Already Exists.', 
				 'spa_user_defined_fields_template', 'DB Error', 
				 'The Selected Field Name Already Exists.',''
		
		END
	END
	ELSE IF  @flag = 'u'
		BEGIN
			
			IF EXISTS(
			       SELECT 1
			       FROM   user_defined_fields_template udft
			       WHERE  udft.Field_label = @field_label
			              AND udft.udf_template_id <> @udf_template_id
			              AND udft.udf_type = @udf_type
			   )
			BEGIN
			    EXEC spa_ErrorHandler -1,
			         'The Selected Field Name Already Exists.',
			         'spa_user_defined_fields_template',
			         'DB Error',
			         'The Selected Field Label Already Exists.',
			         ''
			    
			    RETURN
			END 	
			
			IF EXISTS(SELECT 1 FROM maintain_field_deal mfd WHERE mfd.default_label = @field_label)
			BEGIN
				 EXEC spa_ErrorHandler -1,
			         'The Selected Field Name Already Used As System Field Label.',
			         'spa_user_defined_fields_template',
			         'DB Error',
			         'The Selected Field Name Already Used As System Field Label.',			         
			         ''
			    
			    RETURN
			END
			
			
			SELECT  @tmp_field_name= count(field_name) FROM [dbo].[user_defined_fields_template]
				WHERE field_name=ltrim(rtrim(@field_name))
				AND   udf_template_id<>@udf_template_id
			
			IF(@tmp_field_name=0)
			BEGIN
				--IF NOT EXISTS(
	   --             SELECT 1
	   --             FROM   maintain_field_template_detail mftd
	   --             WHERE  mftd.udf_or_system = 'u'
	   --                    AND mftd.field_id = @udf_template_id
	   --         )
				--BEGIN	
					IF @field_type <> 'w'
						SET @formula_id = NULL
									
					UPDATE [dbo].[user_defined_fields_template]
					   SET 
						  [field_name] = @field_name
						  ,[field_label] = @field_label
						  ,[field_type] = @field_type
						  ,[data_type] = @data_type
						  ,[is_required] = @is_required
						  ,[sql_string] = @sql_string
						  ,[udf_type] = @udf_type
						  ,[udf_category] = @udf_category
						  ,[sequence] = @sequence
						  ,[field_size] = @field_size
						  ,[field_id] = @field_id
						  ,[udf_group] = @udf_group
						  ,[udf_tabgroup] = @udf_tabgroup
						  ,[default_value] = @default_value
						  ,[book_id] = @book_id
						  ,[formula_id] = @formula_id					  
						  ,[internal_field_type] = @internal_field_type
						  ,[currency_field_id] = @currency_field_id
						  ,[window_id] = @window_id
						  ,[leg] = @leg
						  
						 WHERE udf_template_id = @udf_template_id
						 
						 UPDATE user_defined_deal_fields_template_main
						 SET    internal_field_type = @internal_field_type
						 WHERE  field_name = @field_name
				END
				--ELSE
				--BEGIN
	   --          EXEC spa_ErrorHandler -1,
	   --               'Maintain UDF Template',
	   --               'spa_user_defined_fields_template',
	   --               'error',
	   --               'UDF is already in use.',
	   --               ''
				--END
			--END
		ELSE
			BEGIN
				EXEC spa_ErrorHandler -1, 'The Selected Field Name Already Exists.', 
				 'spa_user_defined_fields_template', 'DB Error', 
				 'The Selected Field Name Already Exists.',''
			END
	END
	ELSE IF  @flag = 's'
	begin
		set @Sql_Select=' 	
		SELECT DISTINCT s.[udf_template_id] [UDF Template ID]
			  ,replace(sdv.code,'' '',''_'') [Field Name]
			  ,[field_label] [Field Label]
			  ,[field_type] [Field Type]
			  ,[data_type] [Data Type]
			 -- ,[is_required] [Is Required]
			  ,ISNULL(NULLIF(s.sql_string, ''''), uds.sql_string) [SQL String]'


		set @Sql_Select = @Sql_Select + 
			case when @source_deal_header_id is null then ',NULL [Field Value]' else 
			',f.[udf_value] [Field Value]' end

		set @Sql_Select = @Sql_Select + ' 
			  ,[udf_type] [UDF Type]
			  ,[sequence] [Sequence]
			  ,[field_size] [Field Size]
			  ,s.[field_id] [Field Id]
			  ,CASE WHEN [field_type] = ''a'' THEN dbo.FNADateFormat(s.[default_value]) ELSE s.[default_value] END [Default Value]
			  ,s.[udf_group] [UDF Group]  
			  ,ph.[entity_name] [Entity Name]
			  ,ISNULL(sdv_udf.code,''UDF Fields'') [UDF Grouping]
			  ,fe.formula [Formula]
			  ,sdv_ift.code [Internal Field Type]
			  ,sc.code [Currency Field]
			  ,s.window_id [Window ID]
			  ,CASE WHEN mftd.field_template_id IS NULL THEN ''No'' ELSE ''Yes'' END [Used]
		  FROM [dbo].[user_defined_fields_template] s
			inner join static_data_value sdv on s.field_id=sdv.value_id
			LEFT JOIN static_data_value sdv_udf ON s.[udf_tabgroup]=sdv_udf.value_id
			left join portfolio_hierarchy ph on s.book_id = ph.entity_id
			LEFT JOIN formula_editor fe ON fe.formula_id=s.formula_id 
			LEFT JOIN static_data_value sdv_ift ON sdv_ift.value_id=s.internal_field_type 
			LEFT JOIN static_data_value sc ON sc.value_id=s.currency_field_id			 
			LEFT JOIN maintain_field_template_detail mftd ON mftd.field_id = s.udf_template_id AND mftd.udf_or_system = ''u''
			LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = s.data_source_type_id
			'  + 

			case when @source_deal_header_id is null then '' else '
						left join '+ CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_user_defined_deal_fields' ELSE 'user_defined_deal_fields' END +' f on s.udf_template_id = f.udf_template_id and source_deal_header_id=' + cast(@source_deal_header_id as NVARCHAR) 
			end

			set @Sql_Select = @Sql_Select + ' where 1=1 '

			
		if @udf_type is not null
			set @Sql_Select = @Sql_Select + '
				and udf_type = '''+cast(@udf_type as NVARCHAR)+'''
			'

		if @book_id is not null
			set @Sql_Select = @Sql_Select + '
				and (book_id = '''+cast(@book_id as NVARCHAR)+''' OR book_id  is null)'

		set @Sql_Select = @Sql_Select + ' order by [UDF Grouping],sequence'  --order of [UDF Grouping] need to be same on 's','l' and 'g' option.

--		if @source_system_id is not null 
--			set @Sql_Select=@Sql_Select +  ' where s.source_system_id='+convert(NVARCHAR(20),@source_system_id)
		exec spa_print @Sql_Select
		exec(@Sql_Select)
	end

	ELSE IF  @flag = 't'
	begin
			set @Sql_Select=' 	
				SELECT udft.[udf_template_id] [UDF Template ID]
					  ,sdht.[template_name] [Template Name]
					  ,replace(sdv.code,'' '',''_'') [Field Name]
					  ,[field_label] [Field Label]
					  ,[field_type] [Field Type]
					  ,[data_type] [Data Type]
					  ,[is_required] [Is Required]
					  ,ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string) [SQL String]
					  ,udf.[udf_value] [Field Value]
					  ,[udf_type] [UDF Type]
					  ,[sequence] [Sequence]
					  ,[field_size] [Field Size]
					  ,[field_id] [Field Id]
					  ,CASE WHEN [field_type] = ''a'' THEN dbo.FNADateFormat(udf.[udf_value]) ELSE udf.[udf_value] END [Default Value]
					  ,[udf_group] [UDF Group]
					  ,[book_id] [Book Id]	
					  ,ISNULL(sdv_udf.code,''UDF Fields'') [UDF Grouping]
					  ,fe.formula [Formula]
					  ,sdv_ift.code [Internal Field Type]
					  ,sc.code [Currency Field]
					  ,udft.window_id [Window ID]
				FROM '
					+ CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_source_deal_header' ELSE 'source_deal_header' END + ' sdh ' +
					'INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_fields_template udft ON udft.template_id = sdh.template_id
					LEFT JOIN ' + CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_user_defined_deal_fields' ELSE 'user_defined_deal_fields' END + 
					' udf ON udf.udf_template_id = udft.udf_template_id AND udf.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
					LEFT JOIN static_data_value sdv_udf ON udf_tabgroup = sdv_udf.value_id
					LEFT JOIN formula_editor fe ON fe.formula_id=udft.formula_id
					LEFT JOIN static_data_value sdv_ift ON sdv_ift.value_id=s.internal_field_type 
					LEFT JOIN static_data_value sc ON sc.value_id=s.currency_field_id
					LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id'
		+' where 1=1 '
		+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id='+CAST(@source_deal_header_id AS NVARCHAR)+')' ELSE '' END

		

		if @udf_type is not null
			set @Sql_Select = @Sql_Select + '
				and udf_type = '''+cast(@udf_type as NVARCHAR)+'''
			'
		
		if @book_id is not null
			set @Sql_Select = @Sql_Select + '
				and (book_id = '''+cast(@book_id as NVARCHAR)+''' OR book_id  is null)'
		

		set @Sql_Select = @Sql_Select + ' order by [UDF Grouping],sequence' --order of [UDF Grouping] need to be same on 's','l' and 'g' option.
		
		exec spa_print @Sql_Select
		exec(@Sql_Select)
	end

	ELSE IF @flag = 'd'
	     BEGIN
	         IF NOT EXISTS(
	                SELECT 1
	                FROM   maintain_field_template_detail mftd
	                WHERE  mftd.udf_or_system = 'u'
	                       AND mftd.field_id = @udf_template_id
	            )
	             DELETE [dbo].[user_defined_fields_template]
	             WHERE  udf_template_id = @udf_template_id
	         ELSE
	         BEGIN
	             EXEC spa_ErrorHandler -1,
	                  'Maintain UDF Template',
	                  'spa_user_defined_fields_template',
	                  'error',
	                  'UDF is already in use.',
	                  ''
	         END
	         
	         IF EXISTS(
	                SELECT *
	                FROM   formula_breakdown fb
	                       INNER JOIN user_defined_fields_template udft
	                            ON  fb.arg1 = udft.field_name
	                            AND fb.func_name IN ('UDFValue', 'FieldValue')
	                WHERE  udft.udf_template_id = @udf_template_id
	            )
	         BEGIN
	             EXEC spa_ErrorHandler -1,
	                  'Maintain UDF Template',
	                  'spa_user_defined_fields_template',
	                  'error',
	                  'UDF is used in formula.',
	                  ''
	             
	             RETURN
	         END

	END 		
	ELSE IF  @flag = 'a'	
	
		SELECT [udf_template_id]
			  ,[field_name]
			  ,[field_label]
			  ,[field_type]	
			  ,[data_type]
			  ,[is_required]
			  ,ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) [sql_string]
			  ,[udf_type]
			  ,[sequence]
			  ,[field_size]
			  ,[field_id]
			  ,default_value
			  ,[udf_group]
			  ,[udf_tabgroup]
			  ,udft.formula_id
			  ,fe.formula [Formula]
			  ,internal_field_type [Internal Field Type]
			  ,currency_field_id [Currency Field ID]
			  ,window_id [Window ID]
			  , leg
			  , [udf_category]
		  FROM [dbo].[user_defined_fields_template] udft
			LEFT JOIN formula_editor fe ON fe.formula_id = udft.formula_id
			LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE udf_template_id = @udf_template_id
		
		ELSE IF @flag = 'g' --lists udfgroup and counts of udf fields inside that group, added for udf tabbing.
		  BEGIN
			SELECT  ISNULL(sdv.code, 'UDF Fields') [UDF Grouping],
					COUNT(udf_template_id) [Counts]
			FROM    [user_defined_fields_template] uddft
					LEFT JOIN static_data_value sdv ON udf_tabgroup = sdv.value_id
					INNER JOIN static_data_value sdv2 ON sdv2.value_id = uddft.field_name
			
			GROUP BY sdv.code
			ORDER BY [UDF Grouping] --order of [UDF Grouping] need to be same on 's','l' and 'g' option.
		  END
	
	ELSE IF  @flag = 'c'
		BEGIN
			SELECT DISTINCT field_name [Value ID], Field_label [code]
		  	FROM [dbo].[user_defined_fields_template] udft
			WHERE (udft.is_active = 'y' AND udft.deal_udf_type IN ('c','p')) OR udft.field_name = -5500
		END

	DECLARE @msg NVARCHAR(2000)
	SELECT @msg = ''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg <> ''
		Exec spa_ErrorHandler 0, 'user_defined_fields_template table', 
				'spa_user_defined_fields_template', 'Success', 
				@msg, ''
END try
begin catch
	DECLARE @error_number int
	SET @error_number=error_number()
	SET @msg_err=''


	if @flag='i'
		SET @msg_err='Fail Insert Data.'
	ELSE if @flag='u'
		SET @msg_err='Fail Update Data.'
	ELSE if @flag='d'
		SET @msg_err='Fail Delete Data.'


	--SET  @msg_err=@msg_err +'(Err_No:' +cast(@error_number as NVARCHAR) + '; Description:' + error_message() +'.'
		Exec spa_ErrorHandler @error_number, 'user_defined_fields_template table', 
					'spa_user_defined_fields_template', 'DB Error', 
					@msg_err, ''
END catch






GO

