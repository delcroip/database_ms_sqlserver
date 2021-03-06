/****** Object:  View [dw].[uvwClaimEntered]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwClaimEntered] 
AS
	SELECT COUNT(1)TotalClaimEntered,MONTH(ISNULL(C.DateTo, C.DateFrom))MonthTime, DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom))QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom))YearTime,
	HF.HFLevel,HF.HFCode, HF.HFName,HFD.DistrictName HFDistrict, HFR.RegionName HFRegion
	FROM tblClaim C  LEFT OUTER JOIN tblHF HF ON C.HFID = HF.HFID
	LEFT OUTER JOIN tblDistricts HFD ON HF.LocationId = HFD.DistrictID
	INNER JOIN tblRegions HFR ON HFD.Region = HFR.RegionId
	WHERE C.ValidityTo IS NULL 
	GROUP BY MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER,ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom)),
	HF.HFLevel,HF.HFCode, HF.HFName,HFD.DistrictName, HFR.RegionName

GO
