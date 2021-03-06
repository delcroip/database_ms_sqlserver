/****** Object:  StoredProcedure [dbo].[uspLastDateForPayment]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspLastDateForPayment]
(
	@PolicyId INT
)
AS
BEGIN
	DECLARE @ProdId INT,
		@HasCycle BIT = 0,
		@GracePeriod INT,
		@WaitingPeriod INT,
		@StartDate DATE,
		@PolicyStage CHAR(1),
		@ExpiryDate DATE,
		@EnrollDate DATE,
		@LastDate DATE

	SELECT @ProdId = ProdId FROM tblPolicy WHERE PolicyId = @PolicyId;
	IF EXISTS(SELECT 1 FROM tblProduct Prod WHERE ProdID = @ProdId AND (StartCycle1 IS NOT NULL OR StartCycle2 IS NOT NULL OR StartCycle3 IS NOT NULL OR StartCycle4 IS NOT NULL))
		SET @HasCycle = 1;

	SELECT @GracePeriod = CASE PL.PolicyStage WHEN 'N' THEN Prod.GracePeriod WHEN 'R' THEN GracePeriodRenewal END,
	@WaitingPeriod = Prod.WaitingPeriod
	FROM tblProduct Prod
	INNER JOIN tblPolicy PL ON PL.ProdId = Prod.ProdId
	WHERE Prod.ProdId = @ProdId;

	IF @HasCycle = 1
	BEGIN
		PRINT N'Calculate on Fixed Cycle';
		SELECT @StartDate = StartDate FROM tblPolicy WHERE PolicyId = @PolicyId;
		SET @LastDate = DATEADD(MONTH, @GracePeriod, @StartDate)
		PRINT @LastDate
	END
	ELSE
	BEGIN
		PRINT N'Calculate on Free Cycle';
		SELECT @PolicyStage = PolicyStage, @EnrollDate = EnrollDate, @ExpiryDate = ExpiryDate FROM tblPolicy WHERE PolicyId = @PolicyId;
		IF @PolicyStage = 'N'
			SET @LastDate = DATEADD(MONTH, @WaitingPeriod, @EnrollDate);
		IF @PolicyStage = 'R'
			SET @LastDate = DATEADD(MONTH, @WaitingPeriod, DATEADD(DAY, 1, @ExpiryDate));
	END

	SELECT DATEADD(DAY, -1, @LastDate) LastDate;
END
GO
