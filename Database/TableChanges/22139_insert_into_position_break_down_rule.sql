DECLARE @phy_month INT
DECLARE @pricing_term INT

SET @phy_month = 1
SET @pricing_term = 1

WHILE @phy_month <= 12
BEGIN

    WHILE @pricing_term <= 6
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM position_break_down_rule WHERE lag = 0 AND pricing_term = @pricing_term * -1 AND phy_month = @phy_month AND strip_from=6 and strip_to=0)   
		BEGIN
			INSERT INTO position_break_down_rule(strip_from, lag, strip_to, phy_month, phy_day, multiplier, pricing_term)
			SELECT 6, 0, 0, @phy_month, 1, 1, @pricing_term * -1
		END
		ELSE
			PRINT('Data for lag: 0 AND phy_month: ' + CAST(@phy_month AS VARCHAR) + ' AND pricing_term : ' + CAST(@pricing_term * -1 as VARCHAR) + ' already exists.' )


		IF NOT EXISTS(SELECT 1 FROM position_break_down_rule WHERE lag = 1 AND pricing_term = (@pricing_term + 1) * -1 AND phy_month = @phy_month AND strip_from = 6 and strip_to=0)   
		BEGIN
			INSERT INTO position_break_down_rule(strip_from, lag, strip_to, phy_month, phy_day, multiplier, pricing_term)
			SELECT 6, 1, 0, @phy_month, 1, 1, (@pricing_term + 1) * -1
		END
		ELSE
			PRINT('Data for lag: 1 AND phy_month: ' + CAST(@phy_month AS VARCHAR) + ' AND pricing_term : ' + CAST((@pricing_term + 1) * -1 as VARCHAR) + ' already exists.' )




		SET @pricing_term = @pricing_term + 1
	END

	SET @pricing_term = 1
    SET @phy_month = @phy_month + 1
END



