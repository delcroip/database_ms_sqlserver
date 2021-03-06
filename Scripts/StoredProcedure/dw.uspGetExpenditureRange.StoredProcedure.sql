/****** Object:  StoredProcedure [dw].[uspGetExpenditureRange]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dw].[uspGetExpenditureRange]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxAmount FLOAT,
			@Step FLOAT = 25000
		
	DECLARE @Counter FLOAT = @Step;

	DECLARE @Range NVARCHAR(30) = '',
			@Low FLOAT = 0,
			@High FLOAT

	SELECT @MaxAmount = MAX(Valuated) FROM(
	SELECT C.ClaimID, SUM(ISNULL(CI.PriceValuated,0) + ISNULL(CS.PriceValuated,0))Valuated
	FROM tblClaim C LEFT OUTER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
	LEFT OUTER JOIN tblClaimServices CS ON C.ClaimId = CS.ClaimID
	WHERE C.ValidityTo IS NULL
	AND C.ClaimStatus > 4
	GROUP BY C.ClaimID)Val

	DECLARE @Temp TABLE(ExpenditureRange NVARCHAR(50),ExpenditureLow FLOAT, ExpenditureHigh FLOAT)

	WHILE @Counter - @Step < @MaxAmount
	BEGIN
		SET @Low = CASE WHEN @Counter - @Step - 1 < 0 THEN 0 ELSE @Counter - @Step + 1 END
		SET @High = @Counter
		SET @Range = CAST(@Low AS NVARCHAR) + '-' + CAST(@High AS NVARCHAR)

		INSERT INTO @Temp(ExpenditureRange,ExpenditureLow,ExpenditureHigh)
		SELECT @Range,@Low,@High;

		SET @Counter += @Step;
	END


	SELECT * FROM @Temp;

END
GO
