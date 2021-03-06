/****** Object:  StoredProcedure [dbo].[uspSSRSDerivedIndicators2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSDerivedIndicators2]
(
	@LocationId INT = 0,
	@ProductID INT = 0,
	@HFID INT = 0,
	@Month INT,
	@Year INT
)	
AS
BEGIN
	DECLARE @LastDay DATE
	
	IF NOT OBJECT_ID('tempdb..#tmpResult') IS NULL DROP TABLE #tmpResult
	
	CREATE TABLE #tmpResult(
		NameOfTheMonth VARCHAR(15),
		DistrictName NVARCHAR(50),
		HFCode NVARCHAR(8),
		HFName NVARCHAR(100) ,
		ProductCode NVARCHAR(8), 
		ProductName NVARCHAR(100),
		SettlementRatio DECIMAL(18,2),
		AverageCostPerClaim DECIMAL(18,2),
		Asessment DECIMAL(18,2),
		FeedbackResponseRatio DECIMAL(18,2)
		
	)

DECLARE @Counter INT = 1
DECLARE @MaxCount INT = 12

IF @Month > 0
	BEGIN
		SET @Counter = @Month
		SET @MaxCount = @Month
	END
	
WHILE @Counter <> @MaxCount + 1
BEGIN

	SET @LastDay = DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Counter AS VARCHAR(2)) + '-01'))
	
	INSERT INTO #tmpResult
	SELECT CAST(YEAR(@LastDay) AS VARCHAR(4)) + ' ' + DATENAME(MONTH,@LastDay)NameOfTheMonth,MainInfo.DistrictName,MainInfo.HFCode,MainInfo.HFName ,MainInfo.ProductCode , MainInfo.ProductName
	,(TC.TotalClaims - ISNULL(RC.RejectedClaims,0))/TC.TotalClaims SettlementRatio
	--,CAST(SUM(ISNULL(R.Remunerated,0))/CAST(ISNULL(NULLIF(COUNT(TC.TotalClaims),0),1) AS NUMERIC) AS FLOAT)AverageCostPerClaim
	,CAST(SUM(ISNULL(R.Remunerated,0))/TC.TotalClaims AS FLOAT)AverageCostPerClaim
	,Satisfaction.Asessment
	,FeedbackResponse.FeedbackResponseRatio
	FROM

	(SELECT tblDistricts.DistrictName,tblHF.HfID  ,tblHF.HFCode ,tblHF.HFName ,tblProduct.ProdID , tblProduct.ProductCode ,tblProduct.ProductName FROM tblDistricts INNER JOIN tblHF ON tblDistricts.DistrictID = tblHF.LocationId 
	INNER JOIN tblProduct ON tblProduct.LocationId = tblDistricts.DistrictID 
	WHERE tblDistricts.ValidityTo IS NULL AND tblHF.ValidityTo IS NULL AND tblproduct.ValidityTo IS NULL 
				AND (tblDistricts.DistrictID = @LocationId OR @LocationId = 0) 
				AND (tblProduct.ProdID = @ProductID OR @ProductID = 0)
				AND (tblHF.HFID = @HFID OR @HFID = 0)
	) MainInfo LEFT OUTER JOIN
	dbo.udfRejectedClaims(@ProductID,@LocationId,0,@Counter,@Year)RC ON MainInfo.ProdID = RC.ProdID AND MainInfo.HfID = RC.HFID LEFT OUTER JOIN
	dbo.udfTotalClaims(@ProductID,@HFID,@LocationId,@Counter,@Year) TC ON MainInfo.ProdID = TC.ProdID AND MainInfo.hfid = TC.HFID LEFT OUTER JOIN
	dbo.udfRemunerated(@HFID,@ProductID,@LocationId,@Counter,@Year) R ON MainInfo.ProdID = R.ProdID AND MainInfo.HfID = R.HFID LEFT OUTER JOIN
	(SELECT C.LocationId,C.HFID,C.ProdID,AVG(CAST(F.Asessment AS DECIMAL(3, 1)))Asessment 
	FROM tblFeedback F INNER JOIN
	(SELECT CI.ClaimID,CI.ProdID,C.HFID,PR.LocationId
	FROM tblClaim C INNER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
	INNER JOIN tblProduct PR ON CI.ProdID = PR.ProdID
	WHERE C.ValidityTo IS NULL AND CI.ValidityTo IS NULL AND PR.ValidityTo IS NULL
	GROUP BY CI.ClaimID,CI.ProdID,C.HFID,PR.LocationId
	UNION 
	SELECT CS.ClaimID,CS.ProdID,C.HFID,PR.LocationId
	FROM tblClaim C INNER JOIN tblClaimServices CS ON C.ClaimID = CS.ClaimID
	INNER JOIN tblProduct PR ON CS.ProdID = PR.ProdID
	WHERE C.ValidityTo IS NULL AND CS.ValidityTo IS NULL AND PR.ValidityTo IS NULL
	GROUP BY CS.ClaimID,CS.ProdID,C.HFID,PR.LocationId
	)C ON F.ClaimID = C.ClaimID
	WHERE MONTH(F.FeedbackDate) = @Counter AND YEAR(F.FeedbackDate) = @Year
	GROUP BY C.LocationId,C.HFID,C.ProdID)Satisfaction ON MainInfo.ProdID = Satisfaction.ProdID AND MainInfo.HfID = Satisfaction.HFID
	LEFT OUTER JOIN
	(SELECT PR.LocationId, C.HFID, PR.ProdId, COUNT(F.FeedbackID) / COUNT(C.ClaimID) FeedbackResponseRatio
	FROM tblClaim C LEFT OUTER JOIN tblClaimItems CI ON C.ClaimId = CI.ClaimID
	LEFT OUTER JOIN tblClaimServices CS ON CS.ClaimID = C.ClaimID
	LEFT OUTER JOIN tblFeedback F ON C.ClaimId = F.ClaimID
	LEFT OUTER JOIN tblFeedbackPrompt FP ON FP.ClaimID =C.ClaimID
	INNER JOIN tblProduct PR ON PR.ProdId = CI.ProdID OR PR.ProdID = CS.ProdID
	WHERE C.ValidityTo IS NULL
	AND C.FeedbackStatus >= 4
	AND F.ValidityTo IS NULL
	AND MONTH(FP.FeedbackPromptDate) = @Counter
	AND YEAR(FP.FeedbackPromptDate) = @Year
	GROUP BY PR.LocationId, C.HFID, PR.ProdId)FeedbackResponse ON MainInfo.ProdID = FeedbackResponse.ProdID AND MainInfo.HfID = FeedbackResponse.HFID
	
	GROUP BY MainInfo.DistrictName,MainInfo.HFCode,MainInfo.HFName,MainInfo.ProductCode,MainInfo.ProductName,RC.RejectedClaims,Satisfaction.Asessment,FeedbackResponse.FeedbackResponseRatio, TC.TotalClaims
	SET @Counter = @Counter + 1

END

	SELECT * FROM #tmpResult

END
GO
