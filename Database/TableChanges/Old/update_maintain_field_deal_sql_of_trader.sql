UPDATE maintain_field_deal
SET
	sql_string = 'SELECT source_trader_id,trader_name FROM dbo.source_traders'
WHERE field_id = 27