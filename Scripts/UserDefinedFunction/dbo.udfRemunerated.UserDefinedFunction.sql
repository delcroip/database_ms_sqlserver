/****** Object:  UserDefinedFunction [dbo].[udfRemunerated]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[udfRemunerated]
(
	@HFID INT = 0,
	@ProdID INT = 0,
	@LocationId INT = 0,
	@Month INT,
	@Year INT
)
RETURNS TABLE
AS
RETURN
	
	SELECT Remunerated.ProdID, Remunerated.HFID,SUM(Rem)Remunerated FROM
	(
		SELECT CI.ProdID,HF.HfID,ISNULL(SUM(CI.RemuneratedAmount), 0) AS Rem
		FROM tblClaim C 
		INNER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
		INNER JOIN tblHF HF ON C.HFID = HF.HfID
		INNER JOIN uvwLocations L ON HF.LocationId = L.LocationId   --Changed From DistrictId to HFLocationId 29062017 Rogers
		WHERE C.ValidityTo IS NULL 
		AND CI.ValidityTo IS NULL 
		AND HF.ValidityTo IS NULL 
		AND (CI.ProdID = @ProdId OR @ProdId = 0)
		AND (HF.HfID = @HFID OR @HFID = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
		AND MONTH(C.DateFrom) = @Month 
		AND YEAR(C.DateFrom) = @Year
		AND CI.ClaimItemStatus = 1
		AND C.ClaimStatus = 16
		GROUP BY CI.ProdID,HF.HfID
		UNION ALL
		SELECT CS.ProdID,HF.HfID,ISNULL(SUM(CS.RemuneratedAmount), 0) AS Rem
		FROM tblClaim C 
		INNER JOIN tblClaimServices CS ON C.ClaimID = CS.ClaimID
		INNER JOIN tblHF HF ON C.HFID = HF.HfID
		INNER JOIN uvwLocations L ON HF.LocationId = L.LocationId   --Changed From DistrictId to HFLocationId 29062017 Rogers
		WHERE C.ValidityTo IS NULL 
		AND CS.ValidityTo IS NULL 
		AND HF.ValidityTo IS NULL 
		AND (CS.ProdID = @ProdId OR @ProdId = 0)
		AND (HF.HfID = @HFID OR @HFID = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
		AND MONTH(C.DateFrom) = @Month 
		AND YEAR(C.DateFrom) = @Year
		AND CS.ClaimServiceStatus = 1
		AND C.ClaimStatus = 16
		GROUP BY CS.ProdID,HF.HfID
	)Remunerated
	GROUP BY Remunerated.ProdID, Remunerated.HFID
GO
