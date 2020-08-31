--DECLARE @field_id INT 
--SELECT @field_id = MAX(field_id) + 1 FROM maintain_field_deal 
--select @field_id


IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'reporting_tier_id' AND header_detail = 'h') 
BEGIN
	INSERT INTO maintain_field_deal ( 
           --field_id, 
           farrms_field_id, 
           default_label, 
           field_type, 
           data_type, 
           default_validation, 
           header_detail, 
           system_required, 
           sql_string, 
           field_size, 
           is_disable, 
           window_function_id, 
           is_hidden, 
           default_value, 
           insert_required, 
           data_flag, 
           update_required 
         ) 
       SELECT --@field_id, 
              'reporting_tier_id',                                   
              'Reporting Tier', 
              'd', 
              'int', 
              NULL, 
              'h', 
              'n', 
              'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15000', 
              NULL, 
              'n', 
              NULL, 
              'n', 
              'y', 
              'n', 
              'i', 
              'n'  
END
