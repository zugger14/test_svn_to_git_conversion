
IF OBJECT_ID(N'spa_template_deal_field_format', N'P') IS NOT NULL
	DROP  PROC [dbo].[spa_template_deal_field_format]  
GO 
CREATE PROC [dbo].[spa_template_deal_field_format]  
@flag CHAR(1),  
@template_id INT,
@group_id INT = NULL ,
@deal_template_id INT=NULL,
@call_window INT=NULL  ---- 1 == deal template : 2 == deal update
AS  

DECLARE @sql VARCHAR(8000)
IF @call_window IS NULL
SET @call_window=-1

IF @flag = 'g'  
BEGIN
	SELECT field_group_id, group_name,REPLACE(group_name,' ','')+'_'+CAST(field_group_id AS VARCHAR) ID FROM maintain_field_template_group WHERE field_template_id=@template_id  
	ORDER BY seq_no  
END  
IF @flag = 'h'
BEGIN
	SELECT group_id, group_name,REPLACE(group_name,' ','')+'_'+CAST(group_id AS VARCHAR) ID FROM maintain_field_template_group_detail WHERE field_template_id=@template_id  
	ORDER BY seq_no
END
 
IF @flag = 'f'   -- populates header portion of deal template
BEGIN   
	--- call from Template window then return only those fields which are in Deal Templates
	IF @call_window=1 
	BEGIN 
		SELECT column_name INTO #temp_header FROM INFORMATION_SCHEMA.Columns WHERE TABLE_NAME = 'source_deal_header_template' 
	END
	
	SET @sql = 'SELECT *
	            FROM   (
	                       SELECT LOWER(f.farrms_field_id) farrms_field_id,
	                              field_group_id,
	                              (CASE 
								    WHEN d.field_caption = ''book1'' OR mfd.farrms_field_id = ''source_system_book_id1'' THEN ISNULL(sbmc.group1,''Group1'')
									WHEN d.field_caption = ''book2'' OR mfd.farrms_field_id = ''source_system_book_id2'' THEN ISNULL(sbmc.Group2,''Group2'')
									WHEN d.field_caption = ''book3'' OR mfd.farrms_field_id = ''source_system_book_id3'' THEN ISNULL(sbmc.Group3,''Group3'')
									WHEN d.field_caption = ''book4'' OR mfd.farrms_field_id = ''source_system_book_id4'' THEN ISNULL(sbmc.Group4,''Group4'')
	                              ELSE ISNULL(d.field_caption, f.default_label) END) default_label,
	                              ISNULL(f.field_type, ''t'') field_type,
	                              f.[data_type],
	                              f.[default_validation],
	                              f.[header_detail],
	                              f.[system_required],
	                              f.[sql_string],
	                              f.[field_size],
	                              CASE 
	                                   WHEN '+CAST(@call_window AS VARCHAR) +' = 1 THEN ''n''
	                                   ELSE COALESCE(d.is_disable, f.[is_disable], ''n'')
	                              END is_disable,
	                              f.window_function_id,
	                              ''s'' udf_or_system,
	                              CASE 
	                                   WHEN ISNULL(d.hide_control, ''n'') = ''y'' or ISNULL(d.update_required, ''n'') = ''n'' THEN d.seq_no + 100
	                                   ELSE d.seq_no
	                              END seq_no,
	                              ISNULL(d.hide_control, ''n'') hide_control,
	                              --CASE 
	                              --     WHEN f.field_type = ''a'' THEN dbo.FNADateFormat(d.default_value)
	                              --     ELSE d.default_value
	                              --END 
	                              d.default_value,
	                              CAST(f.field_id AS VARCHAR) field_id,
	                              d.update_required,
	                              d.value_required
	                       FROM   maintain_field_template_detail d
								  INNER JOIN maintain_field_deal mfd ON d.field_id = mfd.field_id 
	                              JOIN maintain_field_deal f
	                                   ON  d.field_id = f.field_id
								  OUTER APPLY source_book_mapping_clm sbmc
								'   
	IF @call_window=1
	BEGIN 
		SET @sql = @sql + '	join #temp_header t on case when t.column_name=''buy_sell_flag'' then ''header_buy_sell_flag'' else t.column_name end  =f.farrms_field_id '
	END 
	
	SET @sql = @sql + '	WHERE field_group_id is not null and f.header_detail=''h'' AND ISNULL(d.udf_or_system,''s'')=''s''  AND d.field_template_id = ' + CAST(@template_id AS VARCHAR) 
	/*
	IF @call_window <> 1
	begin 
		set @sql = @sql + ' AND ISNULL(d.update_required,''n'')=''y'''
	end 
	*/  

	
	IF @group_id IS NOT NULL
		SET @sql = @sql + ' AND d.field_group_id = ' + CAST(@group_id AS VARCHAR)
	
	IF @call_window = 1 
		SET @sql = @sql + ' AND f.farrms_field_id != ''template_id'''
	
	SET @sql = @sql + '	
	UNION ALL 	
	SELECT ''UDF___'' + CAST(udf_template_id AS VARCHAR) udf_template_id,
	       field_group_id,
	       ISNULL(mftd.field_caption, udf_temp.Field_label) default_label,
	       ISNULL(udf_temp.field_type, ''t'') field_type,
	       udf_temp.[data_type],
	       NULL [default_validation],
	       ''h'' header_detail,
	       udf_temp.is_required [system_required],
	       ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) [sql_string],
	       udf_temp.[field_size],
	       ISNULL(mftd.is_disable, ''n''),
	       udf_temp.window_id window_function_id,
	       ''u'' udf_or_system,
	       CASE 
	            WHEN ISNULL(mftd.hide_control, ''n'') = ''y'' or ISNULL(mftd.update_required, ''n'') = ''n'' THEN mftd.seq_no + 100
	            ELSE mftd.seq_no
	       END seq_no,
	       ISNULL(mftd.hide_control, ''n'') hide_control,
	       --CASE 
	       --     WHEN udf_temp.field_type = ''a'' THEN dbo.FNADateFormat(mftd.default_value)
	       --     ELSE mftd.default_value
	       --END default_value
	       mftd.default_value
	       ,
	       ''u--''+cast(mftd.field_id as varchar) field_id,
	        mftd.update_required
	        ,mftd.value_required
	FROM   user_defined_fields_template udf_temp
	       JOIN maintain_field_template_detail mftd
	            ON  udf_temp.udf_template_id = mftd.field_id 
	                --and udf_temp.template_id='+CAST(@deal_template_id AS VARCHAR) +'
	            AND mftd.field_template_id = ' + CAST(@template_id AS VARCHAR) +'
	            AND ISNULL(mftd.udf_or_system, ''s'') = ''u''
			LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udf_temp.data_source_type_id	      
	WHERE  field_group_id IS NOT NULL
	       AND udf_temp.udf_type = ''h'''
	
	IF @group_id IS NOT NULL
		SET @sql = @sql + ' AND mftd.field_group_id = ' + CAST(@group_id AS VARCHAR)

	
	SET @sql = @sql + ') a ORDER BY field_group_id,ISNULL(CASE WHEN a.seq_no > 100 AND ' + CAST(ISNULL(@call_window, 0)  AS VARCHAR(10)) + ' = 1  THEN a.seq_no - 100 ELSE a.seq_no END, 10000), default_label' 
	exec spa_print @sql
	EXEC(@sql)
  
END   
IF @flag = 'd'   --- Source Deal Detail
BEGIN   
	IF @call_window=1 
	BEGIN 
		SELECT column_name INTO #temp_detail FROM INFORMATION_SCHEMA.Columns WHERE TABLE_NAME = 'source_deal_detail_template' 
	END
	SET @sql = ' select * INTO #tmp_col_table from ('
	
	IF @call_window = 1
	BEGIN 
		SET @sql = @sql + '
							SELECT ''template_detail_id'' farrms_field_id,null field_group_id,''ID'' default_label
								  ,''t'' field_type
								  ,null [data_type]
								  ,null [default_validation]
								  ,''d'' [header_detail]
								  ,NULL [system_required]
								  ,NULL [sql_string]
								  ,NULL [field_size]
								  ,''y'' [is_disable]
								  ,null window_function_id
								  ,''s'' udf_or_system
								  ,-1 seq_no 
								  ,-1 deal_update_seq_no 
								  , ''n'' hide_control
								  , ''y'' update_required
								  , ''n'' value_required
							 UNION ALL  '
	END
	
	SET @sql = @sql + '
						SELECT ''counter'' farrms_field_id
								, NULL field_group_id
								, ''counter'' default_label
								, ''t'' field_type
								, ''int'' [data_type]
								, NULL [default_validation]
								, ''d'' [header_detail]
								, NULL [system_required]
								, NULL [sql_string]
								, NULL [field_size]
								, ''y'' [is_disable]
								, NULL window_function_id
								, ''s'' udf_or_system
								, 9002 seq_no 
								, 9002 deal_update_seq_no 
								, ''y'' hide_control
								, ''n'' update_required
								, ''n'' value_required
						UNION ALL  ' --addition for counter	  
	
	SET @sql = @sql + '
						SELECT lower(f.farrms_field_id) farrms_field_id,field_group_id,ISNULL(d.field_caption,f.default_label) default_label
							  ,ISNULL(f.field_type,''t'') field_type
							  ,f.[data_type]
							  ,f.[default_validation]
							  ,f.[header_detail]
							  ,f.[system_required]
							  ,f.[sql_string]
							  ,f.[field_size]
							  ,COALESCE(d.is_disable,f.[is_disable],''n'') is_disable
							  ,f.window_function_id
							  ,''s'' udf_or_system
							  ,d.seq_no
							   ,d.deal_update_seq_no
							  ,isNULL(d.hide_control,''n'') hide_control
							  ,isNULL(d.update_required,''n'') [update_required]   
							  ,ISNULL(d.value_required, ''n'') [value_required]
						FROM maintain_field_template_detail d JOIN maintain_field_deal f ON d.field_id=f.field_id  '
	IF @call_window=1
	BEGIN 
		SET @sql = @sql + '	join #temp_detail t on t.column_name=f.farrms_field_id '
	END  
	SET @sql = @sql + ' WHERE f.header_detail=''d'' AND ISNULL(d.udf_or_system,''s'')=''s''  and d.field_template_id = ' + CAST(@template_id AS VARCHAR)  
	
	--IF @call_window = 0
	--BEGIN
	--	SET @sql = @sql + ' AND  d.update_required= ''y'''
	--END

	SET @sql = @sql + '
		UNION ALL 	
	SELECT ''UDF___''+CAST(udf_template_id AS VARCHAR) udf_template_id,field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,isnUll(udf_temp.field_type,''t'') field_type
	,udf_temp.[data_type]
	,NULL [default_validation]
	,''d'' header_detail
	,udf_temp.is_required [system_required]
	,ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) [sql_string]
	,udf_temp.[field_size]
	,isNUll(mftd.is_disable,''n'')  
	,NULL window_function_id
	,''u'' udf_or_system
	,mftd.seq_no
	,mftd.deal_update_seq_no
	,isNULL(mftd.hide_control,''n'') hide_control
	,isNULL(mftd.update_required,''n'') [update_required]   
	,ISNULL(mftd.value_required,''n'') [value_required]   
	FROM  user_defined_fields_template udf_temp
	JOIN maintain_field_template_detail mftd 
		ON udf_temp.udf_template_id=mftd.field_id   --and udf_temp.template_id='+CAST(@deal_template_id AS VARCHAR) +'
		AND mftd.field_template_id =' + CAST(@template_id AS VARCHAR) +'
		AND ISNULL(mftd.udf_or_system,''s'')=''u''
	LEFT JOIN udf_data_source uds 
		ON uds.udf_data_source_id = udf_temp.data_source_type_id 
	WHERE udf_temp.udf_type=''d'''
	
	IF @call_window = 0
	BEGIN
		SET @sql = @sql + '
		UNION ALL  
		SELECT ''sequence'' farrms_field_id,
		       NULL field_group_id,
		       ''sequence'' default_label,
		       ''t'' field_type,
		       NULL [data_type],
		       NULL [default_validation],
		       ''d'' [header_detail],
		       NULL [system_required],
		       NULL [sql_string],
		       NULL [field_size],
		       ''y'' [is_disable],
		       NULL window_function_id,
		       ''s'' udf_or_system,
		       9000 seq_no,
		       9000 deal_update_seq_no,
		       ''y'' hide_control,
		       ''y'' update_required,
		       ''n'' value_required
		UNION ALL  
		SELECT ''insert_or_delete'' farrms_field_id,
		       NULL field_group_id,
		       ''insert_or_delete'' default_label,
		       ''t'' field_type,
		       NULL [data_type],
		       NULL [default_validation],
		       ''d'' [header_detail],
		       NULL [system_required],
		       NULL [sql_string],
		       NULL [field_size],
		       ''y'' [is_disable],
		       NULL window_function_id,
		       ''s'' udf_or_system,
		       9001 seq_no,
		       9001 deal_update_seq_no,
		       ''y'' hide_control,
		       ''y'' update_required,
		       ''n'' value_required
		       '
	END
	
	
	--IF @call_window = 0
	--BEGIN
	--	SET @sql = @sql + ' AND  mftd.update_required= ''y'''
	--END

	
	SET @sql = @sql + CASE 
	                       WHEN @call_window = 0 THEN ')l ORDER BY ISNULL(l.deal_update_seq_no,10000),default_label'
	                       ELSE ')l ORDER BY ISNULL(l.seq_no,10000),default_label'
	                  END 
		
	SET @sql = @sql + (' SELECT *, ROW_NUMBER() OVER( ORDER BY deal_update_seq_no) as grid_col_value from #tmp_col_table ' + CASE WHEN @call_window = 0 THEN ' ORDER BY deal_update_seq_no,default_label' ELSE ' ORDER BY seq_no,default_label' END)
	EXEC spa_print @sql
	EXEC(@sql)
  
END 
IF @flag = 'e'
BEGIN
	
	SELECT LOWER(mfd.farrms_field_id) farrms_field_id,field_group_id,ISNULL(mftd.field_caption,mfd.default_label) default_label
	,ISNULL(mfd.field_type,'t') field_type
	,mfd.[data_type]
	,mfd.[default_validation]
	,mfd.[header_detail]
	,mfd.[system_required]
	,mfd.[sql_string]
	,mfd.[field_size]
	,mfd.[is_disable]
	,mfd.window_function_id
	FROM maintain_field_template_detail mftd INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		WHERE mfd.header_detail='h' AND mftd.field_template_id = @template_id  AND mftd.field_group_id <> @group_id

END

IF @flag = 'b' -- field template properties Header
BEGIN
	SELECT *
	FROM   (
	SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
	ISNULL(field_group_id,-1) field_group_id,
	                  (
	                    CASE 
	                        WHEN mftd.field_caption = 'book1' OR mfd.farrms_field_id = 'source_system_book_id1' THEN ISNULL(sbmc.group1,'Group1')
							WHEN mftd.field_caption = 'book2' OR mfd.farrms_field_id = 'source_system_book_id2' THEN ISNULL(sbmc.group2,'Group2')
							WHEN mftd.field_caption = 'book3' OR mfd.farrms_field_id = 'source_system_book_id3' THEN ISNULL(sbmc.group3,'Group3')
							WHEN mftd.field_caption = 'book4' OR mfd.farrms_field_id = 'source_system_book_id4' THEN ISNULL(sbmc.group4,'Group4')
							 ELSE ISNULL(mftd.field_caption,mfd.default_label)	
	                      END
	                  ) default_label,
	                  mftd.seq_no,
	                  ISNULL(mfd.field_type, 't') field_type,
	                  mfd.[data_type],
	                  mftd.[validation_id],
	                  mfd.[header_detail],
	                  mfd.[system_required],
	                  mfd.[sql_string],
	                  mfd.[field_size],
	                  mfd.[is_disable] system_is_disable,
	                  mfd.window_function_id,
	                  field_template_detail_id,
	                  's' udf_or_system,
	                  mftd.is_disable,
	                  mftd.insert_required,
	                  ISNULL(mftd.hide_control, 'n') hide_control,
	                  CASE 
	                       WHEN mfd.field_type = 'a' THEN dbo.FNADateFormat(mftd.default_value)
	                       ELSE mftd.default_value
	                  END default_value,
	                  mftd.min_value,
	                  mftd.max_value,
	                  mfd.data_flag,
	                  mftd.buy_label,
	                  mftd.sell_label,
	                  mftd.update_required,
	                  mftd.value_required
	           FROM   maintain_field_deal mfd
	                  LEFT OUTER JOIN maintain_field_template_detail mftd
	ON mftd.field_id = mfd.field_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='s' 
	OUTER APPLY source_book_mapping_clm sbmc
	WHERE mfd.header_detail='h' 
	UNION ALL 	
	           SELECT 'UDF___' + CAST(udf_template_id AS VARCHAR) 
	                  udf_template_id,
	                  ISNULL(field_group_id, -1) field_group_id,
	                  ISNULL(mftd.field_caption, udf_temp.Field_label) 
	                  default_label,
	                  mftd.seq_no,
	                  ISNULL(udf_temp.field_type, 't') field_type,
	                  udf_temp.[data_type],
	                  mftd.[validation_id],
	                  udf_temp.udf_type,
	                  udf_temp.is_required [system_required],
	                  ISNULL(NULLIF(udf_temp.sql_string, ''), uds.sql_string) [sql_string],
	                  udf_temp.[field_size],
	                  NULL system_is_disable,
	                  NULL window_function_id,
	                  ISNULL(field_template_detail_id, -1) 
	                  field_template_detail_id,
	                  'u' udf_or_system,
	                  mftd.is_disable,
	                  mftd.insert_required,
	                  ISNULL(mftd.hide_control, 'n') hide_control,
	                  CASE 
	                       WHEN udf_temp.field_type = 'a' THEN dbo.FNADateFormat(ISNULL(mftd.default_value, udf_temp.default_value))
	                       ELSE mftd.default_value
	                  END default_value,
	                  mftd.min_value,
	                  mftd.max_value,
	                  mftd.data_flag,
	                  mftd.buy_label,
	                  mftd.sell_label,
	                  mftd.update_required,
	                  mftd.value_required
	FROM user_defined_fields_template udf_temp
	LEFT OUTER JOIN maintain_field_template_detail mftd 
		ON mftd.field_id = udf_temp.udf_template_id 
		AND mftd.field_template_id = @template_id 
		AND ISNULL(mftd.udf_or_system,'s')='u'
	LEFT JOIN udf_data_source uds 
		ON uds.udf_data_source_id = udf_temp.data_source_type_id 
	WHERE udf_temp.udf_type='h' 
	) l 
	ORDER BY
	       field_group_id,
	       ISNULL(l.seq_no, 10000),
	       default_label
	
END
IF @flag = 'p' -- template properties detail
BEGIN
	SELECT * FROM (
	SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
	COALESCE(mftd.detail_group_id, field_group_id, -1) field_group_id,
	ISNULL(mftd.field_caption,mfd.default_label) default_label
	,mftd.seq_no
	,mfd.[system_required]
	,mfd.[data_type]
	,mfd.[is_disable] system_is_disable
	,mftd.is_disable 
	,mftd.insert_required
	,CASE WHEN mfd.field_type = 'a'  AND mfd.sql_string = '' THEN dbo.FNADateFormat(mftd.default_value) ELSE mftd.default_value END default_value
	,mftd.min_value
	,mftd.max_value
	,mftd.validation_id	
	,ISNULL(field_template_detail_id,-1) field_template_detail_id
	,'s' udf_or_system
	,mfd.[sql_string]
	,mfd.[field_size]
	,ISNULL(mftd.hide_control,'n') hide_control
	, mfd.data_flag
	, mftd.display_format [display_format]
	, mfd.field_type 
	, mftd.buy_label
	, mftd.sell_label 
	,mftd.update_required
	,mftd.value_required
	FROM maintain_field_deal mfd 
	LEFT OUTER JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='s'
	WHERE mfd.header_detail='d' 
	
	UNION ALL 	
	SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR) udf_template_id,
	COALESCE(mftd.detail_group_id, field_group_id, -1) field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,mftd.seq_no
	,udf_temp.is_required
	,udf_temp.[data_type]
	,NULL system_is_disable
	,mftd.is_disable 
	,mftd.insert_required
	,CASE WHEN udf_temp.field_type = 'a' THEN dbo.FNADateFormat(ISNULL(mftd.default_value, udf_temp.default_value)) ELSE mftd.default_value END default_value
	,mftd.min_value
	,mftd.max_value
	,NULL [default_validation]
	,ISNULL(field_template_detail_id,-1)  field_template_detail_id
	,'u' udf_or_system
	,ISNULL(NULLIF(udf_temp.sql_string, ''), uds.sql_string) [sql_string]
	,udf_temp.[field_size]
	,ISNULL(mftd.hide_control,'n') hide_control
	, mftd.data_flag
	, mftd.display_format [display_format]
	, udf_temp.Field_type
	, mftd.buy_label
	, mftd.sell_label
	,mftd.update_required
	,mftd.value_required
	FROM user_defined_fields_template udf_temp
	LEFT OUTER JOIN maintain_field_template_detail mftd 
		ON mftd.field_id = udf_temp.udf_template_id 
		AND mftd.field_template_id = @template_id 
		AND ISNULL(mftd.udf_or_system,'s')='u'
	LEFT JOIN udf_data_source uds
		ON uds.udf_data_source_id = udf_temp.data_source_type_id
	
	WHERE udf_temp.udf_type='d' 
	)l 
	ORDER BY ISNULL(l.seq_no,10000),default_label

END


IF @flag = 'm' -- Blotter Inter
BEGIN

	SELECT @template_id = field_template_id
	FROM   dbo.source_deal_header_template
	WHERE  template_id = @deal_template_id 


 --ROW_NUMBER() OVER(ORDER BY header_detail DESC,field_group_id,ISNULL(l.seq_no,10000)) row_id,
	SELECT *
	INTO #column_collection
	FROM   (
	           SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
	                  ISNULL(field_group_id, -1) field_group_id,
	                  ISNULL(mftd.field_caption, mfd.default_label) 
	                  default_label,
	                  mftd.seq_no,
	                  ISNULL(mfd.field_type, 't') field_type,
	                  mfd.[data_type],
	                  mftd.[validation_id],
	                  mfd.[header_detail],
	                  mfd.[system_required],
	                  mfd.[sql_string],
	                  mfd.[field_size],
	                  mfd.[is_disable] system_is_disable,
	                  mfd.window_function_id,
	                  field_template_detail_id,
	                  's' udf_or_system,
	                  mftd.is_disable,
	                  mftd.insert_required,
	                  ISNULL(mftd.hide_control, 'n') hide_control,
	                  CASE 
	                       WHEN mfd.field_type = 'a'
	           AND mfd.farrms_field_id NOT IN ('term_start', 'term_end') THEN dbo.FNADateFormat(mftd.default_value) 
	               ELSE mftd.default_value END default_value,
	           mftd.min_value,
	           mftd.max_value,
	           CAST(mftd.field_id AS VARCHAR) field_id,
	           mftd.display_format,
	           mftd.value_required
	           FROM maintain_field_deal mfd 
	           JOIN maintain_field_template_detail mftd 
	           ON mftd.field_id = mfd.field_id
	           AND mftd.field_template_id = @template_id
	           AND ISNULL(mftd.udf_or_system, 's') = 's' 
	               WHERE mfd.farrms_field_id NOT IN ('source_deal_header_id', 
	                                                'source_deal_detail_id', 
	                                                'create_user', 'create_ts', 
	                                                'update_user', 'update_ts', 
	                                                'template_id', 
	                                                'entire_term_start', 
	                                                'entire_term_end', 
	                                                'fixed_float_leg')
	           AND ISNULL(mftd.insert_required, 'n') = 'y'
	               UNION ALL 	
	               SELECT DISTINCT 'UDF___' + CAST(udf_temp.udf_template_id AS VARCHAR) 
	                      udf_template_id,
	                      ISNULL(field_group_id, -1) field_group_id,
	                      ISNULL(mftd.field_caption, udf_temp.Field_label) 
	                      default_label,
	                      mftd.seq_no,
	                      ISNULL(udf_temp.field_type, 't') field_type,
	                      udf_temp.[data_type],
	                      mftd.[validation_id],
	                      udf_temp.udf_type,
	                      udf_temp.is_required [system_required],
	                      ISNULL(NULLIF(udf_temp.sql_string, ''), uds.sql_string) [sql_string],
	                      udf_temp.[field_size],
	                      NULL system_is_disable,
	                      udf_temp.window_id window_function_id,
	                      ISNULL(field_template_detail_id, -1) 
	                      field_template_detail_id,
	                      'u' udf_or_system,
	                      mftd.is_disable,
	                      mftd.insert_required,
	                      ISNULL(mftd.hide_control, 'n') hide_control,
	                      CASE 
	                           WHEN udf_temp.Field_type = 'a' THEN dbo.FNADateFormat(ISNULL(mftd.default_value, udf_temp.default_value))
	                           ELSE ISNULL(mftd.default_value, udf_temp.default_value)
	                      END default_value,
	                      mftd.min_value,
	                      mftd.max_value,
	                      'u--' + CAST(udf_temp.udf_template_id AS VARCHAR),
	                      mftd.display_format,
	                      mftd.value_required
	               FROM   user_defined_fields_template udf_temp
	                      JOIN maintain_field_template_detail mftd
							ON  mftd.field_id = udf_temp.udf_template_id
							AND mftd.field_template_id = @template_id
							AND ISNULL(mftd.udf_or_system, 's') = 'u' 
	                               
	                      JOIN user_defined_deal_fields_template uddft
							ON uddft.udf_user_field_id = udf_temp.udf_template_id
							AND uddft.template_id = @deal_template_id
						  LEFT JOIN udf_data_source uds 
							ON uds.udf_data_source_id = udf_temp.data_source_type_id
	               WHERE  ISNULL(mftd.insert_required, 'n') = 'y'
					UNION ALL           
				 /*added to inlclude fixed_float_leg*/
				 SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
						  ISNULL(field_group_id, -1) field_group_id,
						  ISNULL(mftd.field_caption, mfd.default_label) 
						  default_label,
						  mftd.seq_no,
						  ISNULL(mfd.field_type, 't') field_type,
						  mfd.[data_type],
						  mftd.[validation_id],
						  mfd.[header_detail],
						  mfd.[system_required],
						  mfd.[sql_string],
						  mfd.[field_size],
						  mfd.[is_disable] system_is_disable,
						  mfd.window_function_id,
						  field_template_detail_id,
						  's' udf_or_system,
						  mftd.is_disable,
						  mftd.insert_required,
						  ISNULL(mftd.hide_control, 'n') hide_control,
	                      CASE WHEN mfd.field_type = 'a' AND mfd.field_id NOT IN (82, 83) THEN 
								dbo.FNADateFormat(mftd.default_value) 
						  ELSE mftd.default_value 
	                      END default_value,
				   mftd.min_value,
				   mftd.max_value,
				   CAST(mftd.field_id AS VARCHAR) field_id,
						   mftd.display_format,
						   mftd.value_required
				   FROM maintain_field_deal mfd 
				   JOIN maintain_field_template_detail  mftd 
				   ON mftd.field_id = mfd.field_id
				   AND mftd.field_template_id = @template_id
				   AND ISNULL(mftd.udf_or_system, 's') = 's' 
					   WHERE mfd.farrms_field_id IN ('fixed_float_leg')	                      
	       ) l
	ORDER BY
	       header_detail DESC,
	       field_group_id,
	       ISNULL(l.seq_no, 10000)
	       
DECLARE @check_fix_float VARCHAR(10)
SELECT @check_fix_float = [default_value] FROM #column_collection WHERE [farrms_field_id] IN ('fixed_float_leg')	
	SELECT	cc.[farrms_field_id],
			cc.[field_group_id],
			cc.[default_label],
			cc.[seq_no],
			cc.[field_type],
			cc.[data_type],
			cc.[validation_id],
			cc.[header_detail],
			cc.[system_required],
			cc.[sql_string],
			cc.[field_size],
			cc.[system_is_disable],
			cc.[window_function_id],
			cc.[field_template_detail_id],
			cc.[udf_or_system],
			cc.[is_disable],
			cc.[insert_required],
			cc.[hide_control],
			CASE WHEN cc.[farrms_field_id] = 'curve_id' THEN CASE WHEN @check_fix_float = 'f' THEN NULL ELSE cc.[default_value] END ELSE cc.[default_value] END AS [default_value],
			cc.[min_value],
			cc.[max_value],
			cc.[field_id],
			cc.[display_format],
			cc.value_required
	FROM #column_collection cc 
	LEFT JOIN maintain_field_template_group mftg 
		ON mftg.field_group_id = cc.field_group_id
		AND mftg.field_template_id = @template_id
	WHERE hide_control <> 'y'
	ORDER BY
	       cc.header_detail DESC,
	       mftg.seq_no,
	       ISNULL(cc.seq_no, 10000)
END
IF @flag = 'k' ---deal update sequence
BEGIN
	--SELECT DISTINCT mftd.field_template_detail_id,
	--       ISNULL(mftd.field_caption, mfd.default_label) default_label,
	--       mftd.udf_or_system,
	--       mftd.deal_update_seq_no
	--FROM   maintain_field_deal mfd
	--       CROSS JOIN maintain_field_template_detail mftd
	--       CROSS JOIN user_defined_fields_template udft
	--WHERE  mftd.field_group_id IS NULL
	--       AND mftd.hide_control = 'n'
	--       AND mftd.update_required = 'y'
	--       AND mftd.field_template_id = @template_id
	--       AND (
	--               (mftd.udf_or_system = 's' AND mfd.field_id = mftd.field_id)
	--               OR (
	--                      mftd.udf_or_system = 'u'
	--                      AND udft.udf_template_id = mftd.field_id
	--                  )
	--           )
	--ORDER BY
	--       mftd.deal_update_seq_no

  SELECT DISTINCT mftd.field_template_detail_id,
         ISNULL(mftd.field_caption, mfd.default_label) default_label,
         mftd.udf_or_system,
         mftd.deal_update_seq_no
  FROM   maintain_field_template_detail mftd
         LEFT JOIN maintain_field_deal mfd
              ON  mftd.field_id = mfd.field_id
              AND mftd.udf_or_system = 's'
         LEFT JOIN user_defined_fields_template udft
              ON  udft.udf_template_id = mftd.field_id
              AND mftd.udf_or_system = 'u'
  WHERE  mftd.field_group_id IS NULL
         AND mftd.hide_control = 'n'
         AND mftd.update_required = 'y'
         AND mftd.field_template_id = @template_id
         AND mftd.detail_group_id IS NULL
  ORDER BY
         mftd.deal_update_seq_no  

END
IF @flag = 'y'
BEGIN
    SELECT mfd.farrms_field_id,
           mftd.display_format
    FROM   maintain_field_template_detail mftd
           INNER JOIN maintain_field_deal mfd
                ON  mftd.field_id = mfd.field_id
                AND mftd.udf_or_system = 's'
                AND mfd.field_type = 'a'
           INNER JOIN source_deal_header_template sdht
                ON  mftd.field_template_id = sdht.field_template_id
    WHERE  sdht.template_id = @template_id
END