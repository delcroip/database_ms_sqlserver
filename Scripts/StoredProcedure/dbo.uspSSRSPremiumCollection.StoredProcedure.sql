/****** Object:  StoredProcedure [dbo].[uspSSRSPremiumCollection]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspSSRSPremiumCollection]
(
	@LocationId INT = 0,
	@Product INT = 0,
	@PaymentType VARCHAR(2) = '',
	@FromDate DATE,
	@ToDate DATE,
	@dtPaymentType xCareType READONLY
)
AS
BEGIN
	IF @LocationId=-1
		SET @LocationId = 0

	SELECT LF.RegionName, LF.DistrictName
	,Prod.ProductCode,Prod.ProductName,SUM(Pr.Amount) Amount, 
	PT.Name PayType,Pr.PayDate,Prod.AccCodePremiums 

	FROM tblPremium PR 
	INNER JOIN tblPolicy PL ON PR.PolicyID = PL.PolicyID
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
	INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyID
	INNER JOIN uvwLocations LF ON LF.VillageId = F.LocationId
	INNER JOIN @dtPaymentType PT ON PT.Code = PR.PayType

	WHERE Prod.ValidityTo IS NULL 
	AND PR.ValidityTo IS NULL 
	AND F.ValidityTo  IS NULL
	
	AND (Prod.ProdId = @Product OR @Product = 0)
	AND (Pr.PayType = @PaymentType OR @PaymentType = '')
	AND Pr.PayDate BETWEEN @FromDate AND @ToDate
	AND (LF.RegionId = @LocationId OR LF.DistrictId = @LocationId OR    @LocationId =0 ) --OR ISNULL(Prod.LocationId, 0) = ISNULL(@LocationId, 0) BY Rogers
	
	GROUP BY LF.RegionName, LF.DistrictName, Prod.ProductCode,Prod.ProductName,Pr.PayDate,Pr.PayType,Prod.AccCodePremiums, PT.Name
END
GO
