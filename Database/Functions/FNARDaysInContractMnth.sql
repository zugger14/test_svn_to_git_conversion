IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARDaysInContractMnth]') AND TYPE IN(N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARDaysInContractMnth]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARDaysInContractMnth] (@contract_id INT,@counterparty_id INT, @pDate DATETIME)
RETURNS INT
AS
BEGIN

--DECLARE @contract_id INT, @pDate DATETIME
--SET @contract_id = 229
--SET @pDate = '2016-05-12'



	DECLARE @start_date DATETIME, @end_date DATETIME,@no_of_days INT

	SELECT @start_date = ISNULL(contract_start_date,term_start)  FROM contract_group cg INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = @counterparty_id WHERE cg.contract_id = @contract_id AND  YEAR(@pDate) = YEAR( ISNULL(contract_start_date,term_start))  AND MONTH(@pDate) = MONTH( ISNULL(contract_start_date,term_start))
	SELECT @end_date = ISNULL(contract_end_date,term_end)  FROM contract_group cg INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = @counterparty_id WHERE cg.contract_id = @contract_id AND   YEAR(@pDate) = YEAR( ISNULL(contract_end_date,term_end))  AND MONTH(@pDate) = MONTH( ISNULL(contract_end_date,term_end))


	IF @start_date IS NOT NULL OR @end_date IS NOT NULL
	BEGIN
		SELECT @start_date = ISNULL(@start_date,CONVERT(VARCHAR(10),CAST(YEAR(@pDate) AS VARCHAR)+'-'+CAST(MONTH(@pDate) AS VARCHAR)+'-01'))
		SELECT @end_date = ISNULL(@end_date,DATEADD(m,1,CONVERT(VARCHAR(10),CAST(YEAR(@pDate) AS VARCHAR)+'-'+CAST(MONTH(@pDate) AS VARCHAR)+'-01'))-1)
		SELECT @no_of_days = DATEDIFF(d,@start_date,@end_date)+1
	END
	ELSE IF EXISTS(SELECT 'X' FROM contract_group cg INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = @counterparty_id WHERE cg.contract_id = @contract_id AND @pDate NOT BETWEEN COALESCE(contract_start_date,term_start,'1900-01-01') AND  COALESCE(contract_end_date,term_end,'9999-01-01'))
	BEGIN
		SELECT @no_of_days = 0
	END

	ELSE
	BEGIN
    SELECT @no_of_days =  CASE WHEN MONTH(@pDate) IN (1, 3, 5, 7, 8, 10, 12) THEN 31
                WHEN MONTH(@pDate) IN (4, 6, 9, 11) THEN 30
                ELSE CASE WHEN (YEAR(@pDate) % 4    = 0 AND
                                YEAR(@pDate) % 100 != 0) OR
                               (YEAR(@pDate) % 400  = 0)
                          THEN 29
                          ELSE 28
                     END
           END
	END

	RETURN  @no_of_days

END
GO
