
IF OBJECT_ID(N'[dbo].[spa_calexpo_counterparty]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calexpo_counterparty]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROC [dbo].[spa_calexpo_counterparty]
 @flag CHAR(1)
 AS
 
IF @flag = 's'
BEGIN
    SELECT source_counterparty_id,
           sc.counterparty_id,
           sc.counterparty_name,
           CASE 
                WHEN int_ext_flag = 'e' THEN 'EXTERNAL'
                ELSE CASE 
                          WHEN int_ext_flag = 'b' THEN 'Broker'
                          ELSE 'Internal'
                     END
           END [counterparty_type]
    FROM   source_counterparty AS sc
           RIGHT JOIN counterparty_credit_info AS cci
                ON  cci.Counterparty_id = sc.source_counterparty_id
    WHERE cci.check_apply IS NULL OR cci.check_apply = 'n' ORDER BY sc.counterparty_id ASC 
END
 
 GO