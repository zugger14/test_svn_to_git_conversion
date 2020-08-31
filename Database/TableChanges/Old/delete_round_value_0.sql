IF EXISTS(SELECT 'x' FROM round_value WHERE [value] = 0)
	DELETE FROM round_value WHERE [value] = 0