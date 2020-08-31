IF COL_LENGTH('fas_eff_hedge_rel_type_detail', 'sub_id') IS NULL
BEGIN
    ALTER TABLE fas_eff_hedge_rel_type_detail ADD sub_id INT
END
GO
