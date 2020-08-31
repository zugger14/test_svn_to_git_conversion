IF NOT EXISTS(SELECT 'x' FROM round_value WHERE [value] = 0)
BEGIN 
	SET  IDENTITY_INSERT round_value ON
	INSERT INTO round_value(id,VALUE) VALUES(0,0)
	SET  IDENTITY_INSERT round_value OFF
END 