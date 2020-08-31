DECLARE @field_id INT 
SELECT @field_id = MAX(field_id) + 1 FROM maintain_field_deal 
IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'is_environmental' AND header_detail = 'h') 
BEGIN  
INSERT INTO maintain_field_deal ( 
           field_id, 
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

       SELECT @field_id, 
              'is_environmental',                      

              'Environmental', 

              'c', 

              'char', 

              NULL, 

              'h', 

              'n', 

              'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''', 

              NULL, 

              NULL, 

              NULL, 

              'n', 

              'n', 

              'n', 

              'i', 

              'n'  

END 

--delete from maintain_field_deal where default_label = 'Environmental'

IF COL_LENGTH('source_deal_header', 'is_environmental') IS NULL 
BEGIN 
	ALTER TABLE source_deal_header
	Add  is_environmental char
END
--select * from source_deal_header

IF COL_LENGTH('source_deal_header_audit', 'is_environmental') IS NULL 
BEGIN 
    ALTER TABLE source_deal_header_audit ADD is_environmental char 
END 


IF COL_LENGTH('delete_source_deal_header', 'is_environmental') IS NULL 
BEGIN 
    ALTER TABLE delete_source_deal_header ADD is_environmental char 
END 

  

IF COL_LENGTH('source_deal_header_template', 'is_environmental') IS NULL 
BEGIN 
    ALTER TABLE source_deal_header_template ADD is_environmental char 
END 
