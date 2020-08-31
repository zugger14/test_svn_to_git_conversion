SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Function to get gas volume among supply and demand with gas logic

	Parameters
	@supply_position	: supply side position
	@demand_position	: demand side position
	@case_type			: type of gas case. e.g. storage_injection, non_storage, storage_withdrawal

	Logic to pcik:
	supply/demand sign rule => supply is always positive; demand is always negative.
	storage injection demand volume rule => in case of storage injection, demand side volume is assumed to be very large.

*/

CREATE OR ALTER FUNCTION [dbo].[FNAGetGasSupplyDemandVol]
(
	@supply_position NUMERIC(10,4) NULL,
	@demand_position NUMERIC(10,4) NULL,
	@case_type VARCHAR(20) NULL
)
RETURNS NUMERIC(10,4)
AS
BEGIN
	DECLARE @return_value NUMERIC(10,4)

	IF @case_type = 'storage_injection' --incase of injection, demand volume is assumed to be large, hence we only see supply volume to pick. pick supply if positive. negative supply is violation of sign rule hence pick 0.
	BEGIN
		IF @supply_position > 0
		BEGIN
			SET @return_value = @supply_position
		END
		ELSE
		BEGIN
			SET @return_value = 0
		END
	END
	ELSE
	BEGIN
		IF @supply_position < 0 OR @demand_position > 0 --in case if any of supply/demand sign rule is violated, then return 0.
		BEGIN
			SET @return_value = 0
		END
		ELSE 
		BEGIN
			--in normal case where, supply/demand sign rule is obeyed, pick minimum among supply and demand.
			SET @return_value = IIF(@supply_position < ABS(@demand_position), @supply_position, ABS(@demand_position))
		END
	END

	RETURN @return_value

END




GO
