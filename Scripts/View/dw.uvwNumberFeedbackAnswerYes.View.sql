/****** Object:  View [dw].[uvwNumberFeedbackAnswerYes]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwNumberFeedbackAnswerYes]
AS
	SELECT COUNT(F.FeedbackID)AnsYes, 1 QuestionId,MONTH(F.FeedbackDate)MonthTime, DATENAME(QUARTER,F.FeedbackDate)QuarterTime, YEAR(F.FeedbackDate)YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
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
	AND CareRendered = 1

	GROUP BY MONTH(F.FeedbackDate), DATENAME(QUARTER,F.FeedbackDate), YEAR(F.FeedbackDate),
	HF.HFLevel,HF.HFCode, HF.HFName
	, Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName

	UNION ALL

	SELECT COUNT(F.FeedbackID)AnsYes, 2 QuestionId,MONTH(F.FeedbackDate)MonthTime, DATENAME(QUARTER,F.FeedbackDate)QuarterTime, YEAR(F.FeedbackDate)YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
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
	AND F.PaymentAsked = 1

	GROUP BY MONTH(F.FeedbackDate), DATENAME(QUARTER,F.FeedbackDate), YEAR(F.FeedbackDate),
	HF.HFLevel,HF.HFCode, HF.HFName
	, Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName

	UNION ALL

	SELECT COUNT(F.FeedbackID)AnsYes, 3 QuestionId,MONTH(F.FeedbackDate)MonthTime, DATENAME(QUARTER,F.FeedbackDate)QuarterTime, YEAR(F.FeedbackDate)YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
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
	AND F.DrugPrescribed = 1

	GROUP BY MONTH(F.FeedbackDate), DATENAME(QUARTER,F.FeedbackDate), YEAR(F.FeedbackDate),
	HF.HFLevel,HF.HFCode, HF.HFName
	, Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName

	UNION ALL

	SELECT COUNT(F.FeedbackID)AnsYes, 4 QuestionId,MONTH(F.FeedbackDate)MonthTime, DATENAME(QUARTER,F.FeedbackDate)QuarterTime, YEAR(F.FeedbackDate)YearTime
	,HF.HFLevel,HF.HFCode, HF.HFName
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion

	FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
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
	AND F.DrugReceived = 1

	GROUP BY MONTH(F.FeedbackDate), DATENAME(QUARTER,F.FeedbackDate), YEAR(F.FeedbackDate),
	HF.HFLevel,HF.HFCode, HF.HFName
	, Prod.ProductCode, Prod.ProductName, HFD.DistrictName, HFR.RegionName


GO
