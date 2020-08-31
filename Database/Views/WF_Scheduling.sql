IF OBJECT_ID ('WF_Scheduling', 'V') IS NOT NULL
	DROP VIEW WF_Scheduling;
GO

-- ===============================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-07-01
-- Modified Date: 2019-01-18
-- Description: View to be used in workflow and alert 
-- ===============================================================================================================
CREATE VIEW WF_Scheduling
AS 

SELECT	mg.match_group_id [match_group_id],
		mg.create_ts [mg_create_ts],
		mg.create_user [mg_create_user],
		mg.update_ts [mg_update_ts],
		mg.update_user [mg_update_user],
		mgs.match_group_shipment_id [mgs_match_group_shipment_id],
		mgs.create_user [mgs_create_user],
		mgs.create_ts [mgs_create_ts],
		mgs.update_user [mgs_update_user],
		mgs.update_ts [mgs_update_ts],
		mgs.shipment_status [mgs_shipment_status],
		mgs.from_location [mgs_from_location],
		mgs.to_location [mgs_to_location],
		mgs.is_transport_deal_created [mgs_is_transportation_deal_created],
		mgh.match_group_header_id [mgh_match_group_header_id],
		mgh.match_book_auto_id [mgh_match_book_auto_id],
		mgh.match_bookout [mgh_match_bookout],
		mgh.source_minor_location_id [mgh_source_minor_location_id],
		mgh.scheduler [mgh_scheduler],
		mgh.location [mgh_location],
		mgh.status [mgh_status],
		mgh.scheduled_from [mgh_scheduled_from],
		mgh.scheduled_to [mgh_scheduled_to],
		mgh.match_number [mgh_match_number],
		mgh.pipeline_cycle [mgh_pipeline_cycle],
		mgh.consignee [mgh_consignee],
		mgh.carrier [mgh_carrier],
		mgh.po_number [mgh_po_number],
		mgh.container [mgh_container],
		mgh.line_up [mgh_line_up],
		mgh.commodity_origin_id [mgh_commodity_origin_id],
		mgh.commodity_form_id [mgh_commodity_form_id],
		mgh.organic [mgh_organic],
		mgh.commodity_form_attribute1 [mgh_commodity_form_attribute1],
		mgh.commodity_form_attribute2 [mgh_commodity_form_attribute2],
		mgh.commodity_form_attribute3 [mgh_commodity_form_attribute3],
		mgh.commodity_form_attribute4 [mgh_commodity_form_attribute4],
		mgh.commodity_form_attribute5 [mgh_commodity_form_attribute5],
		mgh.estimated_movement_date [mgh_estimated_movement_date],
		mgh.create_user [mgh_create_user],
		mgh.create_ts [mgh_create_ts],
		mgh.update_user [mgh_update_user],
		mgh.update_ts [mgh_update_ts],
		mgd.match_group_detail_id [mgd_match_group_detail_id],
		mgd.quantity [mgd_quantity],
		mgd.source_commodity_id [mgd_source_commodity_id],
		mgd.scheduling_period [mgd_scheduling_period],
		mgd.notes [mgd_notes],
		mgd.source_deal_detail_id [mgd_source_deal_detail_id],
		mgd.is_complete [mgd_is_complete],
		mgd.create_user [mgd_create_user],
		mgd.create_ts [mgd_create_ts],
		mgd.update_user [mgd_update_user],
		mgd.update_ts [mgd_update_ts],
		mgd.bookout_split_volume [mgd_bookout_split_volume],
		mgd.split_deal_detail_volume_id [mgd_split_deal_detail_volume_id],
		mgd.frequency [mgd_frequency],
		mgd.lot [mgd_lot],
		mgd.batch_id [mgd_batch_id],
		mgd.inco_terms [mgd_inco_terms],
		mgd.crop_year [mgd_crop_year],
		mgs.shipment_workflow_status [mgs_workflow_status],
		mgd1.match_group_detail_id [mgd_s_match_group_detail_id],
		mgd1.quantity [mgd_s_quantity],
		mgd1.source_commodity_id [mgd_s_source_commodity_id],
		mgd1.scheduling_period [mgd_s_scheduling_period],
		mgd1.notes [mgd_s_notes],
		mgd1.source_deal_detail_id [mgd_s_source_deal_detail_id],
		mgd1.is_complete [mgd_s_is_complete],
		mgd1.create_user [mgd_s_create_user],
		mgd1.create_ts [mgd_s_create_ts],
		mgd1.update_user [mgd_s_update_user],
		mgd1.update_ts [mgd_s_update_ts],
		mgd1.bookout_split_volume [mgd_s_bookout_split_volume],
		mgd1.split_deal_detail_volume_id [mgd_s_split_deal_detail_volume_id],
		mgd1.frequency [mgd_s_frequency],
		mgd1.lot [mgd_s_lot],
		mgd1.batch_id [mgd_s_batch_id],
		mgd1.inco_terms [mgd_s_inco_terms],
		mgd1.crop_year [mgd_s_crop_year]
FROM match_group mg
INNER JOIN match_group_shipment mgs ON mg.match_group_id = mgs.match_group_id
INNER JOIN match_group_header mgh ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
LEFT JOIN match_group_detail mgd ON mgd.match_group_header_id = mgh.match_group_header_id AND (
	SELECT sdd.buy_sell_flag FROM source_deal_detail sdd WHERE sdd.source_deal_detail_id = mgd.source_deal_detail_id 
) = 'b'
LEFT JOIN match_group_detail mgd1 ON mgd1.match_group_header_id = mgh.match_group_header_id AND (
	SELECT sdd1.buy_sell_flag FROM source_deal_detail sdd1 WHERE sdd1.source_deal_detail_id = mgd1.source_deal_detail_id 
) = 's' 