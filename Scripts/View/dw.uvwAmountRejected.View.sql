/****** Object:  View [dw].[uvwAmountRejected]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwAmountRejected]
AS
	SELECT SUM(Details.Rejected)AmountRejected,MONTH(ISNULL(C.DateTo, C.DateFrom))MonthTime, DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom))QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom))YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblClaim C 
	LEFT OUTER JOIN

	(SELECT ClaimId,ProdId, SUM(QtyProvided * PriceAsked)Rejected FROM tblClaimItems WHERE ValidityTo IS NULL GROUP BY ClaimId,ProdId
	UNION ALL
	SELECT ClaimId,ProdID,SUM(QtyProvided * PriceAsked)Rejected FROM tblClaimServices WHERE ValidityTo IS NULL GROUP BY ClaimId,ProdId
	)Details ON C.ClaimID = Details.ClaimID

	LEFT OUTER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
	LEFT OUTER JOIN tblHF HF ON C.HFID = HF.HFID
	LEFT OUTER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	LEFT OUTER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region

	WHERE C.ValidityTo IS NULL
	AND Prod.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND HFD.ValidityTo IS NULL

	AND C.ClaimStatus = 1 --Which is rejected

	--AND ISNULL(Details.Rejected,0) <> 0

	GROUP BY MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom))
	,HF.HFLevel,HF.HFCode, HF.HFName
	, Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName

GO
