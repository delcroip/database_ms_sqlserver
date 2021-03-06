/****** Object:  View [dw].[uvwVisit]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwVisit]
AS
	SELECT COUNT(C.ClaimId) Visits, MONTH(C.DateFrom)MonthTime, DATENAME(QUARTER,C.DateFrom)QuarterTime, YEAR(C.DateFrom)YearTime
	,HFR.RegionName Region, HFD.DistrictName, Prod.ProductCode, Prod.ProductName,
	DATEDIFF(YEAR,I.DOB,C.DateFrom)Age,I.Gender,
	HF.HFLevel,HF.HFCode, HF.HFName,
	C.VisitType, ICD.ICDCode, ICD.ICDName, HFD.DistrictName HFDistrict, HFR.RegionName HFRegion
	FROM tblClaim C 
	LEFT OUTER JOIN
	(SELECT ClaimId,ProdId FROM tblClaimItems WHERE ValidityTo IS NULL AND RejectionReason = 0
	UNION 
	SELECT ClaimId,ProdID FROM tblClaimServices WHERE ValidityTo IS NULL AND RejectionReason = 0
	)Details ON C.ClaimID = Details.ClaimID
	LEFT OUTER JOIN tblProduct Prod ON Details.ProdID = Prod.ProdID
	LEFT OUTER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	LEFT OUTER JOIN tblHF HF ON C.HFID = HF.HFID
	LEFT OUTER JOIN tblICDCodes ICD ON C.ICDID = ICD.ICDID
	LEFT OUTER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	LEFT OUTER JOIN tblRegions HFR ON HFR.RegionId = HFD.Region
	
	WHERE C.ValidityTo IS NULL
	AND Prod.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND HFD.ValidityTo IS NULL

	AND DATEDIFF(DAY,C.DateFrom,C.DateTo) = 0


	GROUP BY MONTH(C.DateFrom), DATENAME(QUARTER,C.DateFrom), YEAR(C.DateFrom)
	,Prod.ProductCode, Prod.ProductName,
	DATEDIFF(YEAR,I.DOB,C.DateFrom),I.Gender,
	HF.HFLevel,HF.HFCode, HF.HFName,C.VisitType, ICD.ICDCode, ICD.ICDName, HFD.DistrictName, HFR.RegionName


GO
