/****** Object:  View [dw].[uvwExpenditureInsureeRange]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwExpenditureInsureeRange]
AS

	WITH Val
	AS
	(
	SELECT ClaimId, SUM(PriceValuated) Valuated, ProdID FROM tblClaimItems WHERE validityto IS NULL AND PriceValuated IS NOT NULL GROUP BY ClaimID, ProdID
	UNION ALL
	SELECT ClaimId, SUM(PriceValuated) Valuated, ProdID FROM tblClaimServices WHERE validityto IS NULL AND PriceValuated IS NOT NULL GROUP BY ClaimID, ProdID
	) 
	SELECT SUM(Val.Valuated)Valuated,C.ClaimID Insuree, MONTH(ISNULL(C.DateTo, C.DateFrom))MonthTime, DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom))QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom))YearTime
	,R.RegionName Region, D.DistrictName, Prod.ProductCode, Prod.ProductName
	,DATEDIFF(YEAR,I.DOB,ISNULL(C.DateTo, C.DateFrom))Age,I.Gender

	FROM Val INNER JOIN tblClaim C ON Val.ClaimID = C.ClaimID
	INNER JOIN tblProduct Prod ON Val.ProdID = Prod.ProdID
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblFamilies F ON F.InsureeID = I.InsureeID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblRegions R ON R.RegionId = D.Region

	WHERE C.ValidityTo IS NULL
	 AND Prod.ValidityTo IS NULL
	 AND I.ValidityTo IS NULL
	 AND F.ValidityTo IS NULL
	 AND D.ValidityTo IS NULL

	 GROUP BY C.Claimid, MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom))
	,R.RegionName, D.DistrictName, Prod.ProductCode, Prod.ProductName
	,DATEDIFF(YEAR,I.DOB,ISNULL(C.DateTo, C.DateFrom)),I.Gender

GO
