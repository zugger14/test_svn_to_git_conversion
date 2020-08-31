/****** Object:  UserDefinedFunction [dbo].[FNAContractBillingDate]    Script Date: 03/27/2011 18:37:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAContractBillingDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAContractBillingDate]
GO

CREATE FUNCTION dbo.FNAContractBillingDate(@contract_id INT,@prod_date DATETIME)
RETURNS @contract_date TABLE(contract_id INT, udf_from_date DATETIME,udf_to_date DATETIME,billing_from_hour VARCHAR(10) ,billing_to_hour VARCHAR(10))
AS
	BEGIN

	DECLARE @prod_month INT
	SELECT @prod_month = month(@prod_date);
	
	INSERT INTO @contract_date
	SELECT 
		@contract_id,
		ISNULL(CASE WHEN billing_cycle=988 THEN
			CASE 
				WHEN @prod_month<=3 then
					cast(cast(year(@prod_date) AS VARCHAR)+'-01-01' AS DATETIME )
				WHEN @prod_month>=4 and @prod_month<=6 then
					cast(cast(year(@prod_date) AS VARCHAR)+'-04-01' AS DATETIME )
				WHEN @prod_month>=7 and @prod_month<=9 then
					cast(cast(year(@prod_date) AS VARCHAR)+'-07-01' AS DATETIME )
				WHEN @prod_month>=10 and @prod_month<=12 then
					cast(cast(year(@prod_date) AS VARCHAR)+'-10-01' AS DATETIME )
			END
		ELSE
			(cast(cast(YEAR(dateadd(month,0,@prod_date)) AS VARCHAR )+'-'+cast(MONTH(dateadd(month,0,@prod_date)) AS VARCHAR )+'-'+cast(billing_FROM_date AS VARCHAR ) AS DATETIME )) END,@prod_Date) AS udf_from_date,
		
		ISNULL(CASE WHEN billing_cycle=988 THEN
			CASE 
			WHEN @prod_month<=3 then
				cast(cast(year(@prod_date) AS VARCHAR)+'-03-31 23:59:59.998' AS DATETIME )
			WHEN @prod_month>=4 and @prod_month<=6 then
				cast(cast(year(@prod_date) AS VARCHAR)+'-06-31 23:59:59.998' AS DATETIME )
			WHEN @prod_month>=7 and @prod_month<=9 then
				cast(cast(year(@prod_date) AS VARCHAR)+'-09-30 23:59:59.998' AS DATETIME )
			WHEN @prod_month>=10 and @prod_month<=12 then
				cast(cast(year(@prod_date) AS VARCHAR)+'-12-31 23:59:59.998' AS DATETIME )
		END 
		ELSE
			(cast(cast(YEAR(dateadd(month,1,@prod_date)) AS VARCHAR )+'-'+cast(MONTH(dateadd(month,1,@prod_date)) AS VARCHAR )+'-'+cast(billing_to_date AS VARCHAR ) AS DATETIME )) END,
			CASE WHEN billing_to_hour IS NOT NULL THEN DATEADD(DAY,1,DATEADD(MONTH,1,@prod_Date)-1) ELSE DATEADD(MONTH,1,@prod_Date)-1 END) AS udf_to_date,
			ISNULL(billing_from_hour-1,0),
			ISNULL(billing_to_hour-2,23)			
			FROM 
					contract_group cg 
					LEFT JOIN contract_group_detail cgd ON cg.contract_id=cgd.contract_id
						AND cgd.prod_type=
					CASE WHEN ISNULL(cg.term_start,'')='' THEN 't' 
						 WHEN dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(@prod_date) THEN 'p'
						 ELSE 't' END 		
					LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id=cg.contract_charge_type_id
					LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id=cct.contract_charge_type_id
						AND cctd.prod_type=
					CASE WHEN ISNULL(cg.term_start,'')='' THEN 't' 
						 WHEN dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(@prod_date) THEN 'p'
						 ELSE 't' END 			
					LEFT JOIN formula_nested fn ON fn.formula_group_id=ISNULL(cctd.formula_id,cgd.formula_id)
			WHERE 
					cg.contract_id=@contract_id   
	
	RETURN 
			
	END