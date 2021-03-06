/****** Object:  StoredProcedure [dbo].[uspAddInsureePolicyOffline]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[uspAddInsureePolicyOffline]
(
	--@InsureeId INT,
	@PolicyId INT,
	@Activate BIT = 0
)
AS
BEGIN

	DECLARE @FamilyId INT,			
			@NewPolicyValue DECIMAL(18,2),
			@EffectiveDate DATE,
			@PolicyValue DECIMAL(18,2),
			@PolicyStage NVARCHAR(1),
			@ProdId INT,
			@AuditUserId INT,
			@isOffline BIT,
			@ErrorCode INT,
			@TotalInsurees INT,
			@MaxMember INT,
			@ThresholdMember INT,
			@Premium DECIMAL(18,2),
			@NewFamilyId INT,
			@NewPolicyId INT,
			@NewInsureeId INT
	DECLARE @Result TABLE(ErrorMessage NVARCHAR(500))
	DECLARE @tblInsureePolicy TABLE(
	InsureeId int NULL,
	PolicyId int NULL,
	EnrollmentDate date NULL,
	StartDate date NULL,
	EffectiveDate date NULL,
	ExpiryDate date NULL,
	ValidityFrom datetime NULL ,
	ValidityTo datetime NULL,
	LegacyId int NULL,
	AuditUserId int NULL,
	isOffline bit NULL,
	RowId timestamp NULL
)

----BY AMANI 19/12/2017
	--SELECT @FamilyId = FamilyID,@AuditUserId = AuditUserID FROM tblInsuree WHERE InsureeID = @InsureeId
	SELECT @FamilyId = F.FamilyID,@AuditUserId = F.AuditUserID FROM tblFamilies F
	INNER JOIN tblPolicy P ON P.FamilyID=F.FamilyID AND P.PolicyID=@PolicyId  AND F.ValidityTo IS NULL  AND P.ValidityTo IS NULL
	SELECT @isOffline = ISNULL(OfflineCHF,0)  FROM tblIMISDefaults
	SELECT @ProdId=ProdID FROM tblPolicy WHERE PolicyID=@PolicyId
	SET    @Premium=ISNULL((SELECT SUM(Amount) Amount FROM tblPremium WHERE PolicyID=@PolicyId AND ValidityTo IS NULL),0)
	SELECT @MaxMember = ISNULL(MemberCount,0) FROM tblProduct WHERE ProdId = @ProdId;		
	SELECT @ThresholdMember = Threshold FROM tblProduct WHERE ProdId = @ProdId;

	SELECT @PolicyStage = PolicyStage FROM tblPolicy WHERE PolicyID=@PolicyId
				
BEGIN TRY
	SAVE TRANSACTION TRYSUB	---BEGIN SAVE POINT

	--INSERT TEMPORARY FAMILY
	INSERT INTO tblFamilies(InsureeID, LocationId, Poverty, ValidityFrom, ValidityTo, LegacyID, AuditUserID, FamilyType, FamilyAddress, isOffline, Ethnicity, ConfirmationNo, ConfirmationType)
	SELECT					InsureeID, LocationId, Poverty, ValidityFrom, ValidityTo, LegacyID, AuditUserID, FamilyType, FamilyAddress, isOffline, Ethnicity, ConfirmationNo, ConfirmationType 
	FROM tblFamilies WHERE FamilyID=@FamilyId  AND ValidityTo IS NULL 
	SET @NewFamilyId = (SELECT SCOPE_IDENTITY());

	EXEC @NewPolicyValue = uspPolicyValue @FamilyId=@NewFamilyId, @PolicyStage=@PolicyStage, @ErrorCode = @ErrorCode OUTPUT;

	--INSERT TEMP POLICY
	INSERT INTO dbo.tblPolicy
           (FamilyID,EnrollDate,StartDate,EffectiveDate,ExpiryDate,PolicyStatus,PolicyValue,ProdID,OfficerID,PolicyStage,ValidityFrom,ValidityTo,LegacyID,AuditUserID,isOffline)
 SELECT		@NewFamilyId,EnrollDate,StartDate,EffectiveDate,ExpiryDate,PolicyStatus,@NewPolicyValue,ProdID,OfficerID,@PolicyStage,ValidityFrom,ValidityTo,LegacyID,AuditUserID,isOffline
  FROM dbo.tblPolicy WHERE PolicyID=@PolicyId
	SET @NewPolicyId = (SELECT SCOPE_IDENTITY());


		--SELECT InsureeID FROM tblInsuree WHERE FamilyID =@FamilyId AND ValidityTo IS NULL 	ORDER BY InsureeID ASC

		DECLARE @NewCurrentInsureeId INT =0
	
		DECLARE CurTempInsuree CURSOR FOR 
		SELECT InsureeID FROM tblInsuree WHERE FamilyID =@FamilyId AND ValidityTo IS NULL 	ORDER BY InsureeID ASC
		OPEN CurTempInsuree
		FETCH NEXT FROM CurTempInsuree INTO @NewCurrentInsureeId
		WHILE @@FETCH_STATUS = 0
		BEGIN
				INSERT INTO dbo.tblInsuree
		  (FamilyID,CHFID,LastName,OtherNames,DOB,Gender,Marital,IsHead,passport,Phone,PhotoID,PhotoDate,CardIssued,ValidityFrom,ValidityTo,LegacyID,AuditUserID,Relationship,Profession,Education,Email,isOffline,TypeOfId,HFID,CurrentAddress ,GeoLocation,CurrentVillage)
  
		SELECT   
		   @NewFamilyId,CHFID,LastName,OtherNames,DOB,Gender,Marital,IsHead,passport,Phone,PhotoID,PhotoDate,CardIssued,ValidityFrom,ValidityTo,LegacyID,AuditUserID,Relationship,Profession,Education,Email,isOffline,TypeOfId,HFID,CurrentAddress,GeoLocation,CurrentVillage
		  FROM dbo.tblInsuree WHERE InsureeID=@NewCurrentInsureeId
		  SET @NewInsureeId= (SELECT SCOPE_IDENTITY());
			SELECT @TotalInsurees = COUNT(InsureeId) FROM tblInsuree WHERE FamilyId = @NewFamilyId AND ValidityTo IS NULL 
				IF  @TotalInsurees > @MaxMember 
				GOTO CLOSECURSOR;
		
	SELECT @EffectiveDate= EffectiveDate, @PolicyValue=ISNULL(PolicyValue,0) FROM tblPolicy  WHERE PolicyID =@NewPolicyId AND ValidityTo IS NULL 
			EXEC @NewPolicyValue = uspPolicyValue @PolicyId = @NewPolicyId, @PolicyStage = @PolicyStage, @ErrorCode = @ErrorCode OUTPUT;
			--If new policy value is changed then the current insuree will not be insured
		IF @NewPolicyValue <> @PolicyValue OR @ErrorCode <> 0
		BEGIN
	UPDATE tblPolicy SET PolicyValue=@NewPolicyValue WHERE PolicyID=@NewPolicyId
		IF @Activate = 0 
			IF  @Premium < @NewPolicyValue
			BEGIN
				SET @EffectiveDate = NULL
			END
		END

		--INSERT TEMP INSUREEPOLICY
	
		INSERT INTO @tblInsureePolicy(InsureeId,PolicyId,EnrollmentDate,StartDate,EffectiveDate,ExpiryDate,ValidityFrom,AuditUserId,isOffline)
			SELECT @NewCurrentInsureeId, @PolicyId,EnrollDate,P.StartDate,@EffectiveDate,P.ExpiryDate,GETDATE(),@AuditUserId,@isOffline
			FROM tblPolicy P 
			WHERE P.PolicyID = @NewPolicyId
		

		CLOSECURSOR:
		FETCH NEXT FROM CurTempInsuree INTO @NewCurrentInsureeId
		END														
		CLOSE CurTempInsuree
		
	
		ROLLBACK TRANSACTION  TRYSUB --ROLLBACK SAVE POINT			
		SELECT * FROM @tblInsureePolicy

		--BEGIN TRY	

		--MERGE TO THE REAL TABLE


		MERGE INTO tblInsureePolicy  AS TARGET
			USING @tblInsureePolicy AS SOURCE
				ON TARGET.InsureeId = SOURCE.InsureeId
				AND TARGET.PolicyId = SOURCE.PolicyId
				AND TARGET.ValidityTo IS NULL
			WHEN MATCHED THEN 
				UPDATE SET TARGET.EffectiveDate = SOURCE.EffectiveDate
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (InsureeId,PolicyId,EnrollmentDate,StartDate,EffectiveDate,ExpiryDate,ValidityFrom,AuditUserId,isOffline)
				VALUES (SOURCE.InsureeId,
						SOURCE.PolicyId, 
						SOURCE.EnrollmentDate, 
						SOURCE.StartDate, 
						SOURCE.EffectiveDate, 
						SOURCE.ExpiryDate, 
						SOURCE.ValidityFrom, 
						SOURCE.AuditUserId, 
						SOURCE.isOffline);
		--END TRY
		--BEGIN CATCH
		--	SELECT ERROR_MESSAGE();
		--	ROLLBACK TRANSACTION  TRYSUB;	
		--END CATCH
	

END TRY
BEGIN CATCH
		ROLLBACK TRANSACTION  TRYSUB;	
		SELECT @ErrorCode;
		INSERT INTO @Result(ErrorMessage) VALUES(ERROR_MESSAGE())
		SELECT * INTO TempError FROM @Result
END CATCH
	
END



GO
