/****** Object:  View [dw].[uvwItemExpenditures]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwItemExpenditures]
AS
	SELECT SUM(CI.RemuneratedAmount)ItemExpenditure,MONTH(ISNULL(C.DateTo,C.DateFrom))MonthTime,DATENAME(QUARTER,ISNULL(C.DateTo,C.DateFrom))QuarterTime,YEAR(ISNULL(C.DateTo,C.DateFrom))YearTime,
	R.RegionName Region,HFD.DistrictName,PR.ProductCode,PR.ProductName,DATEDIFF(YEAR,I.DOB,ISNULL(C.DateTo, C.DateFrom))Age,I.Gender,
	Itm.ItemType,Itm.ItemCode,Itm.ItemName,CASE WHEN DATEDIFF(DAY, C.DateFrom, C.DateTo) > 0 THEN N'I' ELSE N'O' END ItemCareType,
	HF.HFLevel,HF.HFCode,HF.HFName,C.VisitType, ICD.ICDCode,ICD.ICDName,
	DIns.DistrictName IDistrictName , W.WardName, V.VillageName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion, HFR.RegionName ProdRegion

	FROM tblClaimItems CI INNER JOIN tblClaim C ON CI.ClaimID = C.ClaimID
	INNER JOIN tblProduct PR ON CI.ProdID = PR.ProdID
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblFamilies F ON I.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts DIns ON DIns.DistrictID = W.DistrictID
	INNER JOIN tblItems Itm ON CI.ItemID = Itm.ItemID
	INNER JOIN tblHF HF ON C.HFID = HF.HfID
	INNER JOIN tblICDCodes ICD ON C.ICDID = ICD.ICDID
	INNER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	INNER JOIN tblRegions R ON DIns.Region = R.RegionId
	INNER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region
	

	WHERE CI.ValidityTo IS NULL
	AND C.ValidityTo IS NULL
	AND PR.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND HFD.ValidityTo IS NULL
	AND C.ClaimStatus >= 8		--Consider only Processed(8) and Valuated(16) Claims
	--AND ISNULL(CI.PriceValuated,0) > 0
	--Also add a criteria if they want the batch id as well

	GROUP BY MONTH(ISNULL(C.DateTo,C.DateFrom)),DATENAME(QUARTER,ISNULL(C.DateTo,C.DateFrom)),YEAR(ISNULL(C.DateTo,C.DateFrom)),
	R.RegionName, PR.ProductCode,PR.ProductName,DATEDIFF(YEAR,I.DOB,ISNULL(C.DateTo, C.DateFrom)),I.Gender,
	Itm.ItemType,Itm.ItemCode,Itm.ItemName,DATEDIFF(DAY, C.DateFrom, C.DateTo),
	HF.HFLevel,HF.HFCode,HF.HFName,C.VisitType, ICD.ICDCode,ICD.ICDName,
	DIns.DistrictName, W.WardName, V.VillageName, HFD.DistrictName, HFR.RegionName


GO
