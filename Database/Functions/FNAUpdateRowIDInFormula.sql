IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAUpdateRowIDInFormula]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAUpdateRowIDInFormula]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-02-21
-- Description:	Updates sequence no used in ROW(<sequence>) function when any formula is added/updated/deleted
-- Params:
--	@flag -	i: increment sequence
--			d: decrement sequence
--			h: hash current sequence by ### to prevent alteration by i or d
--			r: revert hashing done by h, replace ### by orginal sequence or Undefined
--			u: update sequence of the current formula to check for Undefined
--			o: update orphaned sequence with Undefined (happens when referenced row is deleted)
--	@formula_id - formula_id whose formula will be udpated
--	@cur_seq - sequence id of current formula, may be different from db value in case of updates
--	@min_seq - minium sequence id to change, flag o and h uses it for updating specific sequence, instead of a range (@min_seq - @max_seq)
--	@max_seq - maximum sequence id to change, flag r uses it for updating specific sequence, instead of a range (@min_seq - @max_seq)
-- ===============================================================================================================

CREATE FUNCTION dbo.FNAUpdateRowIDInFormula 
(
	@flag CHAR(1),
	@formula_id INT,
	@cur_seq INT,
	@min_seq INT,
	@max_seq INT
)
RETURNS varchar(8000)
AS
BEGIN
	--------Test Data START---------------
--	DECLARE @flag CHAR(1)
--	DECLARE @formula_id int
--	DECLARE @cur_seq INT
--	DECLARE @min_seq INT
--	DECLARE @max_seq INT
--	
--	SET @flag = 'i'
--	--SET @formula = 'DealVol * dbo.FNARow( 2 ) + dbo.FNARow (3) * dbo.FNARow(4 )'
--	SET @formula_id = 488
--	SET @cur_seq = 4
--	SET @min_seq = 1
--	SET @max_seq = 3
	--------Test Data END---------------

	DECLARE @increment_value INT
	DECLARE @tbl_formula AS TABLE (formula VARCHAR(8000), seq INT)
	DECLARE @new_formula VARCHAR(8000)
	DECLARE @undefined_string AS VARCHAR(30)
	
	SET @undefined_string = '-1'

	IF @min_seq IS NULL
		SET @min_seq = 0
		
	IF @max_seq IS NULL
		SET @max_seq = 999999
		
	--sanitize formula
	SELECT @new_formula = REPLACE(												--remove extra space between <NO> and )				
							REPLACE(											--remove extra space between dbo.FNARow and (
								REPLACE(formula, 'dbo.FNARow (', 'dbo.FNARow(')	--remove extra space between dbo.FNARow( and <NO>
								, 'dbo.FNARow( ', 'dbo.FNARow(')
							, ' )', ')')
	FROM formula_editor fe
	WHERE fe.formula_id = @formula_id

	--strip all number values from ROW() function.
	--Left join is done with a auto-number set to retrieve the ROW number values
	INSERT INTO @tbl_formula(formula, seq)
	SELECT formula, seq 
	FROM
	(SELECT @new_formula formula) t
	LEFT JOIN 
	(SELECT TOP 500 ROW_NUMBER() OVER (ORDER BY (object_id)) seq FROM sys.[columns]) n 
		ON t.formula LIKE '%dbo.FNARow(' + CAST(n.seq AS VARCHAR(10)) + ')%'

	--SELECT * FROM @tbl_formula
	IF @flag = 'o' --update orphaned sequence with Undefined (happens when referenced row is deleted)
	BEGIN
		SELECT @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(seq AS VARCHAR(10)) + ')'
								, 'dbo.FNARow(Undefined)') 
		FROM @tbl_formula
		WHERE seq = @min_seq
	END
	ELSE IF @flag = 'h' --hash current sequence by ### to prevent alteration by i or d
	BEGIN
		SELECT @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(seq AS VARCHAR(10)) + ')'
								, 'dbo.FNARow(###)') 
		FROM @tbl_formula
		WHERE seq = @min_seq
	END
	ELSE IF @flag = 'r' --revert hashing done by h, replace ### by updated sequence or Undefined
	BEGIN
		SET @new_formula = REPLACE(@new_formula, 'dbo.FNARow(###)'
						, 'dbo.FNARow(' + CASE WHEN @max_seq >= @cur_seq THEN @undefined_string ELSE CAST(@max_seq AS VARCHAR(5)) END  + ')')															 
	END
	ELSE IF @flag = 'u' --update sequence of the current formula to check for Undefined
	BEGIN
		SELECT @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(seq AS VARCHAR(10)) + ')'
								, 'dbo.FNARow(' + CASE WHEN seq >= @cur_seq THEN @undefined_string ELSE CAST(seq AS VARCHAR(10)) END  + ')')
		FROM @tbl_formula
		WHERE seq BETWEEN @min_seq AND @max_seq
	END
	ELSE IF @flag = 'i' --increment sequence
	BEGIN
		SET @increment_value = 1
		SELECT @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(seq AS VARCHAR(10)) + ')'
								, 'dbo.FNARow(' + CASE WHEN (seq + @increment_value) >= @cur_seq THEN @undefined_string ELSE CAST(seq + @increment_value AS VARCHAR(10)) END  + ')')
		FROM @tbl_formula
		WHERE seq BETWEEN @min_seq AND @max_seq
		ORDER BY seq DESC
	END
	ELSE IF @flag = 'd' --decrement sequence
	BEGIN
		SET @increment_value = -1
		SELECT @new_formula = REPLACE(@new_formula, 'dbo.FNARow(' + CAST(seq AS VARCHAR(10)) + ')'
								, 'dbo.FNARow(' + CASE WHEN (seq + @increment_value) >= @cur_seq THEN @undefined_string ELSE CAST(seq + @increment_value AS VARCHAR(10)) END  + ')')
		FROM @tbl_formula
		WHERE seq BETWEEN @min_seq AND @max_seq
		ORDER BY seq ASC
	END

	--SELECT @new_formula
	RETURN @new_formula
END
GO