/****** Object:  View [dbo].[tblRegions]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[tblRegions] 
AS
SELECT LocationId RegionId, LocationCode RegionCode, LocationName RegionName, ValidityFrom, ValidityTo, LegacyId, AuditUserId, RowId
FROM tblLocations
WHERE ValidityTo IS NULL
AND LocationType = N'R'
GO
