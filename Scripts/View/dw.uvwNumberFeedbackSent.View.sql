/****** Object:  View [dw].[uvwNumberFeedbackSent]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwNumberFeedbackSent]
AS
	SELECT COUNT(FeedbackPromptId)FeedbackSent, MONTH(F.FeedbackPromptDate)MonthTime, DATENAME(QUARTER,F.FeedbackPromptDate)QuarterTime, YEAR(F.FeedbackPromptDate)YearTime
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName
	,HF.HFLevel,HF.HFCode, HF.HFName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblFeedbackPrompt F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
	INNER JOIN
			(SELECT ClaimId,ProdId FROM tblClaimItems WHERE ValidityTo IS NULL
			UNION 
			SELECT ClaimId,ProdID FROM tblClaimServices WHERE ValidityTo IS NULL
			)Details ON F.ClaimID = Details.ClaimID
	INNER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
	INNER JOIN tblHF HF ON C.HFID = HF.HFID
	INNER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	INNER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region

	WHERE F.ValidityTo IS NULL
	AND Prod.ValidityTo IS NULL
	AND HFD.ValidityTo IS NULL

	GROUP BY YEAR(F.FeedbackPromptDate),MONTH(F.FeedbackPromptDate), DATENAME(QUARTER,F.FeedbackPromptDate) 
	, Prod.ProductCode, Prod.ProductName
	,HF.HFLevel,HF.HFCode, HF.HFName, HFD.DistrictName, HFR.RegionName
	

GO
