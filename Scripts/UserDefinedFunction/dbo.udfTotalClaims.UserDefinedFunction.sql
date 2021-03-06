/****** Object:  UserDefinedFunction [dbo].[udfTotalClaims]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfTotalClaims]
(
	@ProdID INT = 0,
	@HFID INT = 0,
	@LocationId INT = 0,
	@Month INT,
	@Year INT
)
RETURNS TABLE
AS
RETURN
  
	SELECT ClaimStat.ProdID, ClaimStat.HFID,COUNT(ClaimStat.ClaimID)TotalClaims
	FROM
	(
		 	SELECT CI.ProdId, HF.HFID, C.ClaimID
	FROM tblClaim C 
	INNER JOIN tblClaimItems CI ON CI.ClaimId = C.ClaimID
	INNER JOIN tblHF HF ON HF.HFID = C.HFID
	INNER JOIN uvwLocations L ON L.DistrictId = HF.LocationId
	WHERE C.ValidityTo IS NULL
	AND CI.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND MONTH(C.DateFrom) = @Month
	AND YEAR(C.DateFrom) = @Year
	AND (CI.ProdId = @ProdId OR @ProdId = 0)
	AND (HF.HFID = @HFId OR @HFId = 0)
	AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
	GROUP BY ProdId, HF.HFID, C.ClaimID, C.ClaimCode
	UNION 
	SELECT CS.ProdId, HF.HFID ,C.ClaimID
	FROM tblClaim C 
	INNER JOIN tblClaimServices CS ON CS.ClaimId = C.ClaimID
	INNER JOIN tblHF HF ON HF.HFID = C.HFID
	INNER JOIN uvwLocations L ON L.DistrictId = HF.LocationId
	WHERE C.ValidityTo IS NULL
	AND CS.ValidityTo IS NULL
	AND HF.ValidityTo IS NULL
	AND MONTH(C.DateFrom) = @Month
	AND YEAR(C.DateFrom) = @Year
	AND (CS.ProdId = @ProdId OR @ProdId = 0)
	AND (HF.HFID = @HFId OR @HFId = 0)
	AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
	GROUP BY ProdId, HF.HFID, C.ClaimID
	)ClaimStat
	GROUP BY ClaimStat.ProdID, ClaimStat.HFID
GO
