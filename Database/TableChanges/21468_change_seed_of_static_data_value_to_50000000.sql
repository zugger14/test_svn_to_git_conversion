DECLARE @current_seed_value NUMERIC(30),
		@current_max_value_id NUMERIC(30),
		@apply_seed NUMERIC(30)

SELECT @current_seed_value = IDENT_CURRENT('static_data_value')
SELECT @current_max_value_id = MAX(value_id) FROM static_data_value

IF @current_seed_value < 49999999 
BEGIN
	IF @current_max_value_id > 49999999
		SET @apply_seed = @current_max_value_id + 1
	ELSE
		SET @apply_seed = 49999999
	--PRINT @apply_seed
	DBCC CHECKIDENT (static_data_value, RESEED, @apply_seed)
	PRINT 'Seed set to max'
END
ELSE
	PRINT 'Seed already set to max'

GO