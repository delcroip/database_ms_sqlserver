/****** Object:  StoredProcedure [dbo].[uspPolicyValue]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspPolicyValue]
(
	@FamilyId INT =0,			--Provide if policy is not saved
	@ProdId INT =0,				--Provide if policy is not saved
	@PolicyId INT = 0,			--Provide if policy id is known
	@PolicyStage CHAR(1),		--Provide N if new policy, R if renewal
	@EnrollDate DATE = NULL,	--Enrollment date of the policy
	@PreviousPolicyId INT = 0,	--To determine the Expiry Date (For Renewal)
	@ErrorCode INT = 0 OUTPUT
)
AS

/*
********ERROR CODE***********
-1	:	Policy does not exists at the time of enrolment
-2	:	Policy was deleted at the time of enrolment

*/

BEGIN

	SET @ErrorCode = 0;

	DECLARE @LumpSum DECIMAL(18,2) = 0,
			@PremiumAdult DECIMAL(18,2) = 0,
			@PremiumChild DECIMAL(18,2) = 0,
			@RegistrationLumpSum DECIMAL(18,2) = 0,
			@RegistrationFee DECIMAL(18,2) = 0,
			@GeneralAssemblyLumpSum DECIMAL(18,2) = 0,
			@GeneralAssemblyFee DECIMAL(18,2) = 0,
			@Threshold SMALLINT = 0,
			@MemberCount INT = 0,
			@AdultMembers INT =0,
			@ChildMembers INT = 0,
			@OAdultMembers INT =0,
			@OChildMembers INT = 0,
			@Registration DECIMAL(18,2) = 0,
			@GeneralAssembly DECIMAL(18,2) = 0,
			@Contribution DECIMAL(18,2) = 0,
			@PolicyValue DECIMAL(18,2) = 0,
			@ExtraAdult INT = 0,
			@ExtraChild INT = 0,
			@AddonAdult DECIMAL(18,2) = 0,
			@AddonChild DECIMAL(18,2) = 0,
			@DiscountPeriodR INT = 0,
			@DiscountPercentR DECIMAL(18,2) =0,
			@DiscountPeriodN INT = 0,
			@DiscountPercentN DECIMAL(18,2) =0,
			@ExpiryDate DATE
		

		IF @EnrollDate IS NULL 
			SET @EnrollDate = GETDATE();



	--This means you are calculating existing policy
		IF @PolicyId > 0
		BEGIN
			SELECT TOP 1 @FamilyId = FamilyId, @ProdId = ProdId,@PolicyStage = PolicyStage,@EnrollDate = EnrollDate, @ExpiryDate = ExpiryDate FROM tblPolicy WHERE PolicyID = @PolicyId
		END

		DECLARE @ValidityTo DATE = NULL,
				@LegacyId INT = NULL

	/*--Get all the required fiedls from product (Valide product at the enrollment time)--*/
		SELECT TOP 1 @LumpSum = ISNULL(LumpSum,0),@PremiumAdult = ISNULL(PremiumAdult,0),@PremiumChild = ISNULL(PremiumChild,0),@RegistrationLumpSum = ISNULL(RegistrationLumpSum,0),
		@RegistrationFee = ISNULL(RegistrationFee,0),@GeneralAssemblyLumpSum = ISNULL(GeneralAssemblyLumpSum,0), @GeneralAssemblyFee = ISNULL(GeneralAssemblyFee,0), 
		@Threshold = ISNULL(Threshold ,0),@MemberCount = ISNULL(MemberCount,0), @ValidityTo = ValidityTo, @LegacyId = LegacyID, @DiscountPeriodR = ISNULL(RenewalDiscountPeriod, 0), @DiscountPercentR = ISNULL(RenewalDiscountPerc,0)
		, @DiscountPeriodN = ISNULL(EnrolmentDiscountPeriod, 0), @DiscountPercentN = ISNULL(EnrolmentDiscountPerc,0)
		FROM tblProduct 
		WHERE (ProdID = @ProdId OR LegacyID = @ProdId)
		AND CONVERT(DATE,ValidityFrom,103) <= @EnrollDate
		ORDER BY ValidityFrom Desc

		IF @@ROWCOUNT = 0	--No policy found
			SET @ErrorCode = -1
		IF NOT @ValidityTo IS NULL AND @LegacyId IS NULL	--Policy is deleted by the time of enrollment
			SET @ErrorCode = -2
			

	/*
		Relationships to be excluded from the normal family Count
		7: Others
	*/

	--Get only valid insurees according to the maximum members of the product from the family

	IF NOT OBJECT_ID('tempdb..#tblInsuree') IS NULL DROP TABLE #tblInsuree
	SELECT * INTO #tblInsuree FROM tblInsuree WHERE FamilyID = @FamilyId AND ValidityTo IS NULL;

	;WITH TempIns AS
	(
	SELECT ROW_NUMBER() OVER(ORDER BY ValidityFrom) Number, * FROM #tblInsuree
	)DELETE I FROM #tblInsuree I INNER JOIN TempIns T ON I.InsureeId = T.InsureeId
	 WHERE Number > @MemberCount;


	--Get the number of adults, Children, OtherAdult and Other Children from the family
		SET @AdultMembers = (SELECT COUNT(InsureeId) FROM #tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) >= 18 AND ISNULL(Relationship,0) <> 7 AND ValidityTo IS NULL AND FamilyID = @FamilyId) 
		SET @ChildMembers = (SELECT COUNT(InsureeId) FROM #tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) < 18 AND ISNULL(Relationship,0) <> 7  AND ValidityTo IS NULL AND FamilyID = @FamilyId)
		SET @OAdultMembers = (SELECT COUNT(InsureeId) FROM #tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) >= 18 AND ISNULL(Relationship,0) = 7 AND ValidityTo IS NULL AND FamilyID = @FamilyId) 
		SET @OChildMembers = (SELECT COUNT(InsureeId) FROM #tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) < 18 AND ISNULL(Relationship,0) = 7 AND ValidityTo IS NULL AND FamilyID = @FamilyId)


	--Get extra members in family
		IF @Threshold > 0 AND @AdultMembers > @Threshold
			SET @ExtraAdult = @AdultMembers - @Threshold
		IF @Threshold > 0 AND @ChildMembers > (@Threshold - @AdultMembers + @ExtraAdult )
					SET @ExtraChild = @ChildMembers - ((@Threshold - @AdultMembers + @ExtraAdult))
			

	--Get the Contribution
		IF @LumpSum > 0
			SET @Contribution = @LumpSum
		ELSE
			SET @Contribution = (@AdultMembers * @PremiumAdult) + (@ChildMembers * @PremiumChild)

	--Get the Assembly
		IF @GeneralAssemblyLumpSum > 0
			SET @GeneralAssembly = @GeneralAssemblyLumpSum
		ELSE
			SET @GeneralAssembly = (@AdultMembers + @ChildMembers + @OAdultMembers + @OChildMembers) * @GeneralAssemblyFee;

	--Get the Registration
		IF @PolicyStage = N'N'	--Don't calculate if it's renewal
		BEGIN
			IF @RegistrationLumpSum > 0
				SET @Registration = @RegistrationLumpSum
			ELSE
				SET @Registration = (@AdultMembers + @ChildMembers  + @OAdultMembers + @OChildMembers) * @RegistrationFee;
		END

	/* Any member above the maximum member count  or with excluded relationship calculate the extra addon amount */

		SET @AddonAdult = (@ExtraAdult + @OAdultMembers) * @PremiumAdult;
		SET @AddonChild = (@ExtraChild + @OChildMembers) * @PremiumChild;

		SET @Contribution += @AddonAdult + @AddonChild;
		
		--Line below was a mistake, All adults and children are already included in GeneralAssembly and Registration
		--SET @GeneralAssembly += (@OAdultMembers + @OChildMembers + @ExtraAdult + @ExtraChild) * @GeneralAssemblyFee;
		
		--IF @PolicyStage = N'N'
		--	SET @Registration += (@OAdultMembers + @OChildMembers + @ExtraAdult + @ExtraChild) * @RegistrationFee;


	SET @PolicyValue = @Contribution + @GeneralAssembly + @Registration;


	--The total policy value is calculated, So if the enroldate is earlier than the discount period then apply discount
	DECLARE @HasCycle BIT
	DECLARE @tblPeriod TABLE(StartDate DATE, ExpiryDate DATE, HasCycle BIT)
	INSERT INTO @tblPeriod(StartDate, ExpiryDate, HasCycle)
	EXEC uspGetPolicyPeriod @ProdId, @EnrollDate, @HasCycle OUTPUT, @PolicyStage;

	DECLARE @StartDate DATE =(SELECT StartDate FROM @tblPeriod);


	DECLARE @MinDiscountDateR DATE,
			@MinDiscountDateN DATE

	IF @PolicyStage = N'N'
	BEGIN
		SET @MinDiscountDateN = DATEADD(MONTH,-(@DiscountPeriodN),@StartDate);
		IF @EnrollDate <= @MinDiscountDateN AND @HasCycle = 1
			SET @PolicyValue -=  (@PolicyValue * 0.01 * @DiscountPercentN);
	END
	ELSE IF @PolicyStage  = N'R'
	BEGIN
		DECLARE @PreviousExpiryDate DATE = NULL

		IF @PreviousPolicyId > 0
		BEGIN
			SELECT @PreviousExpiryDate = DATEADD(DAY, 1, ExpiryDate) FROM tblPolicy WHERE ValidityTo IS NULL AND PolicyId = @PreviousPolicyId;	
		END
		ELSE
		BEGIN
			SET @PreviousExpiryDate = @StartDate;
		END

		SET @MinDiscountDateR = DATEADD(MONTH,-(@DiscountPeriodR),@PreviousExpiryDate);
		IF @EnrollDate <= @MinDiscountDateR
			SET @PolicyValue -=  (@PolicyValue * 0.01 * @DiscountPercentR);
	END

	SELECT @PolicyValue PolicyValue;
	RETURN @PolicyValue;

END

GO
