IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'process_risk_controls'
                    AND ccu.COLUMN_NAME IN ('risk_description_id', 'risk_control_description')
)
BEGIN
 ALTER TABLE [dbo].process_risk_controls WITH NOCHECK ADD CONSTRAINT uc_process_risk_controls UNIQUE(risk_description_id, risk_control_description)
 PRINT 'Unique Constraints added on risk_description_id, risk_control_description.' 
END
ELSE
BEGIN
 PRINT 'Unique Constraints on risk_description_id, risk_control_description already exists.'
END