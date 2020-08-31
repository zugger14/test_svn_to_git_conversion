DECLARE @grid_id INT 

SELECT @grid_id = grid_id FROM adiha_grid_definition WHERE grid_name = 'grid_bank_info'

UPDATE adiha_grid_columns_definition SET column_order = 8 WHERE grid_id = @grid_id AND column_name = 'Address2' AND column_label = 'Address 2'

DELETE FROM adiha_grid_columns_definition WHERE grid_id = @grid_id AND column_name = 'Address1' AND column_label = 'Address 2'