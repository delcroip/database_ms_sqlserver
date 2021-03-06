/****** Object:  StoredProcedure [dbo].[uspDeleteFromPhone]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[uspDeleteFromPhone]
 (
		@Id INT,
		@AuditUserId INT,
		@DeleteInfo CHAR(2),
		@ErrorMessage NVARCHAR(300) = OUTPUT
	)
AS 
BEGIN
	BEGIN TRY
		IF @DeleteInfo = 'F'
			BEGIN
				--Delete Family
			
				IF EXISTS(SELECT * FROM tblPolicy WHERE FamilyID =@Id AND ValidityTo IS NULL) RETURN 3
				INSERT INTO tblFamilies ([insureeid],LocationId, [Poverty], [ConfirmationType],isOffline,[ValidityFrom],[ValidityTo], [LegacyID],[AuditUserID],[Ethnicity], [ConfirmationNo])
				SELECT [insureeid],LocationId,[Poverty], [ConfirmationType],isOffline,[ValidityFrom],GETDATE(), @Id, [AuditUserID],Ethnicity, [ConfirmationNo] 
				FROM tblFamilies 
				WHERE FamilyID = @Id 
					  AND ValidityTo IS NULL; 
				UPDATE [tblFamilies] set [ValidityFrom]=GETDATE(),[ValidityTo]=GETDATE(),[AuditUserID] = @AuditUserID 
				WHERE FamilyID = @Id AND ValidityTo IS NULL;

				--Delete Insuree
				INSERT INTO tblInsuree ([FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[PhotoID],[PhotoDate],[CardIssued],isOffline,[AuditUserID],
				[ValidityFrom] ,[ValidityTo],legacyId,TypeOfId, HFID, CurrentAddress, CurrentVillage,GeoLocation )  
				SELECT	[FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[PhotoID],[PhotoDate],[CardIssued],isOffline,[AuditUserID],[ValidityFrom] ,GETDATE(),@Id ,TypeOfId, HFID, CurrentAddress, CurrentVillage, GeoLocation 
				FROM tblInsuree 
				WHERE FamilyID = @Id  
				AND ValidityTo IS NULL; 
				UPDATE [tblInsuree] SET [ValidityFrom] = GETDATE(),[ValidityTo] = GETDATE(),[AuditUserID] = @AuditUserID  
				WHERE FamilyID = @Id  
				AND ValidityTo IS NULL;

				--Delete Policy
				 INSERT INTO tblPolicy (FamilyID, EnrollDate, StartDate, EffectiveDate, ExpiryDate, ProdID, OfficerID,PolicyStatus,PolicyValue,isOffline, ValidityTo, LegacyID, AuditUserID) 
				 SELECT FamilyID, EnrollDate, StartDate, EffectiveDate, ExpiryDate, ProdID, OfficerID,PolicyStatus,PolicyValue,isOffline, GETDATE(), @Id, AuditUserID 
				 FROM tblPolicy WHERE FamilyID = @Id AND ValidityTo IS NULL; 
				 UPDATE tblPolicy set ValidityFrom = GETDATE(), ValidityTo = GETDATE(), AuditUserID = @AuditUserID WHERE FamilyID = @Id AND ValidityTo IS NULL
			
				--Delete Premium
				INSERT INTO tblPremium (PolicyID, PayerID, Amount, Receipt, PayDate, PayType,isOffline, ValidityTo, LegacyID, AuditUserID,isPhotoFee) 
				SELECT P.PolicyID, PayerID, Amount, Receipt, PayDate, PayType,P.isOffline, GETDATE(), @Id,P.AuditUserID,isPhotoFee 
				FROM tblPremium P
				INNER JOIN tblPolicy Po ON P.PolicyID =Po.PolicyID
				WHERE FamilyId = @Id 
				AND P.ValidityTo IS NULL
				AND Po.ValidityTo IS NULL; 

				UPDATE  PR SET [ValidityFrom] = GETDATE(),[ValidityTo] = GETDATE(),[AuditUserID] = @AuditUserID FROM tblPremium PR
				INNER JOIN tblPolicy Po ON PR.PolicyID =Po.PolicyID
				WHERE FamilyID = @Id 
				AND PR.ValidityTo IS NULL
				AND Po.ValidityTo IS NULL
			END
		ELSE IF @DeleteInfo ='I'
			BEGIN
				IF EXISTS(SELECT 1 FROM tblInsuree WHERE InsureeID =@Id AND IsHead = 1) RETURN 2
				INSERT INTO tblInsuree ([FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[PhotoID],[PhotoDate],[CardIssued],isOffline,[AuditUserID],
				[ValidityFrom] ,[ValidityTo],legacyId,TypeOfId, HFID, CurrentAddress, CurrentVillage,GeoLocation )  
				SELECT	[FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[PhotoID],[PhotoDate],[CardIssued],isOffline,[AuditUserID],[ValidityFrom] ,GETDATE(),@Id ,TypeOfId, HFID, CurrentAddress, CurrentVillage, GeoLocation 
				FROM tblInsuree 
				WHERE InsureeID = @Id  
				AND ValidityTo IS NULL; 
				UPDATE [tblInsuree] SET [ValidityFrom] = GETDATE(),[ValidityTo] = GETDATE(),[AuditUserID] = @AuditUserID  
				WHERE InsureeID = @Id  
				AND ValidityTo IS NULL;
			END
		ELSE IF @DeleteInfo ='PO'
			BEGIN
				 INSERT INTO tblPolicy (FamilyID, EnrollDate, StartDate, EffectiveDate, ExpiryDate, ProdID, OfficerID,PolicyStatus,PolicyValue,isOffline, ValidityTo, LegacyID, AuditUserID) 
				 SELECT FamilyID, EnrollDate, StartDate, EffectiveDate, ExpiryDate, ProdID, OfficerID,PolicyStatus,PolicyValue,isOffline, GETDATE(), @Id, AuditUserID 
				 FROM tblPolicy WHERE PolicyID = @Id AND ValidityTo IS NULL; 
				 UPDATE tblPolicy set ValidityFrom = GETDATE(), ValidityTo = GETDATE(), AuditUserID = @AuditUserID WHERE PolicyID = @Id AND ValidityTo IS NULL

				INSERT INTO tblPremium (PolicyID, PayerID, Amount, Receipt, PayDate, PayType,isOffline, ValidityTo, LegacyID, AuditUserID,isPhotoFee) 
				SELECT P.PolicyID, PayerID, Amount, Receipt, PayDate, PayType,P.isOffline, GETDATE(), @Id,P.AuditUserID,isPhotoFee 
				FROM tblPremium P
				WHERE PolicyID = @Id 
				AND P.ValidityTo IS NULL;

				UPDATE  PR SET [ValidityFrom] = GETDATE(),[ValidityTo] = GETDATE(),[AuditUserID] = @AuditUserID FROM tblPremium PR
				WHERE PolicyID=@Id 
				AND PR.ValidityTo IS NULL; 
			END
		ELSE IF @DeleteInfo ='PR'
			BEGIN
				INSERT INTO tblPremium (PolicyID, PayerID, Amount, Receipt, PayDate, PayType,isOffline, ValidityTo, LegacyID, AuditUserID,isPhotoFee) 
				SELECT P.PolicyID, PayerID, Amount, Receipt, PayDate, PayType,P.isOffline, GETDATE(), @Id,P.AuditUserID,isPhotoFee 
				FROM tblPremium P
				WHERE PremiumId = @Id 
				AND P.ValidityTo IS NULL; 

				UPDATE  PR SET [ValidityFrom] = GETDATE(),[ValidityTo] = GETDATE(),[AuditUserID] = @AuditUserID FROM tblPremium PR
				WHERE PremiumID=@Id 
				AND PR.ValidityTo IS NULL;
			 
			END
	RETURN 1
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RETURN 0
	END CATCH
END
GO
