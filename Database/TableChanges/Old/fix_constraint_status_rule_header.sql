DECLARE @constraint VARCHAR(1000)

SELECT @constraint = tc.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
    AND tc.Constraint_name = ccu.Constraint_name    
    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
    AND   tc.Table_Name = 'status_rule_header'           --table name
    AND ccu.COLUMN_NAME = 'status_rule_type' 
    AND tc.constraint_name <> 'FK_status_static_data_type_23RT'
    
IF @constraint IS NOT NULL
BEGIN 
	exec('ALTER TABLE status_rule_header DROP constraint ' + @constraint)
END 

-----NOTE: A wrong foreign key had been created in original table creation script referencing table 
--static_data_value column value_id.So we need to remove this constraint.But another script has also been 
--committed creating the correct foreign key reference to static_data_type column type_id.So we want to delete 
--the constraint referencing static_data_value and not static_data_type hence the condition 
-- AND tc.constraint_name <> 'FK_status_static_data_type_23RT'