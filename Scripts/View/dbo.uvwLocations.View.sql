/****** Object:  View [dbo].[uvwLocations]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[uvwLocations]
AS
	SELECT 0 LocationId, NULL RegionId, NULL RegionCode, N'National' RegionName, NULL DistrictId, NULL DistrictCode, NULL DistrictName, NULL WardId, NULL WardCode, NULL WardName, NULL VillageId, NULL VillageCode, NULL VillageName, NULL ParentLocationId
	UNION ALL
	SELECT RegionId LocationId,RegionId, RegionCode, RegionName, NULL DistrictId, NULL DistrictCode, NULL DistrictName, NULL WardId, NULL WardCode, NULL WardName, NULL VillageId, NULL VillageCode, NULL VillageName, 0 ParentLocationId 
	FROM tblRegions
	UNION ALL
	SELECT D.DistrictId LocationId, R.RegionId, R.RegionCode, R.RegionName, D.DistrictId, D.DistrictCode, D.DistrictName, NULL WardId, NULL WardCode, NULL WardName, NULL VillageId, NULL VillageCode, NULL VillageName, Region ParentLocationId
	FROM tblDistricts D
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	UNION ALL
	SELECT W.WardId LocationId, R.RegionId, R.RegionCode, R.RegionName, D.DistrictId, D.DistrictCode, D.DistrictName, W.WardId, W.WardCode, W.WardName, NULL VillageId, NULL VillageCode, NULL VillageName, D.DistrictId ParentLocationId
	FROM tblRegions R
	INNER JOIN tblDistricts D ON R.RegionId = D.Region
	INNER JOIN tblWards W ON W.DistrictId = D.DistrictId
	UNION ALL
	SELECT V.VillageId LocationId, R.RegionId, R.RegionCode, R.RegionName, D.DistrictId, D.DistrictCode, D.DistrictName, W.WardId, W.WardCode, W.WardName, V.VillageId, V.VillageCode, V.VillageName, V.WardId ParentLocationId
	FROM tblRegions R
	INNER JOIN tblDistricts D ON R.RegionId = D.Region
	INNER JOIN tblWards W ON W.DistrictId = D.DistrictId
	INNER JOIN tblVillages V ON V.WardId = W.WardId

GO
