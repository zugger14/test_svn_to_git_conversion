IF OBJECT_ID(N'[dbo].[spa_create_rec_compliance_sold_report]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_create_rec_compliance_sold_report]
GO




--EXEC spa_create_rec_compliance_sold_report '96', null, null, 5118, 2005


CREATE PROCEDURE [dbo].[spa_create_rec_compliance_sold_report]
		@sub_entity_id varchar(100), 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@compliance_state int,
		@compliance_year int,
		@assignment_type_value_id int = 5146,
		@convert_uom_id int,
		@counterparty varchar(100) = NULL
					  
AS
SET NOCOUNT ON 

EXEC spa_create_rec_compliance_report
		@sub_entity_id, 
		@strategy_entity_id, 
		@book_entity_id, 
		@compliance_state,
		@compliance_year,
		@assignment_type_value_id,
		@convert_uom_id,
		null,
		44
		--,@counterparty


