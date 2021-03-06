/****** Object:  View [dw].[uvwHospitalDays]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwHospitalDays]
AS
	SELECT        SUM(DATEDIFF(DAY, C.DateFrom, C.DateTo)) AS HospitalDays, MONTH(ISNULL(C.DateTo, C.DateFrom)) AS MonthTime, DATENAME(QUARTER, ISNULL(C.DateTo, 
							 C.DateFrom)) AS QuarterTime, YEAR(ISNULL(C.DateTo, C.DateFrom)) AS YearTime, HFR.RegionName AS Region, HFD.DistrictName, Prod.ProductCode, 
							 Prod.ProductName, DATEDIFF(YEAR, I.DOB, ISNULL(C.DateTo, C.DateFrom)) AS Age, I.Gender, HF.HFLevel, HF.HFCode, HF.HFName, C.VisitType, ICD.ICDCode, 
							 ICD.ICDName, HFD.DistrictName AS HFDistrict, HFR.RegionName AS HFRegion
	FROM            dbo.tblClaim AS C LEFT OUTER JOIN
								 (SELECT        ClaimID, ProdID
								   FROM            dbo.tblClaimItems
								   WHERE        (ValidityTo IS NULL AND RejectionReason=0)
								   UNION
								   SELECT        ClaimID, ProdID
								   FROM            dbo.tblClaimServices
								   WHERE        (ValidityTo IS NULL AND RejectionReason=0)) AS Details ON C.ClaimID = Details.ClaimID LEFT OUTER JOIN
							 dbo.tblProduct AS Prod ON Details.ProdID = Prod.ProdID LEFT OUTER JOIN
							 dbo.tblInsuree AS I ON C.InsureeID = I.InsureeID LEFT OUTER JOIN
							 dbo.tblHF AS HF ON C.HFID = HF.HfID LEFT OUTER JOIN
							 dbo.tblICDCodes AS ICD ON C.ICDID = ICD.ICDID LEFT OUTER JOIN
							 dbo.tblDistricts AS HFD ON HF.LocationId = HFD.DistrictID LEFT OUTER JOIN
							 dbo.tblRegions AS HFR ON HFR.RegionId = HFD.Region
	WHERE        (C.ValidityTo IS NULL) AND (Prod.ValidityTo IS NULL) AND (I.ValidityTo IS NULL) AND (HF.ValidityTo IS NULL) AND (HFD.ValidityTo IS NULL) AND (DATEDIFF(DAY, 
							 C.DateFrom, C.DateTo) > 0) AND C.ClaimStatus <>1
	GROUP BY MONTH(ISNULL(C.DateTo, C.DateFrom)), DATENAME(QUARTER, ISNULL(C.DateTo, C.DateFrom)), YEAR(ISNULL(C.DateTo, C.DateFrom)), Prod.ProductCode, 
							 Prod.ProductName, DATEDIFF(YEAR, I.DOB, ISNULL(C.DateTo, C.DateFrom)), I.Gender, HF.HFLevel, HF.HFCode, HF.HFName, C.VisitType, ICD.ICDCode, 
							 ICD.ICDName, HFD.DistrictName, HFR.RegionName

GO
