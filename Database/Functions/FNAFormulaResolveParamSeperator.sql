
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAFormulaResolveParamSeperator]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFormulaResolveParamSeperator]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Resolce parameter seperator for formula

	Parameters :
	@formula : Formula string
	@mode : Type 's' to save mode, 'v' to view mode

	Returns parsed formula string
 */

CREATE FUNCTION [dbo].[FNAFormulaResolveParamSeperator] (@formula varchar(max),@mode char(1))
RETURNS varchar(max) AS  
BEGIN 
	DECLARE @formula_parameter_seperator varchar(10) = ';'

	IF @mode =  's'
	BEGIN
		SET @formula = REPLACE(@formula, ',', '#####');
		SET @formula = REPLACE(@formula, @formula_parameter_seperator, ',');
		SET @formula = REPLACE(@formula, '#####', '.');
	END
	ELSE IF @mode =  'v'
	BEGIN
		SET @formula = REPLACE(@formula, '.','#####');
		SET @formula = REPLACE(@formula, ',', @formula_parameter_seperator);
		SET @formula = REPLACE(@formula, '#####', ',');
	END 

	RETURN @formula

END