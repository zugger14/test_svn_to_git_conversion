--UPDATE maintain_field_deal SET update_required = insert_required 

--UPDATE maintain_field_deal SET	update_required = 'y' WHERE insert_required = 'n' AND is_hidden = 'n'

--UPDATE maintain_field_deal SET	update_required = 'y' WHERE system_required = 'y'


UPDATE maintain_field_deal
SET    is_hidden = 'n'
WHERE field_id IN (101, 102, 103, 104, 122)
       
UPDATE maintain_field_deal SET update_required = CASE WHEN is_hidden = 'n' THEN 'y' ELSE 'n' END 
 