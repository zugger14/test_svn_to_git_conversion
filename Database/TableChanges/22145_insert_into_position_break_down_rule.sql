DECLARE @phy_month INT
DECLARE @pricing_term INT
DECLARE @strip_from INT
DECLARE @strip_to INT
DECLARE @lag INT 
DECLARE @phy_day INT
DECLARE @multiplier INT

SET @phy_month = 1
SET @pricing_term = -2
SET @strip_from = 1
SET @strip_to = 1
SET @lag =1
SET @phy_day = 1
SET @multiplier =1

WHILE @phy_month <= 12
BEGIN
	IF NOT EXISTS(SELECT 1 FROM position_break_down_rule WHERE lag = @lag AND pricing_term = @pricing_term AND phy_month = @phy_month AND strip_from=@strip_from and strip_to=@strip_to)   
	BEGIN
		INSERT INTO position_break_down_rule(strip_from, lag, strip_to, phy_month, phy_day, multiplier, pricing_term)
		SELECT @strip_from, @lag, @strip_to, @phy_month, @phy_day, @multiplier, @pricing_term
	END
	ELSE
	BEGIN
		PRINT('Data for lag: 1 AND phy_month: ' + CAST(@phy_month AS VARCHAR) + ' AND pricing_term : ' + CAST(@pricing_term as VARCHAR) + ' already exists.' )
	END   
	SET @phy_month = @phy_month + 1
END
