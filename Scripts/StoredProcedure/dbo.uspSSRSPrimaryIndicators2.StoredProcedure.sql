/****** Object:  StoredProcedure [dbo].[uspSSRSPrimaryIndicators2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspSSRSPrimaryIndicators2]
(
	@LocationId INT = 0,
	@ProductID INT = 0,
	@HFID INT = 0,
	@MonthFrom INT,
	@MonthTo INT,
	@Year INT
)
AS
BEGIN

	IF NOT OBJECT_ID('tempdb..#tmpResult') IS NULL DROP TABLE #tmpResult
	
	CREATE TABLE #tmpResult(
		NameOfTheMonth VARCHAR(20),
		DistrictName NVARCHAR(50),
		HFCode NVARCHAR(8),
		HFName NVARCHAR(100),
		ProductCode NVARCHAR(8), 
		ProductName NVARCHAR(100), 
		TotalClaims INT,
		Remunerated DECIMAL(18,2),
		RejectedClaims INT,
		MonthNo INT
		
	)	

DECLARE @Counter INT = 1
DECLARE @MaxCount INT = 12

IF @MonthFrom > 0
	BEGIN
		SET @Counter = @MonthFrom
		SET @MaxCount = @MonthTo
	END
	
IF @LocationId = -1
SET @LocationId = NULL
WHILE @Counter <> @MaxCount + 1
BEGIN
		DECLARE @LastDay DATE = DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Counter AS VARCHAR(2)) + '-01'))
			
		INSERT INTO #tmpResult
		SELECT CAST(YEAR(@LastDay) AS VARCHAR(4)) + ' ' + DATENAME(MONTH,@LastDay),MainInfo.DistrictName,
		MainInfo.HFCode,MainInfo.HFName ,MainInfo.ProductCode , MainInfo.ProductName , 
		TC.TotalClaims TotalClaims,
		R.Remunerated Remunerated,
		RC.RejectedClaims RejectedClaims,
		DATEPART(MM,@LastDay) MonthNo --Added by Rogers On 19092017
	FROM
	(SELECT  DistrictName DistrictName,HF.HFID,HF.HFCode,HF.HFName,Prod.ProdID,Prod.ProductCode,Prod.ProductName
	FROM tblClaim C 
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblHF HF ON C.HFID = HF.HFID 
	INNER JOIN tblDistricts D ON D.DistrictId = HF.LocationId
	 
	LEFT OUTER JOIN 
	(SELECT ClaimId,ProdId FROM tblClaimItems WHERE ValidityTo IS NULL
	UNION 
	SELECT ClaimId, ProdId FROM tblClaimServices WHERE ValidityTo IS NULL
	)CProd ON CProd.ClaimId = C.ClaimID
	LEFT OUTER JOIN tblProduct Prod ON Prod.ProdId = CProd.ProdID
	WHERE C.ValidityTo IS NULL 
	AND I.ValidityTo IS NULL 
	AND D.ValidityTo IS NULL 
	AND HF.ValidityTo IS NULL 
	AND Prod.ValidityTo IS NULL
	AND  HF.LocationId  = @LocationId --Changed From LocationId to HFLocationId	On 29062017
	AND (Prod.ProdID = @ProductId OR @ProductId = 0)
	AND (HF.HfID = @HFID OR @HFID = 0)
	GROUP BY DistrictName,HF.HFID,HF.HFCode,HF.HFName,Prod.ProdID,Prod.ProductCode,Prod.ProductName
	) MainInfo 
	LEFT OUTER JOIN dbo.udfTotalClaims(@ProductID,@HFID,@LocationId,@Counter,@Year) TC ON ISNULL(MainInfo.ProdID, 0) = ISNULL(TC.ProdID, 0) AND MainInfo.HfID = TC.HFID 
	LEFT OUTER JOIN dbo.udfRemunerated(@HFID,@ProductID,@LocationId,@Counter,@Year) R ON ISNULL(MainInfo.ProdID, 0) = ISNULL(R.ProdID, 0) AND MainInfo.HfID = R.HFID 
	LEFT OUTER JOIN dbo.udfRejectedClaims(@ProductID,@HFID,@LocationId,@Counter,@Year) RC ON ISNULL(MainInfo.ProdID, 0) = ISNULL(RC.ProdID, 0) AND MainInfo.HfID = RC.HFID

	SET @Counter = @Counter + 1
	
END
	
	SELECT NameOfTheMonth,MonthNo,DistrictName,HFCode ,HFName,ProductCode,ProductName ,ISNULL(TotalClaims,0) TotalClaims ,ISNULL(Remunerated,0) Remunerated ,ISNULL(RejectedClaims,0) RejectedClaims FROM #tmpResult
	ORDER BY MonthNo  --Added by Rogers On 19092017

END
GO
