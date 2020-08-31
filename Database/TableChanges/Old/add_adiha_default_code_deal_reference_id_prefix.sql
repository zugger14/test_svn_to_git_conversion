IF NOT EXISTS(
       SELECT 1
       FROM   adiha_default_codes adc
       WHERE  adc.default_code_id = 50
   )
BEGIN
    INSERT INTO adiha_default_codes
      (
        default_code_id,
        default_code,
        code_description,
        code_def,
        instances
      )
    SELECT 50,
           'spa_deal_reference_id_prefix',
           'Define Reference ID Prefix according to deal type selected.',
           'Deal Reference ID Prefix',
           1
END

GO

IF NOT EXISTS(
       SELECT 1
       FROM   adiha_default_codes_params adcp
       WHERE adcp.seq_no = 1 AND adcp.default_code_id = 50
   )
BEGIN
	INSERT INTO adiha_default_codes_params
	  (
		seq_no,
		default_code_id,
		var_name,
		[type_id],
		var_length,
		value_type
	  )
	SELECT 1,
		   50,
		   'spa_deal_reference_id_prefix',
		   3,
		   NULL,
		   'h'
END
       
GO
       
IF NOT EXISTS(
       SELECT 1
       FROM   adiha_default_codes_values adcv
       WHERE adcv.instance_no = 1 AND adcv.default_code_id = 50 
   )
BEGIN
	
INSERT INTO adiha_default_codes_values
	  (
		instance_no,
		default_code_id,
		seq_no,
		var_value,
		[description]
	  )
	SELECT 1,
		   50,
		   1,
		   0,
		   'Refrence ID Prefix'
       
END

GO

/*
SELECT * FROM adiha_default_codes order by 1 desc
SELECT * FROM adiha_default_codes_params
SELECT * FROM adiha_default_codes_values
*/