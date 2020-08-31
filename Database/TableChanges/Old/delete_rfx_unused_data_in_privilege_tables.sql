/*
* script to delete used data on privilege table of report manager
* sligal
* 8/30/2013
*/

DELETE FROM rp
FROM report_privilege rp
LEFT JOIN report r ON r.report_hash = rp.report_hash
WHERE r.report_id IS NULL

DELETE FROM rpp
FROM report_paramset_privilege rpp
LEFT JOIN report_paramset rp ON rp.paramset_hash = rpp.paramset_hash
WHERE rp.report_paramset_id IS NULL

