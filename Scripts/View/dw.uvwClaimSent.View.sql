/****** Object:  View [dw].[uvwClaimSent]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwClaimSent]
AS
	SELECT COUNT(C.ClaimID)ClaimSent,MONTH(C.DateClaimed)MonthTime, DATENAME(QUARTER,C.DateClaimed)QuarterTime, YEAR(C.DateClaimed)YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblClaim C 
		INNER JOIN
		(SELECT ClaimId,ProdId FROM tblClaimItems WHERE ValidityTo IS NULL
		UNION 
		SELECT ClaimId,ProdID FROM tblClaimServices WHERE ValidityTo IS NULL
		)Details ON C.ClaimID = Details.ClaimID
		INNER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
		INNER JOIN tblHF HF ON C.HFID = HF.HFID
		INNER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
		INNER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region

		WHERE C.ValidityTo IS NULL
		AND Prod.ValidityTo IS NULL
		AND HF.ValidityTo IS NULL
		AND HFD.ValidityTo IS NULL
		AND C.ClaimStatus > 2 --Which is entered

	GROUP BY MONTH(C.DateClaimed), DATENAME(QUARTER,C.DateClaimed), YEAR(C.DateClaimed)
	,HF.HFLevel,HF.HFCode, HF.HFName
	,Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName


GO
