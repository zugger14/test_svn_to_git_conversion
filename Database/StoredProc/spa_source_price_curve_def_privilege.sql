IF OBJECT_ID(N'spa_source_price_curve_def_privilege', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_source_price_curve_def_privilege]
GO 

CREATE PROCEDURE [dbo].[spa_source_price_curve_def_privilege]
	@flag CHAR(1),
	@id INT = NULL,
	@source_curve_def_id INT,
	@sub_entity_id INT = NULL,
	@role_id INT = NULL
AS
	
BEGIN

if @flag='s'
	select ISNULL(ph.entity_name,'All') [Subsidiary],ISNULL(asr.role_name,'All') [Role], [id],source_curve_def_id
	from
		source_price_curve_def_privilege spcdp
		left join portfolio_hierarchy ph on spcdp.sub_entity_id=ph.entity_id
		left join application_security_role asr on spcdp.role_id=asr.role_id
	where
		source_curve_def_id=@source_curve_def_id	
	
else if @flag='a'
	SELECT  [id],
			source_curve_def_id,
			sub_entity_id,
			role_id
	FROM source_price_curve_def_privilege
	WHERE [id]=@id	

else if @flag='i'
BEGIN
	insert into source_price_curve_def_privilege(
		source_curve_def_id,
		sub_entity_id,	
		role_id
	)
	select
		@source_curve_def_id,
		@sub_entity_id,	
		@role_id

		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "spa_source_price_curve_def_privilege", 
		"spa_source_price_curve_def_privilege", "DB Error", 
		"Error Inserting source price curve privilege.", ''
	else
		Exec spa_ErrorHandler 0, 'spa_source_price_curve_def_privilege', 
		'spa_source_price_curve_def_privilege', 'Success', 
		'source price curve privilege successfully inserted.',''			
END

else if @flag='u'
BEGIN
	update 
		source_price_curve_def_privilege
	set
		sub_entity_id=@sub_entity_id,
		role_id=@role_id
	where
		[id]=@id

		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "spa_source_price_curve_def_privilege", 
		"spa_source_price_curve_def_privilege", "DB Error", 
		"Error Updating source price curve privilege.", ''
	else
		Exec spa_ErrorHandler 0, 'spa_source_price_curve_def_privilege', 
		'spa_source_price_curve_def_privilege', 'Success', 
		'source price curve privilege successfully updated.',''			
END

else if @flag='d'
BEGIN
	DELETE
		source_price_curve_def_privilege
	where
		[id]=@id

		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "spa_source_price_curve_def_privilege", 
		"spa_source_price_curve_def_privilege", "DB Error", 
		"Error Deleting source price curve privilege.", ''
	else
		Exec spa_ErrorHandler 0, 'spa_source_price_curve_def_privilege', 
		'spa_source_price_curve_def_privilege', 'Success', 
		'source price curve privilege successfully Deleted.',''			
END

ELSE IF @flag = 'g'
BEGIN
	SELECT id, source_curve_def_id, sub_entity_id, ISNULL(CAST(role_id AS VARCHAR(25)), 'All') role_id
	FROM
		source_price_curve_def_privilege spcdp
	WHERE
		source_curve_def_id=@source_curve_def_id
	ORDER BY sub_entity_id, role_id
END	

END
