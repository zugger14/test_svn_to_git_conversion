IF OBJECT_ID('[dbo].[spa_program_affiliations]','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_program_affiliations]
GO 
--EXEC [spa_program_affiliations] 't',142,14,9,5
CREATE PROCEDURE [dbo].[spa_program_affiliations]
@flag char(1),
@fas_subsidiary_id int=null,
@affiliation_id int=null,

@affiliation_type_id int=null,
@affiliation_value_id int=null
as
if @flag='t' 
begin
	select type_id,type_name from static_data_type where type_id in (10080,14100,14150)

END
if @flag='z' 
begin
	select value_id,code from static_data_value where type_id in (10080,14100,14150)
END

if @flag='s' 
begin
	select affiliation_id ID, fas_subsidiary_id, affiliation_type_id, affiliation_value_id,s.type_name [Affiliation Type], v.code [Description]
	from (program_affiliations p inner join static_data_type s on p.affiliation_type_id=s.type_id) inner join static_data_value v on p.affiliation_value_id=v.value_id
	where fas_subsidiary_id=@fas_subsidiary_id

END
if @flag='a' 
begin
	select affiliation_id ID, fas_subsidiary_id, affiliation_type_id, affiliation_value_id
	from program_affiliations
	where affiliation_id=@affiliation_id

END
if @flag='i'
begin

INSERT  program_affiliations(
	fas_subsidiary_id,
	affiliation_type_id,
	affiliation_value_id

)
VALUES 	(
	@fas_subsidiary_id,
	@affiliation_type_id,
	@affiliation_value_id
)
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "program Affiliations", 
						"spa_program_affiliations", "DB Error", 
					"Error on Inserting program affiliations.", ''
			else
				Exec spa_ErrorHandler 0, 'Program Affiliations', 
						'spa_program_affiliations', 'Success', 
						'program affiliations successfully inserted.', ''
END
if @flag='u'
begin

	UPDATE	program_affiliations
		set fas_subsidiary_id=@fas_subsidiary_id,
		affiliation_type_id=@affiliation_type_id,
		affiliation_value_id=@affiliation_value_id
		where affiliation_id=@affiliation_id
	
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "program Affiliations", 
						"spa_program_affiliations", "DB Error", 
					"Error on Updating program affiliations.", ''
			else
				Exec spa_ErrorHandler 0, 'Program Affiliations', 
						'spa_program_affiliations', 'Success', 
						'program affiliations successfully updated.', ''
END
if @flag='d'
begin
	delete program_affiliations
	where affiliation_id=@affiliation_id
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "program Affiliations", 
						"spa_program_affiliations", "DB Error", 
					"Error on Deleting program affiliations.", ''
			else
				Exec spa_ErrorHandler 0, 'Program Affiliations', 
						'spa_program_affiliations', 'Success', 
						'program affiliations successfully deleted.', ''
end
ELSE IF @flag = 'k'
BEGIN
	 SELECT sub.fas_subsidiary_id, pf.entity_name FROM portfolio_hierarchy pf
	 INNER JOIN fas_subsidiaries sub ON sub.fas_subsidiary_id = pf.entity_id
	 
END

ELSE IF @flag = 'p'
BEGIN
	    SELECT pa.affiliation_id,sb.fas_subsidiary_id,pa.affiliation_type_id,pa.affiliation_value_id
	    FROM program_affiliations pa INNER JOIN fas_subsidiaries sb ON  sb.fas_subsidiary_id = pa.fas_subsidiary_id
	  WHERE sb.fas_subsidiary_id = @fas_subsidiary_id
END


--SELECT * FROM program_affiliations
--SELECT * FROM fas_subsidiaries 
--SELECT * FROM static_data_value WHERE code LIKE '%value%'
--SELECT * FROM static_data_type  WHERE type_name LIKE '%value%'
--select value_id,code from static_data_value where type_id in (10080,14100,14150)
--select type_id,type_name from static_data_type where type_id in (10080,14100,14150)
--SELECT * FROM static_data_value
--INSERT INTO static_data_value(TYPE_ID,code,DESCRIPTION,entity_id,xref_value_id,xref_value,category_id) VALUES
--(10080,'sa','sa',NULL,NULL,NULL,null)