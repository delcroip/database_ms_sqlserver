/****** Object:  View [dw].[uvwamountvaluated]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwamountvaluated]
AS
	SELECT SUM(Details.Valuated)AmountValuated,MONTH(ISNULL(C.DateTo, C.DateFrom))MonthTime, DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom))QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom))YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblClaim C 
	LEFT OUTER JOIN

	(SELECT ClaimId,ProdId, SUM(RemuneratedAmount) Valuated FROM tblClaimItems WHERE ValidityTo IS NULL GROUP BY ClaimId,ProdId
	UNION ALL
	SELECT ClaimId,ProdID,SUM(RemuneratedAmount) Valuated FROM tblClaimServices WHERE ValidityTo IS NULL GROUP BY ClaimId,ProdId
	)Details ON C.ClaimID = Details.ClaimID


	LEFT OUTER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
	LEFT OUTER JOIN tblHF HF ON C.HFID = HF.HFID
	LEFT OUTER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	LEFT OUTER JOIN tblRegions HFR ON HFD.Region = HFR.RegionId

	WHERE C.ValidityTo IS NULL
	--AND Prod.ValidityTo IS NULL
	--AND D.ValidityTo IS NULL
	--AND HF.ValidityTo IS NULL
	--AND HFD.ValidityTo IS NULL
	AND C.ClaimStatus = 16 --Which is Processed and greater

	GROUP BY MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom))
	,HF.HFLevel,HF.HFCode, HF.HFName
	,Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName


GO
