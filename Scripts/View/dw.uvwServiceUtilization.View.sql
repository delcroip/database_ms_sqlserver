/****** Object:  View [dw].[uvwServiceUtilization]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwServiceUtilization]
AS
	SELECT  SUM(CS.QtyProvided) AS ServiceUtilized, MONTH(ISNULL(C.DateTo, C.DateFrom)) AS MonthTime, DATENAME(QUARTER, ISNULL(C.DateTo, C.DateFrom)) 
	AS QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom)) AS YearTime, R.RegionName AS Region, DIns.DistrictName ,  Prod.ProductCode, Prod.ProductName, 
	DATEDIFF(YEAR, I.DOB, ISNULL(C.DateTo, C.DateFrom)) AS Age, I.Gender, S.ServType, S.ServCode, S.ServName, CASE WHEN DATEDIFF(DAY, C.DateFrom, 
	C.DateTo) > 0 THEN N'I' ELSE N'O' END AS ServCareType, HF.HFLevel, HF.HFCode, HF.HFName, C.VisitType, ICD.ICDCode, ICD.ICDName, 
	DIns.DistrictName AS IDistrictName, W.WardName, V.VillageName, HFD.DistrictName AS HFDistrict,HFR.RegionName AS HFRegion, 
	R.RegionName AS ProdRegion
	
	FROM dbo.tblClaimServices AS CS 
	INNER JOIN dbo.tblClaim AS C ON CS.ClaimID = C.ClaimID 
	LEFT OUTER JOIN dbo.tblProduct AS Prod ON CS.ProdID = Prod.ProdID 
	INNER JOIN dbo.tblInsuree AS I ON C.InsureeID = I.InsureeID 
	INNER JOIN dbo.tblFamilies AS F ON I.FamilyID = F.FamilyID 
	INNER JOIN dbo.tblVillages AS V ON V.VillageID = F.LocationId 
	INNER JOIN dbo.tblWards AS W ON W.WardID = V.WardID
	INNER JOIN  dbo.tblDistricts AS DIns ON DIns.DistrictID = W.DistrictID 
	INNER JOIN dbo.tblServices AS S ON CS.ServiceID = S.ServiceID 
	INNER JOIN dbo.tblHF AS HF ON C.HFID = HF.HfID 
	INNER JOIN dbo.tblICDCodes AS ICD ON C.ICDID = ICD.ICDID 
	INNER JOIN dbo.tblDistricts AS HFD ON HF.LocationId = HFD.DistrictID -- BY Rogers
	INNER JOIN dbo.tblRegions AS R ON R.RegionId = DIns.Region 
	INNER JOIN dbo.tblRegions AS HFR ON HFR.RegionId = HFD.Region

	WHERE (CS.ValidityTo IS NULL) 
	  AND (C.ValidityTo IS NULL) 
	  AND (Prod.ValidityTo IS NULL) 
	  AND (I.ValidityTo IS NULL) 
	  AND (DIns.ValidityTo IS NULL) 
	  AND (HF.ValidityTo IS NULL) 
	  AND (HFD.ValidityTo IS NULL) 
	  AND (F.ValidityTo IS NULL) 
	  AND (S.ValidityTo IS NULL) 
	  AND (C.ClaimStatus > 2)
	  AND CS.RejectionReason=0
	GROUP BY MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER, ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom)), R.RegionName, 
	Prod.ProductCode, Prod.ProductName, DATEDIFF(YEAR, I.DOB, ISNULL(C.DateTo, C.DateFrom)), I.Gender, S.ServType, S.ServCode, S.ServName, DATEDIFF(DAY, 
	C.DateFrom, C.DateTo), HF.HFLevel, HF.HFCode, HF.HFName, C.VisitType, ICD.ICDCode, ICD.ICDName, DIns.DistrictName, W.WardName, V.VillageName, HFD.DistrictName  ,HFR.RegionName

GO
