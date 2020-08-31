

/****** Object:  StoredProcedure [dbo].[spa_Source_Deal_Header_Template]    Script Date: 03/19/2009 11:29:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_html_email_body]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_html_email_body]

go

/*
exec spa_Create_Deal_Audit_Report 'c', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16910, NULL, NULL, NULL, NULL,null,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,NULL

DECLARE @html VARCHAR(MAX)
exec spa_get_html_email_body 16910,@html OUT
SELECT @html


*/

go

CREATE PROCEDURE [dbo].[spa_get_html_email_body] (
	@deal_id INT, 
	@html VARCHAR(MAX) OUT
)
AS
BEGIN
	CREATE TABLE #deal_deatail_aaa(
		sn				INT IDENTITY(1,1),
		deal_id			INT,
		ref_id			VARCHAR(50) COLLATE DATABASE_DEFAULT,
		term_start		VARCHAR(10) COLLATE DATABASE_DEFAULT,
		leg				VARCHAR(10) COLLATE DATABASE_DEFAULT,
		field			VARCHAR(50) COLLATE DATABASE_DEFAULT,
		prior_value		VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		current_value	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		update_ts		VARCHAR(50) COLLATE DATABASE_DEFAULT,
		update_user		VARCHAR(50) COLLATE DATABASE_DEFAULT
	)
		
--	INSERT INTO #deal_deatail_aaa
	exec spa_Create_Deal_Audit_Report 'c', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @deal_id, NULL, NULL, NULL, NULL,null,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,NULL
	
	/*IF NOT EXISTS(SELECT TOP 1 1 FROM #deal_detail)
	BEGIN
		SELECT @html = ''
		RETURN
	END*/
	
	SELECT @html = '<html>
					<head>
						<style type="text/css">
							table
							{
								border-width: 0 0 1px 1px;
								border-spacing: 0;
								border-collapse: collapse;
								border-style: solid;								
							}

							table td,th
							{
								margin: 0;
								padding: 4px;
								border-width: 1px 1px 0 0;
								border-style: solid;								
							}
						</style>
					</head>
					<body>
						<table border="1" cellspacing="0" cellpadding="5">
							<tr>
								<th>Deal ID</th>
								<th>Ref ID</th>
								<th>Term Start</th>
								<th>Leg</th>
								<th>Field</th>
								<th>Prior Value</th>
								<th>Current Value</th>
								<th>Update TS</th>
								<th>Update User</th>
							</tr>'
	SELECT @html =	@html + 
					'<tr>' +
						'<td>' + CAST(@deal_id AS VARCHAR)	+ '</td>' +
						'<td>' + ISNULL(ref_id,'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(dbo.FNAConvertTZAwareDateFormat(term_start, 2),'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(leg,'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(field,'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(prior_value,'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(current_value,'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(dbo.FNAConvertTZAwareDateFormat(update_ts, 4),'&nbsp;') + '</td>'	+
						'<td>' + ISNULL(update_user,'&nbsp;') + '</td>'	+
					'</tr>' 
		FROM #deal_deatail_aaa

	SELECT @html = @html + '</table> </body> </html>'
END
