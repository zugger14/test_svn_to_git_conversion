IF EXISTS(SELECT 1 FROM maintain_field_deal WHERE field_id=129 AND header_detail='d' AND sql_string='exec spa_staticDataValues ''b'',10101')
BEGIN
 	UPDATE maintain_field_deal SET sql_string='exec spa_staticDataValues ''b'',18100'  WHERE field_id=129 AND header_detail='d' AND sql_string='exec spa_staticDataValues ''b'',10101'
 	PRINT ' Updated sql_sring field'
 END 
ELSE
	PRINT 'No Records Found'