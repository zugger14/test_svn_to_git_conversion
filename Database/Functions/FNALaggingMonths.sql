IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNALaggingMonths]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNALaggingMonths]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-10-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-08-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-09-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-10-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-11-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2008-12-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2009-01-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2009-02-01')
--select * FROM dbo.FNALaggingMonths (6, 2, 6,'2008-09-01','2009-09-01')

CREATE FUNCTION [dbo].[FNALaggingMonths] (@strip_months int,@lagging_months int,@strip_item_months INT,@Start_term DATETIME,@term DATETIME)
returns @tt table(term DATETIME,grp int)
AS
BEGIN

/*
DECLARE @strip_months int,@lagging_months int,@strip_item_months INT ,@Start_term DATETIME,@term datetime
set @strip_months=6
SET @lagging_months=0
SET @strip_item_months=3
SET @Start_term='2011-01-01'
SET @term ='2011-02-01'
--SELECT DATEADD(mm,-2-1-0,'2008-01-01')
*/

DECLARE @no_month int,@add_month int
SET @no_month=DATEDIFF(mm,@Start_term,@term)+1

SELECT @add_month=CASE WHEN (@no_month%@strip_item_months)=0 AND @no_month<>0
						THEN ((@no_month/@strip_item_months)-1)* @strip_item_months
						ELSE (@no_month/@strip_item_months)* @strip_item_months end;


--SELECT @add_month,@no_month,@strip_item_months;

	WITH term_lag (term,lbl,grp) AS 
	(
	SELECT @Start_term,1,@add_month  WHERE @strip_months<=1
		UNION ALL 
	SELECT DATEADD(mm,-@lagging_months-1+@add_month,@Start_term),1,@add_month  WHERE @strip_months>1
		UNION ALL
	SELECT DATEADD(mm,(@lagging_months+lbl-@add_month),@Start_term),lbl+1,@add_month FROM term_lag WHERE lbl<@strip_item_months and @strip_months=0 and @strip_item_months>1
		UNION ALL
	SELECT DATEADD(mm,-1*(@lagging_months+lbl+1-@add_month),@Start_term),lbl+1,@add_month FROM term_lag WHERE lbl<@strip_months

	)

	INSERT INTO @tt SELECT term,grp FROM term_lag

RETURN

END
