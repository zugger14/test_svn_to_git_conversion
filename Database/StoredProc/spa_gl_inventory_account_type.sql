/****** Object:  StoredProcedure [dbo].[spa_gl_inventory_account_type]    Script Date: 10/07/2009 09:55:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_gl_inventory_account_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_gl_inventory_account_type]
/****** Object:  StoredProcedure [dbo].[spa_gl_inventory_account_type]    Script Date: 10/07/2009 09:55:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spa_gl_inventory_account_type]
	@flag char(1),
	@gl_account_id int=NULL,
	@group_id INT=NULL,
	@account_type_value_id INT=NULL,
	@account_type_name VARCHAR(100)=NULL,
	@sub_entity_id VARCHAR(100)=NULL,
	@stra_entity_id VARCHAR(100)=NULL,
	@book_entity_id VARCHAR(100)=NULL,
	@gl_number_id INT=NULL,
	@use_broker_fees CHAR(1)='n',
	@cost_calc_type CHAR(1)='w',
	@assignment_type_id INT=NULL,
	@assignment_gl_number_id INT=NULL,
	@technology INT=NULL,
	@jurisdiction INT=NULL,
	@gen_state INT=NULL,
	@curve_id INT=NULL,
	@vintage INT=NULL,
	@generator_id INT=NULL,
	@commodity_id INT=NULL,
	@unit_expense CHAR(1)='n',
	@location_id INT =  NULL
AS

DECLARE @sql VARCHAR(8000)

IF @flag='s'
BEGIN
	SET @sql='	
		SELECT 
			gl_account_id [ID],
			account_type_name [Account Name],
			actype.code [Account Type],
			ph1.entity_name [Sub],
			ph2.entity_name [Strategy],
			ph3.entity_name [Book],
			sml.location_name [Location],
			tech.code AS [Technology],
			jur.code AS [Jurisdiction],
			gen_state.code AS [Generation State],
			spcd.curve_id AS [Index Name],
			vintage AS [Vintage],
			rg.name AS [Generation Source],
			sc.commodity_id AS [Commodity],
			gsm.gl_account_name [Gl Account],
			use_broker_fees [Use Broker Fees],
			CASE WHEN cost_calc_type=''w'' THEN ''WACOG'' ELSE ''Deal Price'' END AS [Cost Calc Type],
			assign.code AS [Assignment Type],
			gsm1.gl_account_name AS [Assignment Gl Account]

		FROM
			inventory_account_type glact
			LEFT JOIN static_data_value actype ON actype.value_id=glact.account_type_value_id
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=glact.sub_entity_id
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id=glact.stra_entity_id
			LEFT JOIN portfolio_hierarchy ph3 ON ph3.entity_id=glact.book_entity_id
			LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id=glact.gl_number_id
			LEFT JOIN static_data_value assign ON assign.value_id=glact.assignment_type_id
			LEFT JOIN gl_system_mapping gsm1 ON gsm1.gl_number_id=glact.gl_number_id
			LEFT JOIN static_data_value tech ON tech.value_id=glact.technology
			LEFT JOIN static_data_value jur ON jur.value_id=glact.jurisdiction
			LEFT JOIN static_data_value gen_state ON jur.value_id=glact.gen_state
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=glact.curve_id
			LEFT JOIN rec_generator rg ON rg.generator_id=glact.generator_id
			LEFT JOIN source_commodity sc ON sc.source_commodity_id=glact.commodity_id
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=glact.location_id
		WHERE 1=1 '
		+CASE WHEN @group_id IS NOT NULL THEN ' AND glact.group_id='+CAST(@group_id AS VARCHAR) ELSE '' END
		EXEC spa_print @sql
		EXEC(@sql)

END
ELSE IF @flag='a'
BEGIN
	SELECT  gl_account_id,
			group_id,
			account_type_value_id ,
			account_type_name,
			sub_entity_id ,
			stra_entity_id,
			book_entity_id,
			glact.gl_number_id,
			use_broker_fees,
			cost_calc_type,
			assignment_type_id,
			assignment_gl_number_id,
			technology,
			jurisdiction,
			gen_state,
			curve_id,
			vintage,
			generator_id,
			glact.commodity_id,
			gsm.gl_account_name,
			gsm1.gl_account_name,
			unit_expense,
			glact.location_id,
			sml.Location_Name
	FROM
		inventory_account_type glact
		LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id=glact.gl_number_id
		LEFT JOIN gl_system_mapping gsm1 ON gsm1.gl_number_id=glact.assignment_gl_number_id
		LEFT JOIN source_minor_location sml ON sml.source_major_location_ID = glact.location_id
	WHERE
		gl_account_id=@gl_account_id

END	
ELSE IF @flag='i' OR @flag='u'
BEGIN

	IF @flag='u'
		delete from 
		inventory_account_type
	where 
		gl_account_id =@gl_account_id

	SELECT 
		ph1.entity_id AS [Sub_id],
		ph2.entity_id AS [Stra_id],
		ph3.entity_id AS [Book_id]	
	INTO #book_structure 
		FROM
			(select [item] from dbo.splitcommaSeperatedValues(@book_entity_id))a
			LEFT JOIN portfolio_hierarchy ph3 ON ph3.entity_id=a.[item]
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id=ph3.parent_entity_id
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=ph2.parent_entity_id
		

	INSERT INTO #book_structure
		SELECT ph1.entity_id AS [Sub_id],
			   ph2.entity_id AS [Stra_id],
			   NULL AS [Book_id] 				  
		FROM
			(select [item] from dbo.splitcommaSeperatedValues(@stra_entity_id))a
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id=a.[item]
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=ph2.parent_entity_id		
		WHERE [item] NOT IN(select [Stra_id] FROM #book_structure)


	INSERT INTO #book_structure
		SELECT ph1.entity_id AS [Sub_id],
			   NULL AS [Stra_id],
			   NULL AS [Book_id] 	
		FROM
			(select [item] from dbo.splitcommaSeperatedValues(@sub_entity_id))a
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=a.[item]	
	 WHERE [item] NOT IN(select [Sub_id] FROM #book_structure)


	insert into inventory_account_type
		(
			group_id,
			account_type_value_id ,
			account_type_name,
			sub_entity_id ,
			stra_entity_id,
			book_entity_id,
			gl_number_id,
			use_broker_fees,
			cost_calc_type,
			assignment_type_id,
			assignment_gl_number_id,
			technology,
			jurisdiction,
			gen_state,
			curve_id,
			vintage,
			generator_id,
			commodity_id,
			unit_expense,
			location_id
		)
	SELECT 
			@group_id,
			@account_type_value_id ,
			@account_type_name,
			[sub_id],
			[stra_id],
			[book_id],
			@gl_number_id,
			@use_broker_fees,
			@cost_calc_type,
			@assignment_type_id,
			@assignment_gl_number_id,
			@technology,
			@jurisdiction,
			@gen_state,
			@curve_id,
			@vintage,
			@generator_id,
			@commodity_id,
			@unit_expense,
			@location_id
	FROM
		#book_structure 

	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "gl inventory account type", 
					"spa_gl_inventory_account_type", "DB Error", 
					"Error Inserting gl inventory account type.", ''
		else
			Exec spa_ErrorHandler 0, "gl inventory account type", 
					"spa_gl_inventory_account_type", "Status", 
					"Successfully saved gl inventory account type.","Recommendation"

END

ELSE IF @flag='d'
BEGIN
	delete from 
		inventory_account_type
	where 
		gl_account_id =@gl_account_id

	If @@ERROR <> 0
				Exec spa_ErrorHandler 1, "gl inventory account type", 
						"spa_gl_inventory_account_type", "DB Error", 
						"Error in Deleting gl inventory account type.", ''
			else
				Exec spa_ErrorHandler 0, "gl inventory account type", 
						"spa_gl_inventory_account_type","Status",
						"Successfully deleted gl inventory account type.","Recommendation"
	
END
ELSE IF @flag='g' -- select account name to show in drop down
	BEGIN
		SELECT DISTINCT gl_account_id,account_type_name
			FROM
			inventory_account_type
		WHERE
			account_type_name IS NOT NULL
				

	END












