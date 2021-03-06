/****** Object:  UserDefinedFunction [dbo].[udfRejectedClaims]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfRejectedClaims]
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
	SELECT Claims.HFID,Claims.ProdID,COUNT(ClaimID)RejectedClaims FROM
	(
		SELECT C.ClaimID,HF.HfID,CI.ProdID
		FROM tblClaim C 
		INNER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
		INNER JOIN tblHF HF ON C.HFID = HF.HfID
		INNER JOIN uvwLocations L ON HF.LocationId = L.LocationId 
		WHERE C.ValidityTo IS NULL 
		AND CI.ValidityTo IS NULL 
		AND HF.ValidityTo IS NULL
		AND C.ClaimStatus = 1 
		AND (CI.ProdID = @ProdId OR @ProdId = 0)
		AND (HF.HfID = @HFID OR @HFID = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
		AND MONTH(C.DateFrom) = @Month 
		AND YEAR(C.DateFrom) = @Year
		GROUP BY C.ClaimID,HF.HfID,CI.ProdID
		UNION 
		SELECT C.ClaimID,HF.HfID,CS.ProdID
		FROM tblClaim C 
		INNER JOIN tblClaimServices CS ON C.ClaimID = CS.ClaimID
		INNER JOIN tblHF HF ON C.HFID = HF.HfID
		INNER JOIN uvwLocations L ON HF.LocationId = L.LocationId 
		WHERE C.ValidityTo IS NULL 
		AND CS.ValidityTo IS NULL 
		AND HF.ValidityTo IS NULL
		AND C.ClaimStatus = 1 
		AND (CS.ProdID = @ProdId OR @ProdId = 0)
		AND (HF.HfID = @HFID OR @HFID = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
		AND MONTH(C.DateFrom) = @Month 
		AND YEAR(C.DateFrom) = @Year
		GROUP BY C.ClaimID,HF.HfID,CS.ProdID
	)Claims
	GROUP BY Claims.HFID,Claims.ProdID
GO
