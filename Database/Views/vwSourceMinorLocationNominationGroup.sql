IF OBJECT_ID(N'dbo.[vwSourceMinorLocationNominationGroup]', N'V') IS NOT NULL
	DROP VIEW dbo.[vwSourceMinorLocationNominationGroup]
GO 
-- ===============================================================================================================
-- Author: achyut@pioneersolutionsglobal.com
-- Create date: 2015-07-23
-- Description: Creates view for the Nomination Group Route
-- ===============================================================================================================

CREATE VIEW dbo.[vwSourceMinorLocationNominationGroup]
AS
	SELECT *
	FROM source_minor_location_nomination_group
	WHERE info_type = 'r'
GO