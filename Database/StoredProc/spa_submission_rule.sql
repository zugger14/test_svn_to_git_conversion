IF OBJECT_ID (N'[dbo].[spa_submission_rule]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_submission_rule]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Author: Runaj Khatiwada
	Create date: 2019-05-29

	This proc will be used to perform select, insert, update and delete from setup_submission_rule table

	Parameters:
		@flag	:	Operation flag that decides the action to be performed.
					'main_grid_refresh' --> to refresh main grid in left pannel
					'grid_refresh'	--> to display the data in details grid
					'save_data'	--> to insert/update/delete in setup_submission_rule table
		@submission_type :	Submission type (Static Data Type ID 44700)
		@grid_xml	:	Data from editable grid of Submission Rule
		@delete_rule_ids :	Multile Rule IDs which are to be deleted
*/

CREATE PROCEDURE [dbo].[spa_submission_rule]
	@flag VARCHAR(25),
	@submission_type INT = NULL,
	@grid_xml XML = NULL,
	@delete_rule_ids VARCHAR(MAX) = NULL
AS
 /*-------------------Debug Section---------------
DECLARE @flag VARCHAR(25) = 'save_data',
		@submission_type INT = 44703,@delete_rule_ids VARCHAR(MAX) = NULL,
		@grid_xml XML = '<GridSubmissionRule><GridRow rule_id="" submission_type_id="44703" confirmation_type="" legal_entity_id="7823" sub_book_id="6" contract_id="" counterparty_id2="" deal_type_id="" deal_sub_type_id="" deal_template_id="" commodity_id="" location_group_id="" location_id="" counterparty_id="" counterpaty_type="" index_group="" entity_type="" curve_id="" buy_sell="" confirm_status_id="" deal_status_id="" ></GridRow></GridSubmissionRule>'
SELECT @flag='save_data',@deleted_rule_ids='43,43',@grid_xml='<GridSubmissionRule><GridRow rule_id="42" submission_type_id="44703" confirmation_type="46600" legal_entity_id="8876" sub_book_id="" contract_id="" counterparty_id2="" deal_type_id="" deal_sub_type_id="" deal_template_id="" commodity_id="" location_group_id="" location_id="" counterparty_id="" counterpaty_type="" index_group="" entity_type="" curve_id="" buy_sell="" confirm_status_id="" deal_status_id="" ></GridRow><GridRow rule_id="44" submission_type_id="44703" confirmation_type="46602" legal_entity_id="8876" sub_book_id="" contract_id="" counterparty_id2="" deal_type_id="" deal_sub_type_id="" deal_template_id="" commodity_id="" location_group_id="" location_id="" counterparty_id="" counterpaty_type="" index_group="" entity_type="" curve_id="" buy_sell="" confirm_status_id="" deal_status_id="" ></GridRow></GridSubmissionRule>'
 -----------------------------------------------*/

SET NOCOUNT ON
IF @flag = 'grid_refresh'
BEGIN
	SELECT rule_id, submission_type_id, confirmation_type, legal_entity_id, sub_book_id, contract_id,
		   counterparty_id2, deal_type_id, deal_sub_type_id, deal_template_id, commodity_id, location_group_id,
		   location_id, counterparty_id, counterpaty_type, index_group, entity_type, curve_id, buy_sell,
		   confirm_status_id, deal_status_id, physical_financial_flag, broker_id
	FROM setup_submission_rule
	WHERE submission_type_id = @submission_type
END
ELSE IF @flag = 'main_grid_refresh'
BEGIN
	SELECT value_id submission_type_id,
		   sdv.code submission_type
	FROM static_data_value sdv
	WHERE sdv.type_id = 44700	
END
ELSE IF @flag = 'save_data'
BEGIN
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

	IF OBJECT_ID('tempdb..#setup_submission_rule') IS NOT NULL
		DROP TABLE #setup_submission_rule
	
	CREATE TABLE #setup_submission_rule (
		[rule_id] INT NULL,
		[submission_type_id] INT NULL,
		[confirmation_type] INT NULL,
		[legal_entity_id] INT NULL,
		[sub_book_id] INT NULL,
		[contract_id] INT NULL,
		[counterparty_id2] INT NULL,
		[deal_type_id] INT NULL,
		[deal_sub_type_id] INT NULL,
		[deal_template_id] INT NULL,
		[commodity_id] INT NULL,
		[location_group_id] INT NULL,
		[location_id] INT NULL,
		[counterparty_id] INT NULL,
		[counterpaty_type] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[index_group] INT NULL,
		[entity_type] INT NULL,
		[curve_id] INT NULL,
		[buy_sell] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[confirm_status_id] INT NULL,
		[deal_status_id] INT NULL,
		[physical_financial_flag] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[broker_id] INT NULL
	)
	
	INSERT INTO #setup_submission_rule
	SELECT NULLIF(rule_id, '') rule_id,
		   NULLIF(submission_type_id, '') submission_type_id,
		   NULLIF(confirmation_type, '') confirmation_type,
		   NULLIF(legal_entity_id, '') legal_entity_id,
		   NULLIF(sub_book_id, '') sub_book_id,
		   NULLIF(contract_id, '') contract_id,
		   NULLIF(counterparty_id2, '') counterparty_id2,
		   NULLIF(deal_type_id, '') deal_type_id,
		   NULLIF(deal_sub_type_id, '') deal_sub_type_id,
		   NULLIF(deal_template_id, '') deal_template_id,
		   NULLIF(commodity_id, '') commodity_id,
		   NULLIF(location_group_id, '') location_group_id,
		   NULLIF(location_id, '') location_id,
		   NULLIF(counterparty_id, '') counterparty_id,
		   NULLIF(counterpaty_type, '') counterpaty_type,
		   NULLIF(index_group, '') index_group,
		   NULLIF(entity_type, '') entity_type,
		   NULLIF(curve_id, '') curve_id,
		   NULLIF(buy_sell, '') buy_sell,
		   NULLIF(confirm_status_id, '') confirm_status_id,
		   NULLIF(deal_status_id, '') deal_status_id,
		   NULLIF(physical_financial_flag, '') physical_financial_flag,
		   NULLIF(broker_id,'') broker_id
	FROM OPENXML(@idoc, '/GridSubmissionRule/GridRow', 1)
	WITH #setup_submission_rule
	
	MERGE setup_submission_rule AS t
		USING (
			SELECT rule_id, submission_type_id, confirmation_type, legal_entity_id, sub_book_id, contract_id, counterparty_id2, deal_type_id, deal_sub_type_id, deal_template_id, commodity_id, location_group_id, location_id, counterparty_id, counterpaty_type, index_group, entity_type, curve_id, buy_sell, confirm_status_id, deal_status_id,physical_financial_flag, broker_id
			FROM #setup_submission_rule
			) AS s
		ON (s.rule_id = t.rule_id) 
		WHEN NOT MATCHED BY TARGET 
		THEN 
			INSERT(submission_type_id, confirmation_type, legal_entity_id, sub_book_id, contract_id, counterparty_id2, deal_type_id, deal_sub_type_id, deal_template_id, commodity_id, location_group_id, location_id, counterparty_id, counterpaty_type, index_group, entity_type, curve_id, buy_sell, confirm_status_id, deal_status_id,physical_financial_flag, broker_id)
			VALUES(s.submission_type_id, s.confirmation_type, s.legal_entity_id, s.sub_book_id, s.contract_id, s.counterparty_id2, s.deal_type_id, s.deal_sub_type_id, s.deal_template_id, s.commodity_id, s.location_group_id, s.location_id, s.counterparty_id, s.counterpaty_type, s.index_group, s.entity_type, s.curve_id, s.buy_sell, s.confirm_status_id, s.deal_status_id,s.physical_financial_flag, broker_id)
		WHEN MATCHED 
		THEN 
			UPDATE 
			SET confirmation_type = s.confirmation_type,
				legal_entity_id = s.legal_entity_id,
				sub_book_id = s.sub_book_id,
				contract_id = s.contract_id,
				counterparty_id2 = s.counterparty_id2,
				deal_type_id = s.deal_type_id,
				deal_sub_type_id = s.deal_sub_type_id,
				deal_template_id = s.deal_template_id,
				commodity_id = s.commodity_id,
				location_group_id = s.location_group_id,
				location_id = s.location_id,
				counterparty_id = s.counterparty_id,
				counterpaty_type = s.counterpaty_type,
				index_group = s.index_group,
				entity_type = s.entity_type,
				curve_id = s.curve_id,
				buy_sell = s.buy_sell,
				confirm_status_id = s.confirm_status_id,
				deal_status_id = s.deal_status_id,
				physical_financial_flag = s.physical_financial_flag,
				broker_id = s.broker_id
		;

	IF NULLIF(@delete_rule_ids, '') IS NOT NULL
	BEGIN
		DELETE s
		FROM setup_submission_rule s
		INNER JOIN dbo.SplitCommaSeperatedValues(@delete_rule_ids) d
			ON d.item = s.rule_id
	END

	EXEC spa_ErrorHandler 0, 'setup_submission_rule', 'spa_submission_rule', 'Success' , 'Data saved Successfully.', ''
END
GO
