/****** Object:  View [dw].[uvwNumberInsureeAcquired]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwNumberInsureeAcquired]
AS
	SELECT COUNT(I.InsureeID)NewInsurees,MONTH(PL.EnrollDate)MonthTime,DATENAME(Q,PL.Enrolldate)QuarterTime, YEAR(PL.EnrollDate)YearTime,
	DATEDIFF(YEAR,I.DOB,GETDATE())Age, I.Gender, R.RegionName Region, D.DistrictName InsDistrict, V.VillageName InsVillage, W.WardName InsWard,
	D.DistrictName ProdDistrict, Prod.ProductCode, Prod.ProductName,
	ODist.DistrictName OfficerDistrict, O.Code, O.LastName, O.OtherNames, R.RegionName ProdRegion


	FROM tblPolicy PL INNER JOIN tblInsuree I ON PL.FamilyID = I.FamilyID
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
	INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardID = V.WardID
	INNER JOIN tblDistricts D ON D.DistrictID = W.DistrictID
	INNER JOIN tblOfficer O ON PL.OfficerID = O.OfficerId
	INNER JOIN tblDistricts ODist ON O.LocationId = ODist.DistrictId
	INNER JOIN tblInsureePolicy InsPL ON InsPL.InsureeId = I.InsureeId AND InsPL.PolicyId = PL.PolicyID
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	
	WHERE PL.ValidityTo IS NULL 
	AND I.ValidityTo IS NULL 
	AND Prod.ValidityTo IS NULL 
	AND F.ValidityTo IS NULL
	AND D.ValidityTo IS NULL
	AND V.ValidityTo IS NULL
	AND W.ValidityTo IS NULL
	AND O.ValidityTo IS NULL
	AND ODist.ValidityTo IS NULL
	AND InsPL.ValidityTo IS NULL

	GROUP BY MONTH(PL.EnrollDate),DATENAME(Q,PL.Enrolldate), YEAR(PL.EnrollDate),
	DATEDIFF(YEAR,I.DOB,GETDATE()), I.Gender, D.DistrictName, V.VillageName, W.WardName,
	R.Regionname, Prod.ProductCode, Prod.ProductName,
	ODist.DistrictName, O.Code, O.LastName, O.OtherNames


GO
