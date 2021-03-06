/****** Object:  StoredProcedure [dbo].[uspProcessClaimsTEST]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspProcessClaimsTEST]
	
	@AuditUser as int = 0,
	@CLaimID as int = 21,
	@Submitted as bigint = 0 OUTPUT  ,
	@Processed as bigint = 0 OUTPUT  ,
	@Valuated as bigint = 0 OUTPUT ,
	@Changed as bigint = 0 OUTPUT ,
	@Rejected as bigint = 0 OUTPUT  ,
	@Failed as bigint = 0 OUTPUT ,
	@oReturnValue as int = 0 OUTPUT
	
	
	/*  
	Rejection reasons:
	
	1 = Item/Service not in Registers
	2 = Item/Service not in Covering Product
	3 = Item/Service not in HF Pricelist 
	4 = Item/Service Limitation Fail
	5 = Item/Service Frequency Fail
	6 = Item/Service DUPLICATD
	7 = 
	8 = 
	9 = 
	10=
	11=
	12=
	*/
	
AS
BEGIN
	SET @oReturnValue = 0 	
	SET @Processed = 0
	SET @Rejected = 0
	SET @Valuated = 0
	SET @Failed = 0

	SET @Changed = 0 

	SELECT @Submitted = 1
	DECLARE @InTopIsolation as bit 
	
	SET @InTopIsolation = -1 
	
	BEGIN TRY 
	
	IF @@TRANCOUNT = 0 	
		SET @InTopIsolation =0
	ELSE
		SET @InTopIsolation =1
	IF @InTopIsolation = 0
	BEGIN
		--SELECT 'SET ISOLATION TNX ON'
		SET TRANSACTION  ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION PROCESSCLAIMS
	END

	DECLARE @RtnStatus as int 

	DECLARE @ROWID as BIGINT = 1
	DECLARE @InsureeID as int 
	DECLARE @RowCurrent as BIGINT
	DECLARE @RtnItemsPassed as int 
	DECLARE @RtnServicesPassed as int 
	DECLARE @RtnItemsRejected as int 
	DECLARE @RtnServicesRejected as int 
	DECLARE @HFCareType as Char(1)
	DECLARE @HFLevel as Char(1)
	
	 DECLARE @DateFrom Date
	 DECLARE @DateTo Date
	 DECLARE @TargetDate Date
	DECLARE @Hospitalization BIT 
	DECLARE @AdultChild char(1)
		
		declare @DOB date 

		SELECT @RowCurrent = RowID FROM tblClaim WHERE ClaimID = @CLAIMID
		IF @RowCurrent <> @ROWID 
		BEGIN
			SET @Changed = @Changed + 1 
			--GOTO NextClaim
		END 
		--execute the single CLAIM and set the correct price 
		SELECT @HFCareType = HFCareType FROM tblClaim INNER JOIN tblHF ON tblHF.HfID = tblClaim.HFID WHERE tblClaim.ClaimID = @CLAIMID 
		SELECT @HFLevel = HFLevel FROM tblClaim INNER JOIN tblHF ON tblHF.HfID = tblClaim.HFID WHERE tblClaim.ClaimID = @CLAIMID  
		SELECT @InsureeID = InsureeID, @DateFrom = DateFrom , @TargetDate = ISNULL(TblClaim.DateTo,TblClaim.DateFrom)  FROM tblClaim WHERE ClaimID = @ClaimID 
		
		IF @DateFrom <> @TargetDate 
			SET @Hospitalization = 1 --hospitalization
		ELSE
			SET @Hospitalization = 0  --Day visit/treatment 

		SELECT @DOB = DOB FROM tblInsuree WHERE InsureeID = @InsureeID 
		IF DATEDIFF(YY  ,@DOB,@TargetDate ) >=18 
			SET @AdultChild = 'A'
		ELSE
			SET @AdultChild = 'C'

		EXEC @oReturnValue = [uspProcessSingleClaimStep1] @AuditUser, @CLAIMID, @InsureeID , @HFCareType, @ROWID, @AdultChild, @RtnStatus OUTPUT
	
		IF @RtnStatus = 0 OR @oReturnValue <> 0 
		BEGIN
			SET @Failed = @Failed + 1 
			--GOTO NextClaim
		END
		
		IF @RtnStatus = 2
		BEGIN
			SET @Rejected = @Rejected + 1 
			--GOTO NextClaim
		END
		--apply to claims deductables and ceilings
		EXEC @oReturnValue = [uspProcessSingleClaimStep2] @AuditUser ,@CLAIMID, @InsureeID, @HFLevel, @ROWID, @AdultChild, @Hospitalization, 1 ,@RtnStatus OUTPUT
		
		IF @RtnStatus = 0 OR @oReturnValue <> 0 
		BEGIN
			SET @Failed = @Failed + 1 
			--GOTO NextClaim
		END
		
		IF @RtnStatus = 3
		BEGIN
			SET @Processed  = @Processed  + 1 
			--GOTO NextClaim
		END
		
		IF @RtnStatus = 4
		BEGIN
			SET @Valuated = @Valuated + 1 
			--GOTO NextClaim
		END			

	ROLLBACK TRANSACTION PROCESSCLAIMS

	

FINISH:
	IF @InTopIsolation = 0 COMMIT TRANSACTION PROCESSCLAIMS
	SET @oReturnValue = 0 
	RETURN @oReturnValue

	END TRY
	BEGIN CATCH
		SET @oReturnValue = 1 
		SELECT 'Unexpected error encountered'
		IF @InTopIsolation = 0 ROLLBACK TRANSACTION PROCESSCLAIMS
		RETURN @oReturnValue
		
	END CATCH
	
ERR_HANDLER:

	SELECT 'Unexpected error encountered'
	IF @InTopIsolation = 0 ROLLBACK TRANSACTION PROCESSCLAIMS
	RETURN @oReturnValue

	
END




GO
