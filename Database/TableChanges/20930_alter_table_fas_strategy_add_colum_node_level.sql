IF COL_LENGTH('fas_strategy', 'node_level') IS NULL
BEGIN
    ALTER TABLE fas_strategy ADD node_level INT
END
GO
