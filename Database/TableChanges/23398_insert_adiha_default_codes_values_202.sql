IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 202
)
BEGIN
INSERT INTO adiha_default_codes 
(
	default_code_id
	,default_code
	, code_def
	, code_description
	, instances
)
VALUES (
	202
	, 'position_calc_threshold_deal_detail_count'
	, 'Position Calc Threshold Deal Detail Count'
	, 'Threshold deal detail count for starting position calc'
	, '1'
)
END
ELSE
BEGIN
	UPDATE adiha_default_codes SET default_code = 'position_calc_threshold_deal_detail_count', code_def = 'Position Calc Threshold Deal Detail Count', code_description = 'Threshold deal detail count for starting position calc' WHERE default_code_id = 202
END

GO

IF NOT EXISTS(SELECT 1 FROM dbo.adiha_default_codes_values WHERE default_code_id = 202 AND instance_no = 1 AND seq_no = 1)
BEGIN
	INSERT INTO dbo.adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description]) 
	 VALUES (1, 202, 1, '2000', 'Max deal detail count to initiate position calc')
END
ELSE
	UPDATE dbo.adiha_default_codes_values SET var_value = 2000, [description] = 'Max deal detail count to initiate position calc' WHERE default_code_id = 202 AND instance_no = 1 AND seq_no = 1

GO

