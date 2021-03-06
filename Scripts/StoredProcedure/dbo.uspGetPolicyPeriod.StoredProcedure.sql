/****** Object:  StoredProcedure [dbo].[uspGetPolicyPeriod]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspGetPolicyPeriod]
(
	@ProdId INT,
	@EnrolDate DATE,
	@HasCycles BIT = 0 OUTPUT,
	@PolicyStage NVARCHAR(1) = N'N'
)
AS
BEGIN
		DECLARE	@StartCycle1 DATE,
				@StartCycle2 DATE,
				@StartCycle3 DATE,
				@StartCycle4 DATE,
				@GracePeriod INT,
				@StartDate DATE,
				@InsurancePeriod INT,
				@AdministratorPeriod INT
	
	--Add administration period to the enrolment date and then check the cycle
	SELECT @AdministratorPeriod = ISNULL(AdministrationPeriod,0) FROM tblProduct WHERE ProdID = @ProdId;
	IF @PolicyStage = N'N'
		SET @EnrolDate = DATEADD(MONTH, @AdministratorPeriod, @EnrolDate);

--Check if they work on cycles
	IF EXISTS(SELECT 1 FROM tblProduct WHERE ProdId = @ProdId AND LEN(StartCycle1) > 0)
	BEGIN

		SET @HasCycles = 1;
		
		SELECT @StartCycle1 = CONVERT(DATE,StartCycle1 + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		, @StartCycle2 = CONVERT(DATE,ISNULL(NULLIF(StartCycle2,''),StartCycle1) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		, @StartCycle3 = CONVERT(DATE,ISNULL(NULLIF(StartCycle3,''),ISNULL(NULLIF(StartCycle2,''),StartCycle1)) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
, @StartCycle4 = CONVERT(DATE,ISNULL(NULLIF(StartCycle4,''),ISNULL(NULLIF(StartCycle3,''),ISNULL(NULLIF(StartCycle2,''),StartCycle1))) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		

		/*SELECT @StartCycle1 = CONVERT(DATE,StartCycle1 + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		, @StartCycle2 = CONVERT(DATE,ISNULL(NULLIF(StartCycle2,''),StartCycle1) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		, @StartCycle3 = CONVERT(DATE,ISNULL(NULLIF(StartCycle3,''),StartCycle2) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)
		, @StartCycle4 = CONVERT(DATE,ISNULL(NULLIF(StartCycle4,''),StartCycle3) + '-' + CAST(YEAR(@EnrolDate)AS NVARCHAR(4)),103)*/
		,@GracePeriod = GracePeriod,@InsurancePeriod = InsurancePeriod
		FROM tblProduct WHERE ProdID = @ProdId

		IF @EnrolDate < DATEADD(MONTH,@GracePeriod,@StartCycle1)
			SET @StartDate = @StartCycle1
		ELSE IF @EnrolDate < DATEADD(MONTH,@GracePeriod,@StartCycle2)
			SET @StartDate = @StartCycle2
		ELSE IF @EnrolDate < DATEADD(MONTH,@GracePeriod,@StartCycle3)
			SET @StartDate = @StartCycle3
		ELSE IF @EnrolDate < DATEADD(MONTH,@GracePeriod,@StartCycle4)
			SET @StartDate = @StartCycle4
		ELSE
			SET @StartDate = DATEADD(YEAR,1,@StartCycle1)
		
		SELECT @StartDate StartDate, DATEADD(DAY,-1,DATEADD(MONTH,@InsurancePeriod,@StartDate)) ExpiryDate, @HasCycles HasCycle;
	END
	ELSE	--They don't work on cycles so get the enrolment date as start date and derive expiry date from product period
	BEGIN
		
		SET @HasCycles = 0;
		
		SELECT @StartDate = @EnrolDate,@InsurancePeriod = InsurancePeriod 
		FROM tblProduct WHERE ProdID = @ProdId

		SELECT @StartDate StartDate, DATEADD(DAY,-1,DATEADD(MONTH,@InsurancePeriod,@StartDate)) ExpiryDate, @HasCycles HasCycle;
	END
END

GO
