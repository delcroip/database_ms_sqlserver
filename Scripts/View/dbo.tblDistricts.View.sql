/****** Object:  View [dbo].[tblDistricts]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[tblDistricts] AS
SELECT LocationId DistrictId, LocationCode DistrictCode, LocationName DistrictName, ParentLocationId Region, ValidityFrom, ValidityTo, LegacyId, AuditUserId, RowId
FROM tblLocations
WHERE ValidityTo IS NULL
AND LocationType = N'D'
GO
