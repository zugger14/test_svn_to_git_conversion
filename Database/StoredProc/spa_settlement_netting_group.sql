/****** Object:  StoredProcedure [dbo].[spa_settlement_netting_group]    Script Date: 11/17/2012 10:56:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_settlement_netting_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_netting_group]
GO

--exec spa_settlement_netting_group 'i','','Mukesh',27
--exec spa_settlement_netting_group 's'
--select * from settlement_netting_group
--select * from contract_report_template where template_id = 27
--sp_help settlement_netting_group
CREATE proc [dbo].[spa_settlement_netting_group]
@flag varchar(1),
@netting_group_id VARCHAR(1000) = NULL,
@netting_group_name varchar(100) = null,
@template_id int = null,
@counterparty_id INT=NULL,
@netting_group_detail_id int = null,
@form_xml VARCHAR(max) = NULL,
@grid_xml VARCHAR(max) = NULL

AS
SET NOCOUNT ON

declare @sql_stmt varchar(1000)
DECLARE @idoc INT
DECLARE @idoc_grid INT
DECLARE @message VARCHAR(500)

IF @flag = 'g'
BEGIN
    SELECT ngp.netting_parent_group_name,			
           sc.counterparty_name counterparty_name,
           ng.netting_group_name,
           ng.netting_group_id,           
           dbo.FNADateFormat(ng.effective_date) effective_date,
           crt.template_name invoice_template,
           CASE WHEN ng.create_individual_invoice = 1 THEN 'Yes' ELSE 'No' END [create_individual_invoice]
          
    FROM   netting_group_parent ngp
           LEFT JOIN netting_group ng
                ON  ng.netting_parent_group_id = ngp.netting_parent_group_id
           LEFT JOIN netting_group_detail ngd
                ON  ngd.netting_group_id = ng.netting_group_id
           LEFT JOIN source_counterparty sc
                ON  sc.source_counterparty_id = ngd.source_counterparty_id
            LEFT JOIN Contract_report_template crt ON crt.template_id = ng.invoice_template
    WHERE ngp.netting_parent_group_id IN (-1) --(-1,-2)
END

if @flag ='s'
Begin

--set @sql_stmt = 'select company_type_template_id [CompanyTypeID] ,company_type_id [CompanyType],section [Section],parent_company_type_template_id [ParentCompanyTemplateID]
--from company_type_template '

--select ctt.netting_group_name [GroupName],ctt.company_type_id [CompanyType ID],stv.code [CompanyType],ctt.section [Section],ctt.parent_company_type_template_id [ParentCompanyTemplateID]
--from company_type_template ctt 
--join static_data_value stv  on ctt.company_type_id=stv.value_id
		set @sql_stmt = 'SELECT a.netting_group_id [Netting Group ID],
		sc.counterparty_name [Counterparty],
		a.netting_group_name [Group Name],
		a.effective_date [Effective Date],			
		b.template_name [Invoice Template],
		a.create_individual_invoice	[Create Individual Invoice]
		FROM netting_group a
		LEFT JOIN netting_group_detail ngd
			on a.netting_group_id = ngd.netting_group_id
		LEFT JOIN contract_report_template b
			ON a.invoice_template = b.template_id
		LEFT JOIN source_counterparty sc 
			on sc.source_counterparty_id= ngd.source_counterparty_id'
		

--print @sql_stmt
exec(@sql_stmt)
END

	Else if @flag ='a'
	Begin
	
		set @sql_stmt = '					
					SELECT 
						ng.netting_parent_group_id [netting_parent_group_id],
						ng.netting_group_id [netting_group_id],
						ng.netting_group_name [netting_group_name],
						ng.effective_date [effective_date],
						ng.invoice_template [invoice_template],
						ngd.source_counterparty_id [counterparty_id],
						CASE WHEN ng.create_individual_invoice = 1 THEN ''y'' ELSE ''n'' END [create_individual_invoice],
						ngd.netting_group_detail_id
					FROM netting_group ng
					INNER JOIN netting_group_detail ngd on ngd.netting_group_id = ng.netting_group_id
					where ng.netting_group_id='+ cast(@netting_group_id as varchar)


	--print @sql_stmt
	exec(@sql_stmt)

	END
	
	Else if @flag ='z'
	Begin
	
		set @sql_stmt = '					
					SELECT netting_contract_id, source_contract_id [contract_id], contract_description
				FROM netting_group_detail_contract ngdc INNER JOIN netting_group_detail ngd ON ngdc.netting_group_detail_id= ngd.netting_group_detail_id
					WHERE ngd.netting_group_id = '+ cast(@netting_group_id as varchar)


	--print @sql_stmt
	exec(@sql_stmt)

	END

	Else if @flag='i'

	BEGIN
	BEGIN TRY	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
		IF OBJECT_ID('tempdb..#temp_settlement_netting') IS NOT NULL
			DROP TABLE #temp_settlement_netting
		SELECT
			netting_parent_group_id,
			netting_group_id,
			netting_group_name,
			effective_date,
			invoice_template,
			counterparty_id,
			create_individual_invoice
			INTO #temp_settlement_netting
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			netting_parent_group_id INT,
			netting_group_id INT,
			netting_group_name VARCHAR(1000),
			effective_date DATETIME,
			invoice_template INT,
			counterparty_id INT,
			create_individual_invoice CHAR(1)
		)
	
	
		EXEC sp_xml_preparedocument @idoc_grid OUTPUT, @grid_xml
		IF OBJECT_ID('tempdb..#temp_settlement_netting_grid') IS NOT NULL
			DROP TABLE #temp_settlement_netting_grid
		SELECT
			netting_contract_id,
			contract_id,
			contract_description
			INTO #temp_settlement_netting_grid
		FROM OPENXML(@idoc_grid, '/Root/PSRecordset', 1)
		WITH (
			netting_contract_id INT,
			contract_id INT,
			contract_description VARCHAR(1000)
		)
		
	
		IF EXISTS (SELECT 1 FROM netting_group ng INNER JOIN #temp_settlement_netting tsn
						 ON ng.netting_group_name = tsn.netting_group_name 
						 AND ng.netting_parent_group_id = tsn.netting_parent_group_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_settlement_netting_group', 'DBError', 'Group Name already exists.', ''
			RETURN
		END
		
		/*
		IF EXISTS (SELECT 1 FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
							INNER JOIN #temp_settlement_netting tsn
								 ON ngd.source_counterparty_id = tsn.counterparty_id 
								 AND ng.netting_parent_group_id = tsn.netting_parent_group_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_settlement_netting_group', 'DBError', 'Counterparty already exists.', ''
			RETURN
		END
		*/
		
		INSERT INTO netting_group
		(netting_parent_group_id,
			netting_group_name,
			effective_date,
			invoice_template,
			create_individual_invoice)
		SELECT
			netting_parent_group_id,
			netting_group_name,
			effective_date,
			CASE WHEN invoice_template = 0 THEN NULL ELSE invoice_template END,
			CASE WHEN create_individual_invoice = 'y' THEN 1 ELSE 0 END
		FROM #temp_settlement_netting

		DECLARE @new_id INT
		SET @new_id = SCOPE_IDENTITY()
	
		INSERT INTO netting_group_detail
		(netting_group_id,
			source_counterparty_id)
		SELECT
			@new_id,
			counterparty_id
		FROM #temp_settlement_netting

		DECLARE @new_id1 INT
		SET @new_id1 = SCOPE_IDENTITY()
	
		INSERT INTO netting_group_detail_contract
		(netting_group_detail_id,
			source_contract_id,
			contract_description)
		SELECT
			@new_id1,
			contract_id,
			contract_description
		FROM #temp_settlement_netting_grid

		Exec spa_ErrorHandler 0, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'Success', 
					'Changes have been saved successfully.', @new_id
				
	END TRY
	BEGIN CATCH
		Exec spa_ErrorHandler @@ERROR, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'DB Error', 
					'Data failed inserted.', ''
	END CATCH
END
Else if @flag='u'
BEGIN
	BEGIN TRY	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
		IF OBJECT_ID('tempdb..#temp_settlement_netting2') IS NOT NULL
			DROP TABLE #temp_settlement_netting2
		SELECT
			netting_parent_group_id,
			netting_group_id,
			netting_group_name,
			effective_date,
			invoice_template,
			counterparty_id,
			create_individual_invoice
			INTO #temp_settlement_netting2
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			netting_parent_group_id INT,
			netting_group_id INT,
			netting_group_name VARCHAR(1000),
			effective_date DATETIME,
			invoice_template INT,
			counterparty_id INT,
			create_individual_invoice CHAR(1)
		)
	
	
		EXEC sp_xml_preparedocument @idoc_grid OUTPUT, @grid_xml
		IF OBJECT_ID('tempdb..#temp_settlement_netting_grid2') IS NOT NULL
			DROP TABLE #temp_settlement_netting_grid2
		SELECT
			netting_contract_id,
			contract_id,
			contract_description
			INTO #temp_settlement_netting_grid2
		FROM OPENXML(@idoc_grid, '/Root/PSRecordset', 1)
		WITH (
			netting_contract_id INT,
			contract_id INT,
			contract_description VARCHAR(1000)
		)
				
		IF EXISTS (SELECT 1 FROM netting_group ng INNER JOIN #temp_settlement_netting2 tsn
						 ON ng.netting_group_name = tsn.netting_group_name 
						 AND ng.netting_parent_group_id = tsn.netting_parent_group_id
						 AND ng.netting_group_id <> tsn.netting_group_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_settlement_netting_group', 'DBError', 'Group Name already exists.', ''
			RETURN
		END
		
		/*
		IF EXISTS (SELECT 1 FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
							INNER JOIN #temp_settlement_netting2 tsn
								 ON ngd.source_counterparty_id = tsn.counterparty_id 
								 AND ng.netting_parent_group_id = tsn.netting_parent_group_id
								 AND ng.netting_group_id <> tsn.netting_group_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_settlement_netting_group', 'DBError', 'Counterparty already exists.', ''
			RETURN
		END
		*/
			
		MERGE INTO netting_group T
		   USING #temp_settlement_netting2 S 
			  ON T.netting_group_id = S.netting_group_id
		WHEN MATCHED THEN
		   UPDATE 
			  SET	netting_parent_group_id = S.netting_parent_group_id,
					netting_group_name = S.netting_group_name,
					effective_date = S.effective_date,
					invoice_template = CASE WHEN S.invoice_template = 0 THEN NULL ELSE S.invoice_template END,
					create_individual_invoice = CASE WHEN S.create_individual_invoice = 'y' THEN 1 ELSE 0 END
		WHEN NOT MATCHED THEN
				INSERT
				(netting_parent_group_id,
					netting_group_name,
					effective_date,
					invoice_template,
					create_individual_invoice)
				VALUES(
					S.netting_parent_group_id,
					S.netting_group_name,
					S.effective_date,
					CASE WHEN S.invoice_template = 0 THEN NULL ELSE S.invoice_template END,
					CASE WHEN S.create_individual_invoice = 'y' THEN 1 ELSE 0 END
				);
			
		DECLARE @new_id3 INT
		IF @flag = 'i'
			SET @new_id3 = IDENT_CURRENT('netting_group')
		ELSE
			SELECT @new_id3 = netting_group_id FROM #temp_settlement_netting2
		
		MERGE INTO netting_group_detail T2
		   USING #temp_settlement_netting2 S2 
			  ON T2.netting_group_id = S2.netting_group_id
		WHEN MATCHED THEN
		   UPDATE 
			  SET	netting_group_id = S2.netting_group_id,
					source_counterparty_id = S2.counterparty_id
		WHEN NOT MATCHED THEN
				INSERT
				(netting_group_id,
					source_counterparty_id)
				VALUES(
					@new_id3,
					S2.counterparty_id
				);
				
		DECLARE @new_id4 INT
		IF @flag = 'i'
			SET @new_id4 = IDENT_CURRENT('netting_group_detail')
		ELSE
			SELECT @new_id4 = netting_group_detail_id FROM netting_group_detail ngd WHERE ngd.netting_group_id = @new_id3
			
		
		--SELECT  * FROM netting_group_detail_contract ngc WHERE ngc.netting_group_detail_id = @new_id4
			--SELECT * FROM #temp_settlement_netting_grid2 
		DELETE FROM netting_group_detail_contract
		WHERE netting_contract_id IN (
			SELECT ngc.netting_contract_id FROM netting_group_detail_contract ngc			
		LEFT JOIN #temp_settlement_netting_grid2 tcg ON tcg.netting_contract_id = ngc.netting_contract_id
			WHERE tcg.netting_contract_id IS NULL AND ngc.netting_group_detail_id = @new_id4
		)
			
		
		MERGE INTO netting_group_detail_contract T3
		   USING #temp_settlement_netting_grid2 S3
			  ON T3.netting_group_detail_id = @new_id4 AND T3.netting_contract_id = S3.netting_contract_id
		WHEN MATCHED THEN
		   UPDATE 
			  SET	source_contract_id = S3.contract_id,
					contract_description = S3.contract_description
		WHEN NOT MATCHED by target THEN
				INSERT
				(netting_group_detail_id,
					source_contract_id,
					contract_description)
				VALUES(
					@new_id4,
					S3.contract_id,
					S3.contract_description
				);
				
				
			
		
		Exec spa_ErrorHandler 0, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'Success', 
					'Changes have been saved successfully.', ''
				
	END TRY
	BEGIN CATCH
		Exec spa_ErrorHandler @@ERROR, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'DB Error', 
					'Data update failed.', ''
	END CATCH
END
ELSE IF @flag='d'
BEGIN
	BEGIN TRY
		DELETE ngdc
		FROM netting_group_detail_contract ngdc
		INNER JOIN netting_group_detail ngd
			ON ngd.netting_group_detail_id = ngdc.netting_group_detail_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@netting_group_id) s
			ON s.item = ngd.netting_group_id

		DELETE ngd
		FROM netting_group_detail ngd
		INNER JOIN dbo.SplitCommaSeperatedValues(@netting_group_id) s
			ON s.item = ngd.netting_group_id
		
		DELETE ng 
		FROM netting_group ng
		INNER JOIN dbo.SplitCommaSeperatedValues(@netting_group_id) s
			ON s.item = ng.netting_group_id
		
		EXEC spa_ErrorHandler 0, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'Success', 
					'Changes have been saved successfully.', ''
		
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR, 'Settlement Netting Group', 
					'spa_settlement_netting_group', 'DB Error', 
					'Data delete failed.', ''
	END CATCH
	

END

Else if @flag='y'
BEGIN
	SELECT cg.contract_id [contract_id], cg.contract_name [contract_name]
			  FROM contract_group cg
			  ORDER BY cg.contract_name
	/*
	DECLARE @netting_detail_id INT = NULL
	
	IF @netting_group_id IS NOT NULL
	BEGIN
		SELECT @netting_detail_id = netting_group_detail_id FROM netting_group_detail ngd WHERE ngd.netting_group_id = @netting_group_id
		
		SELECT cg.contract_id [contract_id], cg.contract_name [contract_name]
		  FROM contract_group cg
					LEFT JOIN netting_group_detail_contract ngdc ON ngdc.source_contract_id = cg.contract_id 
		WHERE ngdc.source_contract_id IS NULL 
			OR ngdc.netting_group_detail_id = @netting_detail_id
		ORDER BY cg.contract_name
	END
	ELSE
		BEGIN
			SELECT cg.contract_id [contract_id], cg.contract_name [contract_name]
			  FROM contract_group cg
						LEFT JOIN netting_group_detail_contract ngdc ON ngdc.source_contract_id = cg.contract_id 
			WHERE ngdc.source_contract_id IS NULL 
			ORDER BY cg.contract_name
		END
	*/
	
		
END	
GO
