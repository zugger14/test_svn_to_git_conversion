DECLARE @dci INT = 1,
	@cnt INT,
	@dcid INT,
	@var_value VARCHAR(100),
	@var_value_update VARCHAR(100)

SELECT @cnt = COUNT(*) 
FROM (
	SELECT default_code_id, var_value FROM adiha_default_codes_values 
	EXCEPT 
	SELECT default_code_id, var_value FROM adiha_default_codes_values_possible 
) a
WHERE default_code_id IN (SELECT default_code_id FROM adiha_default_codes_values_possible)

WHILE @dci < @cnt + 1
BEGIN
	SELECT @dcid = default_code_id, @var_value = var_value 
	FROM (
		SELECT default_code_id, var_value FROM adiha_default_codes_values 
		EXCEPT 
		SELECT default_code_id, var_value FROM adiha_default_codes_values_possible 
	) a
	WHERE default_code_id IN (SELECT default_code_id FROM adiha_default_codes_values_possible)

	IF EXISTS (
		SELECT default_code_id, var_value 
		FROM (
			SELECT default_code_id, var_value FROM adiha_default_codes_values 
			EXCEPT 
			SELECT default_code_id, var_value FROM adiha_default_codes_values_possible 
		) a
		WHERE default_code_id IN (SELECT default_code_id FROM adiha_default_codes_values_possible)
	)
	BEGIN
		SELECT @var_value_update = var_value FROM adiha_default_codes_values_possible WHERE default_code_id = @dcid
		UPDATE adiha_default_codes_values SET var_value = @var_value_update WHERE default_code_id = @dcid
	END
	SET @dci = @dci + 1
END

GO