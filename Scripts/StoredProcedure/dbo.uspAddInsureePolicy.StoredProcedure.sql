/****** Object:  StoredProcedure [dbo].[uspAddInsureePolicy]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[uspAddInsureePolicy]
(
	@InsureeId INT,
	@Activate BIT = 0
)
AS
BEGIN
	DECLARE @FamilyId INT,
			@PolicyId INT,
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
			@ThresholdMember INT

	SELECT @FamilyId = FamilyID,@AuditUserId = AuditUserID FROM tblInsuree WHERE InsureeID = @InsureeId
	SELECT @TotalInsurees = COUNT(InsureeId) FROM tblInsuree WHERE FamilyId = @FamilyId AND ValidityTo IS NULL 
	SELECT @isOffline = ISNULL(OfflineCHF,0)  FROM tblIMISDefaults
	

	
	DECLARE Cur CURSOR FOR SELECT PolicyId,PolicyValue,EffectiveDate,PolicyStage,ProdID FROM tblPolicy WHERE FamilyID  = @FamilyId AND ValidityTo IS NULL
	OPEN Cur
	FETCH NEXT FROM Cur INTO @PolicyId,@PolicyValue,@EffectiveDate,@PolicyStage,@ProdId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @MaxMember = MemberCount FROM tblProduct WHERE ProdId = @ProdId;
		--amani 07/12
		SELECT @ThresholdMember = Threshold FROM tblProduct WHERE ProdId = @ProdId;

		IF @MaxMember < @TotalInsurees
			GOTO NEXT_POLICY;

		EXEC @NewPolicyValue = uspPolicyValue @PolicyId = @PolicyId, @PolicyStage = @PolicyStage, @ErrorCode = @ErrorCode OUTPUT;
		--If new policy value is changed then the current insuree will not be insured
		IF @NewPolicyValue <> @PolicyValue OR @ErrorCode <> 0
		BEGIN
		
			IF @Activate = 0
				SET @EffectiveDate = NULL
		END
	
	
				
			INSERT INTO tblInsureePolicy(InsureeId,PolicyId,EnrollmentDate,StartDate,EffectiveDate,ExpiryDate,AuditUserId,isOffline)
			SELECT @InsureeId, @PolicyId,EnrollDate,P.StartDate,@EffectiveDate,P.ExpiryDate,@AuditUserId,@isOffline
			FROM tblPolicy P 
			WHERE P.PolicyID = @PolicyId
			
NEXT_POLICY:
		FETCH NEXT FROM Cur INTO @PolicyId,@PolicyValue,@EffectiveDate,@PolicyStage,@ProdId
	END
	CLOSE Cur
	DEALLOCATE Cur
END
GO
