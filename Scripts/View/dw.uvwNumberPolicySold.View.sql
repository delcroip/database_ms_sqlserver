/****** Object:  View [dw].[uvwNumberPolicySold]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwNumberPolicySold]
AS
	
	SELECT COUNT(PL.FamilyID)SoldPolicy, MONTH(PL.EnrollDate)MonthTime, DATENAME(Q, PL.EnrollDate)QuarterTime, YEAR(PL.EnrollDate)YearTime,
	DATEDIFF(YEAR, I.DOB, PL.EnrollDate)Age, I.Gender, RD.RegionName Region, FD.DistrictName InsDistrict, FV.VillageName InsVillage, FW.WardName InsWard,
	FD.DistrictName ProdDistrict, Prod.ProductCode, Prod.ProductName, OD.DistrictName OfficerDistrict, O.Code, O.LastName, O.OtherNames, RD.RegionName ProdRegion


	FROM tblPolicy PL INNER JOIN tblFamilies F ON PL.FamilyId = F.FamilyID
	INNER JOIN tblInsuree I ON F.InsureeID = I.InsureeID
	INNER JOIN tblVillages FV ON FV.VillageId = F.LocationId
	INNER JOIN tblWards FW ON FW.WardId = FV.WardID
	INNER JOIN tblDistricts FD ON FD.DistrictID = FW.DistrictID
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
	INNER JOIN tblOfficer O ON PL.OfficerId = O.OfficerID
	INNER JOIN tblDistricts OD ON OD.DistrictID = O.LocationId
	INNER JOIN tblRegions RD ON RD.RegionId = FD.Region
	
	WHERE PL.ValidityTo IS NULL
	AND F.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND FD.ValidityTo IS NULL
	AND FW.ValidityTo IS NULL
	AND FV.ValidityTo IS NULL
	AND Prod.ValidityTo IS NULL
	AND O.ValidityTo IS NULL
	AND OD.ValidityTo IS NULL
	AND PL.PolicyStage = N'N'

	GROUP BY MONTH(PL.EnrollDate), DATENAME(Q, PL.EnrollDate), YEAR(PL.EnrollDate),
	DATEDIFF(YEAR, I.DOB, PL.EnrollDate), I.Gender, RD.RegionName, FD.DistrictName, FV.VillageName, FW.WardName,
	Prod.ProductCode, Prod.ProductName, OD.DistrictName, O.Code, O.LastName, O.OtherNames


GO
