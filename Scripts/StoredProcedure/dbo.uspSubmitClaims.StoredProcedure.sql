/****** Object:  StoredProcedure [dbo].[uspSubmitClaims]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSubmitClaims]
	
	@AuditUser as int = 0,
	@xtClaimSubmit dbo.xClaimSubmit READONLY,
	@Submitted as int = 0 OUTPUT  ,
	@Checked as int = 0 OUTPUT  ,
	@Rejected as int = 0 OUTPUT  ,
	@Changed as int = 0 OUTPUT  ,
	@Failed as int = 0 OUTPUT ,
	@ItemsPassed as int = 0 OUTPUT,
	@ServicesPassed as int = 0 OUTPUT,
	@ItemsRejected as int = 0 OUTPUT,
	@ServicesRejected as int = 0 OUTPUT,
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
	
	 
	
	SET @Checked = 0
	SET @Rejected = 0
	SET @Changed = 0
	SET @Failed = 0
	SET @ItemsPassed = 0 
	SET @ServicesPassed = 0 
	SET @ItemsRejected = 0 
	SET @ServicesRejected = 0 
	
	DECLARE @InTopIsolation as bit 
	
	DECLARE @RtnStatus as int 
	DECLARE @CLAIMID as INT
	DECLARE @ROWID as BIGINT
	DECLARE @RowCurrent as BIGINT
	DECLARE @RtnItemsPassed as int 
	DECLARE @RtnServicesPassed as int 
	DECLARE @RtnItemsRejected as int 
	DECLARE @RtnServicesRejected as int 
	DECLARE @ClaimFailed BIT = 0 
	
	
	SELECT @Submitted = COUNT(ClaimID) FROM @xtClaimSubmit
	
	DECLARE CLAIMLOOP CURSOR LOCAL FORWARD_ONLY FOR SELECT [ClaimID],[RowID] FROM @xtClaimSubmit ORDER BY ClaimID ASC
	OPEN CLAIMLOOP
	FETCH NEXT FROM CLAIMLOOP INTO @CLAIMID,@ROWID
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		SELECT @RowCurrent = RowID FROM tblClaim WHERE ClaimID = @CLAIMID
		IF @RowCurrent <> @ROWID 
		BEGIN
			SET @Changed = @Changed + 1 
			GOTO NextClaim
		END 
		
		IF @@TRANCOUNT = 0 	
			SET @InTopIsolation =0
		ELSE
			SET @InTopIsolation =1
		
		IF @InTopIsolation = 0
		BEGIN
			SET TRANSACTION  ISOLATION LEVEL REPEATABLE READ
			BEGIN TRANSACTION SUBMITCLAIMS
		END

		BEGIN TRY
			--execute the single CLAIM
			EXEC @oReturnValue = [uspSubmitSingleClaim] @AuditUser, @CLAIMID, @ROWID, @RtnStatus OUTPUT,@RtnItemsPassed OUTPUT,@RtnServicesPassed OUTPUT,@RtnItemsRejected OUTPUT,@RtnServicesRejected OUTPUT
		
			IF @oReturnValue <> 0 
			BEGIN
				SET @Failed = @Failed + 1 
				IF @InTopIsolation = 0 
					SET @ClaimFailed = 1
				GOTO NextClaim
			END


			IF @RtnStatus = 0
				SET @Failed = @Failed + 1 
			IF @RtnStatus = 1
				SET @Checked = @Checked + 1 
			IF @RtnStatus = 2
				SET @Rejected = @Rejected + 1 
					
			SET @ItemsPassed = @ItemsPassed + ISNULL(@RtnItemsPassed,0)
			SET @ServicesPassed = @ServicesPassed + ISNULL(@RtnServicesPassed,0)
			SET @ItemsRejected = @ItemsRejected + ISNULL(@RtnItemsRejected ,0)
			SET @ServicesRejected = @ServicesRejected + ISNULL(@RtnServicesRejected ,0)
		
		END TRY
		BEGIN CATCH
			SET @Failed = @Failed + 1 
			--SELECT 'Unexpected error encountered'
			IF @InTopIsolation = 0 
				SET @ClaimFailed = 1
			GOTO NextClaim
		
		END CATCH

NextClaim:
		IF @InTopIsolation = 0 
		BEGIN
			IF @ClaimFailed = 0 
				
				COMMIT TRANSACTION SUBMITCLAIMS	
				
			ELSE
				ROLLBACK TRANSACTION SUBMITCLAIMS
		
		END
		SET @ClaimFailed = 0
		FETCH NEXT FROM CLAIMLOOP INTO @CLAIMID,@ROWID
	END
	CLOSE CLAIMLOOP
	DEALLOCATE CLAIMLOOP
	
FINISH:
	
	SET @oReturnValue = 0 
	RETURN @oReturnValue
	
END


GO
