/****** Object:  StoredProcedure [dbo].[uspPolicyValueBEPHA]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspPolicyValueBEPHA]
(
	@FamilyId INT,
	@ProdId INT,
	@PolicyId INT = 0,
	@isRenewal BIT = 0
)
AS
BEGIN
	DECLARE @LumpSum DECIMAL(18,2) = 0,
			@PremiumAdult DECIMAL(18,2) = 0,
			@PremiumChild DECIMAL(18,2) = 0,
			@RegistrationLumpSum DECIMAL(18,2) = 0,
			@RegistrationFee DECIMAL(18,2) = 0,
			@GeneralAssemblyLumpSum DECIMAL(18,2) = 0,
			@GeneralAssemblyFee DECIMAL(18,2) = 0,
			@MemberCount SMALLINT = 0,
			@AdultMembers INT =0,
			@ChildMembers INT = 0,
			@Registration DECIMAL(18,2) = 0,
			@GeneralAssembly DECIMAL(18,2) = 0,
			@Contribution DECIMAL(18,2) = 0,
			@PolicyValue DECIMAL(18,2) = 0
		
			
	/*--In case of policy id is provided--*/
	IF @PolicyId > 0
	BEGIN
		SELECT @FamilyId = FamilyId, @ProdId = ProdId,@isRenewal = CASE WHEN PolicyStage = N'R' THEN 1 ELSE 0 END FROM tblPolicy WHERE PolicyID = @PolicyId
	END

	/*--Get all the required fiedls from product--*/
	SELECT @LumpSum = ISNULL(LumpSum,0),@PremiumAdult = ISNULL(PremiumAdult,0),@PremiumChild = ISNULL(PremiumChild,0),@RegistrationLumpSum = ISNULL(RegistrationLumpSum,0),
	@RegistrationFee = ISNULL(RegistrationFee,0),@GeneralAssemblyLumpSum = ISNULL(GeneralAssemblyLumpSum,0), @GeneralAssemblyFee = ISNULL(GeneralAssemblyFee,0), 
	@MemberCount = ISNULL(MemberCount ,0)
	FROM tblProduct WHERE ProdID = @ProdId

	/*--Get all the required fiedls from family--*/
	SET @AdultMembers = (SELECT COUNT(InsureeId) FROM tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) >= 18 AND ValidityTo IS NULL AND FamilyID = @FamilyId) 
	SET @ChildMembers = (SELECT COUNT(InsureeId) FROM tblInsuree WHERE DATEDIFF(YEAR,DOB,GETDATE()) < 18 AND ValidityTo IS NULL AND FamilyID = @FamilyId)

	/*--Get the General Assembly Fee Depending on the Product Definition--*/
	IF @GeneralAssemblyLumpSum > 0
		SET @GeneralAssembly = @GeneralAssemblyLumpSum
	ELSE IF @GeneralAssemblyFee > 0
		SET @GeneralAssembly = @GeneralAssemblyFee * (@AdultMembers + @ChildMembers)


	/*--Get the Registration Fee Depending on the Product Definition--*/
	IF @isRenewal = 0
	BEGIN
		IF @RegistrationLumpSum > 0 
			SET @Registration  = @RegistrationLumpSum
		ELSE IF @RegistrationFee > 0 
			SET @Registration = @Registration * (@AdultMembers + @ChildMembers)
		
	END
	ELSE
		SET @Registration = 0
		
	/*--Get the contribution Depending on the Product Definition--*/
	IF @LumpSum > 0 
		SET @Contribution = @LumpSum
	ELSE
		SET @Contribution = (@PremiumAdult * @AdultMembers) * (@PremiumChild * @ChildMembers)
		

	SET @PolicyValue = @GeneralAssembly + @Registration + @Contribution

	SELECT @PolicyValue
END
GO
