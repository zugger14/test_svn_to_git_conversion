-- MOVE from Uncategory to General
DECLARE @field_template_id INT,
		@general_field_group_id INT,
		@field_id INT,
		@farrms_field_id VARCHAR(100) = 'fas_deal_type_value_id',
		@book4_seq INT

SELECT @field_id = field_id FROM maintain_field_deal WHERE farrms_field_id = @farrms_field_id
-- declare cursor
DECLARE template_cursor CURSOR FOR 

SELECT DISTINCT(mft.field_template_id)
	, MIN(mftg.field_group_id) AS [general_field_group_id]
FROM maintain_field_template mft 
LEFT JOIN maintain_field_template_group mftg 
	ON mftg.field_template_id = mft.field_template_id
LEFT JOIN  maintain_field_template_detail mftd 
	ON mftd.field_template_id = mft.field_template_id
AND mftd.field_id = @field_id
WHERE mftd.field_template_id IS NULL
GROUP BY mft.field_template_id

-- open cursor
OPEN template_cursor  
FETCH NEXT FROM template_cursor INTO @field_template_id, @general_field_group_id;

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Move to general
	EXEC spa_maintain_field_properties 'i', NULL, @field_template_id, @general_field_group_id, @farrms_field_id, NULL 
				, 'n', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'h'
				, NULL, NULL, NULL, NULL, NULL, NULL	
	
	SET @book4_seq = NULL
	SELECT @book4_seq = seq_no
	FROM maintain_field_template_detail mftd
	INNER JOIN maintain_field_deal mfd on mftd.field_id = mfd.field_id
	WHERE field_template_id = @field_template_id and field_group_id = @general_field_group_id
		AND mfd.farrms_field_id = 'source_system_book_id4' AND hide_control='n'

	IF @book4_seq IS NOT NULL
	BEGIN
		UPDATE mftd
		SET mftd.deal_update_seq_no = mftd.seq_no
		FROM maintain_field_template_detail mftd
		WHERE field_template_id = @field_template_id and field_group_id = @general_field_group_id

		UPDATE mftd
		SET seq_no = CASE WHEN mfd.farrms_field_id = 'fas_deal_type_value_id' THEN @book4_seq ELSE seq_no + 1 END
		FROM maintain_field_template_detail mftd
		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		WHERE field_template_id = @field_template_id AND field_group_id = @general_field_group_id
		AND seq_no > @book4_seq
	END

	FETCH NEXT FROM template_cursor INTO @field_template_id, @general_field_group_id;
END

-- cleanup
CLOSE template_cursor
DEALLOCATE template_cursor