/****** Object:  View [dw].[uvwOverallAssessment]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwOverallAssessment]
AS
	SELECT Asessment,MONTH(FeedbackDate)MonthTime, DATENAME(QUARTER,FeedbackDate)QuarterTime, YEAR(FeedbackDate)YearTime,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName,HF.HFLevel,HF.HFCode, HF.HFName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion
	FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimId = C.ClaimId
	INNER JOIN
			(SELECT ClaimId,ProdId FROM tblClaimItems WHERE ValidityTo IS NULL
			UNION 
			SELECT ClaimId,ProdID FROM tblClaimServices WHERE ValidityTo IS NULL
			)Details ON C.ClaimID = Details.ClaimID
	INNER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
	INNER JOIN tblHF HF ON C.HFID = HF.HFID
	INNER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	INNER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region

	WHERE F.ValidityTo IS NULL
	AND C.ValidityTo IS NULL
	AND Prod.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND HFD.ValidityTo IS NULL

GO
