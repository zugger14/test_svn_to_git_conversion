
IF COL_LENGTH('monte_carlo_model_parameter', 'lambda') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD lambda float
END
GO
 --SELECT * FROM    monte_carlo_model_parameter
 
