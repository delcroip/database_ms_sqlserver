/****** Object:  StoredProcedure [dbo].[uspSSRSProductSales]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSProductSales]
(
	@LocationId INT = 0,
	@Product INT = 0,
	@FromDate DATE,
	@ToDate DATE
)
AS
BEGIN
	IF @LocationId = -1
		SET @LocationId=NULL
	SELECT L.DistrictName,Prod.ProductCode,Prod.ProductName,PL.EffectiveDate, SUM(PL.PolicyValue) PolicyValue
	FROM tblPolicy PL 
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
	INNER JOIN tblFamilies F ON PL.FamilyId = F.FamilyID
	--INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	--INNER JOIN tblWards W ON W.WardId = V.WardId
	--INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId 
	INNER JOIN uvwLocations L ON L.VillageId = F.LocationId
	WHERE PL.ValidityTo IS NULL 
	AND Prod.ValidityTo IS NULL 
	AND F.validityTo IS NULL
	--AND (ISNULL(Prod.LocationId,-1) = ISNULL(@LocationId,-1) OR @LocationId = 0)
	AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0)
	AND (Prod.ProdID = @Product OR @Product = 0)
	AND PL.EffectiveDate BETWEEN @FromDate AND @ToDate
	GROUP BY L.DistrictName,Prod.ProductCode,Prod.ProductName,PL.EffectiveDate
END
GO
