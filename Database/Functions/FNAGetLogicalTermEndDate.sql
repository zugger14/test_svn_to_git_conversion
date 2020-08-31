IF OBJECT_ID('[dbo].[FNAGetLogicalTermEndDate]', 'FN') IS NOT NULL
	DROP FUNCTION [dbo].[FNAGetLogicalTermEndDate]

GO

CREATE FUNCTION [dbo].[FNAGetLogicalTermEndDate] (
	@term_rule INT,
	@date DATETIME
)
RETURNS DATETIME
AS
/*
--## TEST DATA ##
DECLARE	@term_rule INT = 19318,
		@date DATETIME = '2018-11-21'
--*/
BEGIN
	DECLARE @term_end DATETIME
	DECLARE @mult INT
	DECLARE @term_frequency CHAR(1)

	-- 19307 - Today
	-- 19308 - Next Day
	-- 19309 - Next Business Day
	-- 19310 - Prior Day
	-- 19311 - Next Week
	-- 19312 - Next Month
	-- 19313 - Next Quarter
	-- 19314 - Next year
	-- 19315 - Balance of the Week
	-- 19316 - Balance of the Month
	-- 19317 - Balance of the Quarter
	-- 19318 - Balance of the Year
	
	SET @term_rule = ISNULL(NULLIF(@term_rule, ''), 19307) -- To handle Logical Term no selection

	IF @term_rule IN (19307, 19308, 19309, 19310) -- Day
	BEGIN
		SET @term_end = @date
	END
	ELSE IF @term_rule = 19311 OR @term_rule = 19315 -- Week
	BEGIN
		SET @term_end = DATEADD(dd,-2, DATEADD(ww, DATEDIFF(ww, 0, @date) + 1, 0))
	END
	ELSE
	BEGIN
		IF @term_rule = 19314 OR @term_rule = 19318 -- Annual/Year
		BEGIN
			SET @mult = 12
			SET @term_frequency = 'a'
		END
		ELSE IF @term_rule = 19313 OR @term_rule = 19317 -- Quarter
		BEGIN
			SET @mult = 3
			SET @term_frequency = 'q'
		END
		ELSE IF @term_rule = 19312 OR @term_rule = 19316 -- Month
		BEGIN
			SET @mult = 1
			SET @term_frequency = 'm'
		END

		SET @date = dbo.FNAGetTermStartDate(@term_frequency, @date, 0)
		
		SET @term_end = DATEADD(dd,-1, DATEADD(mm, DATEDIFF(m, 0, @date) + @mult, 0))
	END

	RETURN @term_end
	--SELECT @term_end
END