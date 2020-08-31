IF OBJECT_ID(N'spa_template_report_type', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_template_report_type]
GO 

--spa_template_report_type 's',1075,NULL,NULL
CREATE PROCEDURE [dbo].[spa_template_report_type] 
	@flag AS CHAR(1),
	@temp_type AS INT = NULL,
	@compliance_year INT = NULL,
	@notes_subject VARCHAR(50) = NULL
AS
SET NOCOUNT ON

IF @flag = 's' -- USE for Green House gas Report
BEGIN
    SELECT template_id,
           temp_desc
    FROM   template_header
    WHERE  temp_type = @temp_type
END
ELSE IF @flag = 't' -- GET TEMPLATE NAME by Year and Report Type
     BEGIN
         SELECT TOP 1 temp_detail_id,
                template_file
         FROM   template_detail
         WHERE  template_id = @temp_type
                AND compliance_year <= @compliance_year
         ORDER BY
                temp_detail_id DESC
     END
ELSE IF @flag = 'm' -- Check saved Template in Manage Documment
     BEGIN
		IF NOT EXISTS(
		       SELECT notes_id,
		              notes_subject,
		              notes_text,
		              attachment_file_name
		       FROM   application_notes
		       WHERE  notes_subject = @notes_subject
		   )
	BEGIN
		SELECT TOP 1 NULL notes_id,
		       temp_detail_id,
		       template_file,
		       template_file
		FROM   template_detail
		WHERE  template_id = @temp_type
		       AND compliance_year <= @compliance_year
		ORDER BY
		       temp_detail_id DESC
	END
	ELSE
		SELECT notes_id,
		       notes_subject,
		       notes_text,
		       attachment_file_name
		FROM   application_notes
		WHERE  notes_subject = @notes_subject
	
END