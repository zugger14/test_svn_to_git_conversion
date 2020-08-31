/*
 Written By: sbohara@pioneersolutionsglobal.com
 Written DT: 2016-06-26
 Purpose: Allow to delete WhatIf & AtRisk criteria and it's dependent data
 */
 --WhatIF
DELETE wcm 
FROM whatif_criteria_measure wcm
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = wcm.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE wcs 
FROM whatif_criteria_scenario wcs
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = wcs.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE vpdw 
FROM var_probability_density_whatif vpdw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = vpdw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE prw 
FROM pfe_results_whatif prw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = prw.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE prtww 
FROM pfe_results_term_wise_whatif prtww
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = prtww.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mvw 
FROM marginal_var_whatif mvw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mvw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE vrw 
FROM var_results_whatif vrw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = vrw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE crw 
FROM cfar_results_whatif crw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = crw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE erw
FROM ear_results_whatif erw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = erw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mvsw 
FROM mtm_var_simulation_whatif mvsw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mvsw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mcsw 
FROM mtm_cfar_simulation_whatif mcsw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mcsw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mesw
FROM mtm_ear_simulation_whatif mesw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mesw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mpsw
FROM mtm_pfe_simulation_whatif mpsw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mpsw.whatif_criteria_id
WHERE mwc.criteria_id IS NULL

DELETE mssr 
FROM multiple_scenario_shift_result mssr
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = mssr.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE sdpdow 
FROM source_deal_pnl_detail_options_WhatIf sdpdow
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = sdpdow.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE sdpdw
FROM source_deal_pnl_detail_whatif sdpdw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = sdpdw.criteria_id
WHERE mwc.criteria_id IS NULL

DELETE sdpw
FROM source_deal_pnl_whatif sdpw
LEFT JOIN maintain_whatif_criteria mwc ON mwc.criteria_id = sdpw.criteria_id
WHERE mwc.criteria_id IS NULL

IF EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK__whatif_cr__crite__6679D20F]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[whatif_criteria_measure]'))
BEGIN
	ALTER TABLE whatif_criteria_measure DROP CONSTRAINT FK__whatif_cr__crite__6679D20F
	ALTER TABLE whatif_criteria_measure ADD CONSTRAINT FK__whatif_cr__crite__6679D20F FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END 
ELSE
BEGIN
	ALTER TABLE whatif_criteria_measure ADD CONSTRAINT FK__whatif_cr__crite__6679D20F FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END	
	
IF EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK__whatif_cr__crite__74C7F166]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[whatif_criteria_scenario]'))
BEGIN
	ALTER TABLE whatif_criteria_scenario DROP CONSTRAINT FK__whatif_cr__crite__74C7F166
	ALTER TABLE whatif_criteria_scenario ADD CONSTRAINT FK__whatif_cr__crite__74C7F166 FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END 
ELSE
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD CONSTRAINT FK__whatif_cr__crite__74C7F166 FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END	

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_vpdw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[var_probability_density_whatif]'))
BEGIN
	ALTER TABLE var_probability_density_whatif ADD CONSTRAINT FK_vpdw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END         

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_prw_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[pfe_results_whatif]'))
BEGIN
	ALTER TABLE pfe_results_whatif ADD CONSTRAINT FK_prw_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_prtww_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[pfe_results_term_wise_whatif]'))
BEGIN
	ALTER TABLE pfe_results_term_wise_whatif ADD CONSTRAINT FK_prtww_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mvw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[marginal_var_whatif]'))
BEGIN
	ALTER TABLE marginal_var_whatif ADD CONSTRAINT FK_mvw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_vrw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[var_results_whatif]'))
BEGIN
	ALTER TABLE var_results_whatif ADD CONSTRAINT FK_vrw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_crw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[cfar_results_whatif]'))
BEGIN
	ALTER TABLE cfar_results_whatif ADD CONSTRAINT FK_crw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_erw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[ear_results_whatif]'))
BEGIN
	ALTER TABLE ear_results_whatif ADD CONSTRAINT FK_erw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[fk_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[multiple_scenario_shift_result]'))
BEGIN
	ALTER TABLE multiple_scenario_shift_result DROP CONSTRAINT fk_criteria_id
	ALTER TABLE multiple_scenario_shift_result ADD CONSTRAINT fk_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END 
ELSE
BEGIN
	ALTER TABLE multiple_scenario_shift_result ADD CONSTRAINT fk_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_sdpw_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_whatif]'))
BEGIN
	ALTER TABLE source_deal_pnl_whatif ADD CONSTRAINT FK_sdpw_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_sdpdw_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_detail_WhatIf]'))
BEGIN
	ALTER TABLE source_deal_pnl_detail_WhatIf ADD CONSTRAINT FK_sdpdw_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_sdpdow_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_detail_options_WhatIf]'))
BEGIN
	ALTER TABLE source_deal_pnl_detail_options_WhatIf ADD CONSTRAINT FK_sdpdow_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mvsw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[mtm_var_simulation_whatif]'))
BEGIN
	ALTER TABLE mtm_var_simulation_whatif ADD CONSTRAINT FK_mvsw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mcsw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[mtm_cfar_simulation_whatif]'))
BEGIN
	ALTER TABLE mtm_cfar_simulation_whatif ADD CONSTRAINT FK_mcsw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mesw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[mtm_ear_simulation_whatif]'))
BEGIN
	ALTER TABLE mtm_ear_simulation_whatif ADD CONSTRAINT FK_mesw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mpsw_whatif_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[mtm_pfe_simulation_whatif]'))
BEGIN
	ALTER TABLE mtm_pfe_simulation_whatif ADD CONSTRAINT FK_mpsw_whatif_criteria_id FOREIGN KEY (whatif_criteria_id) REFERENCES maintain_whatif_criteria(criteria_id) ON DELETE CASCADE
END


--At RIsk
DELETE vpd
FROM var_probability_density vpd
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = vpd.var_criteria_id
WHERE vmcd.id IS NULL

DELETE prtw
FROM pfe_results_term_wise prtw
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = prtw.criteria_id
WHERE vmcd.id IS NULL

DELETE mv
FROM marginal_var mv
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = mv.var_criteria_id
WHERE vmcd.id IS NULL

DELETE vr
FROM var_results vr
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = vr.var_criteria_id
WHERE vmcd.id IS NULL

DELETE pr
FROM pfe_results pr
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = pr.criteria_id
WHERE vmcd.id IS NULL

DELETE mvs
FROM mtm_var_simulation mvs
LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = mvs.var_criteria_id
WHERE vmcd.id IS NULL

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_vpd_var_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[var_probability_density]'))
BEGIN
	ALTER TABLE var_probability_density ADD CONSTRAINT FK_vpd_var_criteria_id FOREIGN KEY (var_criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_prtw_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[pfe_results_term_wise]'))
BEGIN
	ALTER TABLE pfe_results_term_wise ADD CONSTRAINT FK_prtw_criteria_id FOREIGN KEY (criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mv_var_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[marginal_var]'))
BEGIN
	ALTER TABLE marginal_var ADD CONSTRAINT FK_mv_var_criteria_id FOREIGN KEY (var_criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_vr_var_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[var_results]'))
BEGIN
	ALTER TABLE var_results ADD CONSTRAINT FK_vr_var_criteria_id FOREIGN KEY (var_criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_pr_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[pfe_results]'))
BEGIN
	ALTER TABLE pfe_results ADD CONSTRAINT FK_pr_criteria_id FOREIGN KEY (criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END

IF NOT EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK_mvs_var_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[mtm_var_simulation]'))
BEGIN
	ALTER TABLE mtm_var_simulation ADD CONSTRAINT FK_mvs_var_criteria_id FOREIGN KEY (var_criteria_id) REFERENCES var_measurement_criteria_detail(id) ON DELETE CASCADE
END