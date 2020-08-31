IF COL_LENGTH('fas_subsidiaries', 'node_level') IS NULL
BEGIN
    ALTER TABLE fas_subsidiaries ADD node_level INT
END
GO
