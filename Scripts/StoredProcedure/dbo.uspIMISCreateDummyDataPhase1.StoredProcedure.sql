/****** Object:  StoredProcedure [dbo].[uspIMISCreateDummyDataPhase1]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery11.sql|7|0|C:\Users\Hans2\AppData\Local\Temp\~vsF4E7.sql
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspIMISCreateDummyDataPhase1]
	-- Add the parameters for the stored procedure here
	
	@UserCount int = 1,
	@CurrentUserID int = 3,
	@DistrictCount int = 50,
	@VillageCount int = 100,
	@WardCount int = 20,
	@FamiliesPerDistrict int = 500,
	@FamilyMemCount int = 4,
	@ServicesCount int = 75, 
	@ItemsCount int = 250,
	@PLCountServices int = 5,
	@PLCountItems int = 5,
	@HFCount int,
	@PAYERCount int ,
	@OfficerCount int,
	@ProductCount int,
	@FamPolicyCount int,
	@SplitPremium1inX int

AS
BEGIN
	SET NOCOUNT ON;
	
	--Users
	
	DECLARE @Counter1 int
	DECLARE @Counter2 int
	DECLARE @Counter3 int
	DECLARE @Counter4 int
	DECLARE @DUMMYCODE1 as nvarchar(25)
	DECLARE @DUMMYCODE2 as nvarchar(25)	
	

	SET @Counter1 = 1
	WHILE @Counter1 <= @UserCount 
	BEGIN
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'Enrolment Officer ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role1_' + CAST(@Counter1 as nvarchar(1000)),'Role1_' + CAST(@Counter1 as nvarchar(1000)),1,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'CHF Manager ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role2_' + CAST(@Counter1 as nvarchar(1000)),'Role2_' + CAST(@Counter1 as nvarchar(1000)),2,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'CHF Accountant ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role4_' + CAST(@Counter1 as nvarchar(1000)),'Role4_' + CAST(@Counter1 as nvarchar(1000)),4,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'CHF Clerk ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role8_' + CAST(@Counter1 as nvarchar(1000)),'Role8_' + CAST(@Counter1 as nvarchar(1000)),8,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'CHF Medical ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role16_' + CAST(@Counter1 as nvarchar(1000)),'Role16_' + CAST(@Counter1 as nvarchar(1000)),16,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'CHF Administrator ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role32_' + CAST(@Counter1 as nvarchar(1000)),'Role32_' + CAST(@Counter1 as nvarchar(1000)),32,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'IMIS Administrator ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role64_' + CAST(@Counter1 as nvarchar(1000)),'Role64_' + CAST(@Counter1 as nvarchar(1000)),64,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'Receptionist ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role128_' + CAST(@Counter1 as nvarchar(1000)),'Role128_' + CAST(@Counter1 as nvarchar(1000)),128,@CurrentUserID)
		INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'Claim Administrator ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','Role256_' + CAST(@Counter1 as nvarchar(1000)),'Role256_' + CAST(@Counter1 as nvarchar(1000)),256,@CurrentUserID)
	    INSERT INTO tblUsers ([LanguageID],[LastName],[OtherNames],[Phone],[LoginName],[Password],[RoleID],[AuditUserID])
		VALUES (0,'ALL ' + CAST(@Counter1 as nvarchar(1000)) ,'Dummy','0987-12345','ALL_' + CAST(@Counter1 as nvarchar(1000)),'ALL_' + CAST(@Counter1 as nvarchar(1000)),511,@CurrentUserID)
	           
		SET @Counter1 = @Counter1 + 1
    END

	--Districts
	SET @Counter1 = 1
	WHILE @Counter1 <= @DistrictCount 
	BEGIN
		INSERT INTO tblDistricts ([DistrictName],[Region],[AuditUserID])
        VALUES ('District ' + CAST(@Counter1 as nvarchar(1000)), 'Region 1',@CurrentUserID)
		SET @Counter1 = @Counter1 + 1
	END
	
	DECLARE @ID1 as int 
	DECLARE @ID2 as int
	DECLARE @STR1 as nvarchar(100)

	--wards
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @WardCount 
		BEGIN
			INSERT INTO tblwards ([DistrictID],[WardName],[AuditUserID])
			VALUES(@ID1,'Ward ' + CAST(@Counter1 as nvarchar(1000)) + ' in ' + @STR1,@CurrentUserID )
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1

--Villages
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT WardID, WardName FROM tblWards
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @VillageCount 
		BEGIN
			INSERT INTO tblVillages ([WardID],[VillageName],[AuditUserID])
			VALUES(@ID1,'Village ' + CAST(@Counter1 as nvarchar(1000)) + ' in ' + @STR1,@CurrentUserID) 
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
 
 
	--usermapping to districts only set users that have ALL set.
	INSERT INTO tblUsersDistricts ([UserID] ,[DistrictID],[AuditUserID])
    SELECT     tblUsers.UserID, tblDistricts.DistrictID, @CurrentUserID
	FROM         tblDistricts CROSS JOIN tblUsers WHERE tblUsers.RoleID = 511 	
	
	
	
	--FAMILIES 
	DECLARE @DISTRICTID int
	DECLARE @VILLAGEID int
	DECLARE @WARDID int
	DECLARE @LASTFAMILYID int 
	DECLARE @LASTINSUREEID int 
	DECLARE @MAXInsuree int
	DECLARE @NewInsuree as varchar(25)
	DECLARE @CHKDIGIT as tinyint
	
	
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @DISTRICTID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @FamiliesPerDistrict 
		BEGIN
			SELECT TOP 1 @WARDID = WardID FROM TblWards WHERE DistrictID = @DISTRICTID ORDER BY NewID()
			SELECT TOP 1 @VILLAGEID = VillageID FROM TblVillages WHERE WardID  = @WARDID ORDER BY NewID()
			SELECT @MAXInsuree =    MAX( CAST( LEFT(CHFID,8) as int) ) FROM tblInsuree
			SET @MAXInsuree = ISNULL(@MAXInsuree,0) + 1
			SET @CHKDIGIT = 7 - (@MAXInsuree % 7) 
			SET @NewInsuree= CAST(@MAXInsuree as nvarchar(8) ) + CAST(@CHKDIGIT as nvarchar(1) )
			SELECT @NewInsuree = RIGHT ('00000000' + @NewInsuree ,9)
			
			INSERT INTO tblFamilies([InsureeID],[DistrictID],[VillageID],[WardID],[Poverty],[AuditUserID])
			VALUES (0,@DISTRICTID,@VILLAGEID,@WARDID,0,@CurrentUserID)
			SELECT @LASTFAMILYID = MAX(FamilyID) FROM tblFamilies
			
			SET @Counter2 = 1
			--now insert all members on the family --> first the head of family seperately to write back to family table
			INSERT INTO tblInsuree ([FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[CardIssued],[AuditUserID])
			VALUES (
			@LASTFAMILYID
           ,@NewInsuree   
           ,'Family ' + CAST(@Counter1 as nvarchar(1000)) + ' (' + CAST(@DISTRICTID as nvarchar(1000)) + '-' + CAST(@VILLAGEID as nvarchar(1000)) + '-' + CAST(@WARDID as nvarchar(1000)) + ')'
           ,'FamMem' + CAST(@Counter2 as nvarchar(1000))
           ,'01-01-1985'
           ,'M'
           ,'M'
           ,1
           ,'1234567890'
           ,'0897-887336'
           ,1
           ,@CurrentUserID)
			SELECT @LASTINSUREEID = MAX(InsureeID) FROM tblInsuree
			--now update family to set the head insuree
			UPDATE TblFamilies SET InsureeID = @LASTINSUREEID WHERE FamilyID = @LASTFAMILYID

			SET @Counter2 = @Counter2 + 1 --all dependants
			WHILE @Counter2 <= @FamilyMemCount 
			BEGIN
				SELECT @MAXInsuree =    MAX( CAST( LEFT(CHFID,8) as int) ) FROM tblInsuree
				SET @MAXInsuree = ISNULL(@MAXInsuree,0) + 1
				SET @CHKDIGIT = 7 - (@MAXInsuree % 7) 
				SET @NewInsuree= CAST(@MAXInsuree as nvarchar(8) ) + CAST(@CHKDIGIT as nvarchar(1) )
				SELECT @NewInsuree = RIGHT ('00000000' + @NewInsuree ,9)
				INSERT INTO tblInsuree ([FamilyID],[CHFID],[LastName],[OtherNames],[DOB],[Gender],[Marital],[IsHead],[passport],[Phone],[CardIssued],[AuditUserID])
				VALUES (
				@LASTFAMILYID
			   , @NewInsuree
			   ,'Family ' + CAST(@Counter1 as nvarchar(1000)) + ' (' + CAST(@DISTRICTID as nvarchar(1000)) + '-' + CAST(@VILLAGEID as nvarchar(1000)) + '-' + CAST(@WARDID as nvarchar(1000)) + ')'
			   ,'FamMem' + CAST(@Counter2 as nvarchar(1000))
			   ,'01-01-1998'
			   ,'F'
			   ,'M'
			   ,0
			   ,'1234567890'
			   ,'0897-887336'
			   ,1
			   ,@CurrentUserID)
				SET @Counter2 = @Counter2 + 1	
			END
				
           	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @DISTRICTID	
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
  
	DECLARE @InsISCareType as char(1)
	DECLARE @CareType TABLE (Care Char(1))
	INSERT INTO @CareType VALUES ('I')
	INSERT INTO @CareType VALUES ('O')
	INSERT INTO @CareType VALUES ('B')

-- INsert items and services
	DECLARE @InsType as Char(1)
	DECLARE @InsLevel Char(1)
	DECLARE @InsCareType int
	DECLARE @Price decimal(18,2)
	DECLARE @Level TABLE (Lvl Char(1))
	INSERT INTO @Level VALUES ('S')
	INSERT INTO @Level VALUES ('V')
	INSERT INTO @Level VALUES ('D')
	INSERT INTO @Level VALUES ('H')
	
	SET @Counter1 = 1
	WHILE @Counter1 <= @ServicesCount
	BEGIN
		IF @InsType = 'P' 
			SET @InsType = 'C'
		ELSE
			SET @InsType = 'P'
		SELECT @Price = ROUND(RAND() * 10000,-2)
		SELECT TOP 1 @InsLevel = Lvl FROM @Level ORDER BY NewID()
		SELECT TOP 1 @InsISCareType = Care FROM @CareType ORDER BY NewID()
		INSERT INTO tblServices([ServCode],[ServName],[ServType],[ServLevel],[ServPrice],[ServCareType],[ServFrequency],[ServPatCat],[AuditUserID])
		VALUES
           ('S-' + CAST(@Counter1 as nvarchar(1000))
           ,'Medical Service ' + CAST(@Counter1 as nvarchar(1000))
           ,@InsType
           ,@InsLevel
           ,@Price
           ,@InsISCareType
           ,7
           ,Cast(((15 + 1) - 1) * Rand() + 1 As tinyint)
           ,@CurrentUserID)
		SET @Counter1 = @Counter1 + 1
	END	



	SET @Counter1 = 1
	WHILE @Counter1 <= @ItemsCount
	BEGIN
		IF @InsType = 'D' 
			SET @InsType = 'P'
		ELSE
			SET @InsType = 'D'
		SELECT @Price = ROUND(RAND() * 10000,-2)
		SELECT TOP 1 @InsLevel = Lvl FROM @Level ORDER BY NewID()
		SELECT TOP 1 @InsISCareType = Care FROM @CareType ORDER BY NewID()
		INSERT INTO tblItems([ItemCode],[ItemName],[ItemType],[ItemPackage],[ItemPrice],[ItemCareType],[ItemFrequency],[ItemPatCat],[AuditUserID])
		VALUES
           ('I-' + CAST(@Counter1 as nvarchar(1000))
           ,'Medical Item ' + CAST(@Counter1 as nvarchar(1000))
           ,@InsType
           ,'Box'
           ,@Price
           ,@InsISCareType
           ,7
           ,Cast(((15 + 1) - 1) * Rand() + 1 As tinyint)
           ,@CurrentUserID)
		SET @Counter1 = @Counter1 + 1
	END	

	
	--Create PL across all districts 
	
	INSERT INTO tblPLServices ([PLServName],[DatePL],[AuditUserID])
			VALUES
           ('National Services PriceList' 
           ,GETDATE()
           ,@CurrentUserID)

	INSERT INTO tblPLItems ([PLItemName],[DatePL],[AuditUserID])
			VALUES
           ('National Items PriceList' 
           ,GETDATE()
           ,@CurrentUserID)

	--Create PLs per District
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @PLCountServices 
		BEGIN
			INSERT INTO tblPLServices ([PLServName],[DatePL],[DistrictID],[AuditUserID])
			VALUES
           ('Services PriceList ' + CAST(@Counter1 as nvarchar(1000)) +  ' ' + @STR1
           ,GETDATE()
           ,@ID1
           ,@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1

	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @PLCountItems 
		BEGIN
			INSERT INTO tblPLItems ([PLItemName],[DatePL],[DistrictID],[AuditUserID])
			VALUES
           ('Items PriceList ' + CAST(@Counter1 as nvarchar(1000)) +  ' ' + @STR1
           ,GETDATE()
           ,@ID1
           ,@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	--now allocate all item to all pricelists without any overule price (=null)
	INSERT INTO tblPLServicesDetail ([PLServiceID],[ServiceID],[AuditUserID])
	SELECT     tblPLServices.PLServiceID, tblServices.ServiceID , @CurrentUserID
	FROM         tblServices CROSS JOIN tblPLServices     

	INSERT INTO tblPLItemsDetail ([PLItemID],[ItemID],[AuditUserID])
	SELECT     tblPLItems.PLItemID, tblItems.ItemID , @CurrentUserID
	FROM         tblPLItems CROSS JOIN tblItems     

	--HFs
	
	DECLARE @HFLevel TABLE (Lvl Char(1))
	INSERT INTO @HFLevel VALUES ('D')
	INSERT INTO @HFLevel VALUES ('C')
	INSERT INTO @HFLevel VALUES ('H')
	DECLARE @Legal TABLE (Leg Char(1))
	INSERT INTO @Legal VALUES ('G')
	INSERT INTO @Legal VALUES ('D')
	INSERT INTO @Legal VALUES ('P')
	INSERT INTO @Legal VALUES ('C')
	
	
	DECLARE @DispCount int
	DECLARE @HospCount int
	DECLARE @FacCount int 
	DECLARE @InsLegal char(1)
	DECLARE @HFInsLevel char(1)
	DECLARE @HFCode nvarchar(25)
	DECLARE @HFInsCareType char(1)
	DECLARE @HFName nvarchar(200)
	DECLARE @PLItems int
	DECLARE @PLServices int 
	SET @DispCount = 0 
	SET @HospCount = 0 
	SET @FacCount = 0 
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @HFCount 
		BEGIN
			SELECT TOP 1 @HFInsLevel = Lvl FROM @HFLevel ORDER BY NewID()
			SELECT TOP 1 @InsLegal = Leg FROM @Legal ORDER BY NewID()
			SELECT TOP 1 @HFInsCareType = Care FROM @CareType ORDER BY NewID()
			IF @HFInsLevel = 'D'
			BEGIN
				SET @DispCount = @DispCount + 1 
				SET @HFName = 'Dispensary ' + CAST(@DispCount as nvarchar(1000)) + ' in ' + @STR1
				SET @HFCode = RIGHT('000' + CAST(@ID1 as nvarchar(1000)),3)  + @HFInsLevel + CAST(@DispCount as nvarchar(1000))
			END 
			IF @HFInsLevel = 'H' 
			BEGIN
				SET @HospCount = @HospCount + 1
				SET @HFName = 'Hospital ' + CAST(@HospCount as nvarchar(1000)) + ' in ' + @STR1
				SET @HFCode = RIGHT('000' + CAST(@ID1 as nvarchar(1000)),3) + @HFInsLevel  + CAST(@HospCount as nvarchar(1000))
			END 
			IF @HFInsLevel = 'C' 
			BEGIN
				SET @FacCount = @FacCount + 1
				SET @HFName = 'Health Centre ' + CAST(@FacCount as nvarchar(1000)) + ' in ' + @STR1
				SET @HFCode = RIGHT('000' + CAST(@ID1 as nvarchar(1000)),3) + @HFInsLevel  + CAST(@FacCount as nvarchar(1000))
			END 			
			
			SELECT TOP 1 @PLItems = PLItemID FROM dbo.tblPLItems WHERE DistrictID = @ID1 ORDER BY NewID()
			SELECT TOP 1 @PLServices = PLServiceID FROM dbo.tblPLServices WHERE DistrictID = @ID1 ORDER BY NewID()
	     	INSERT INTO tblHF ([HFName],[HFCode],[LegalForm],[HFLevel],[HFAddress],[DistrictID],[Phone],[Fax],[eMail],[HFCareType],[PLServiceID],[PLItemID],[AccCode],[AuditUserID])
			VALUES
				   (@HFName
				   ,@HFCode
				   ,@InsLegal
				   ,@HFInsLevel
				   ,'Dummy address 12345'
				   ,@ID1
				   ,'0999-000888'
				   ,'022-123456'
				   ,'dummy@facility.co.tz'
				   ,@HFInsCareType
				   ,@PLServices
				   ,@PLItems
				   ,'200-12345678'
				   ,@CurrentUserID)
		
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1

	--Payers
	
	INSERT INTO tblPayer ([PayerType],[PayerName],[PayerAddress],[Phone],[Fax],[eMail],[AuditUserID])
	VALUES ('G','National Government','Dummy address','0445-123456','0445-112233','gov@tanzania.com',@CurrentUserID)
	INSERT INTO tblPayer ([PayerType],[PayerName],[PayerAddress],[Phone],[Fax],[eMail],[AuditUserID])
	VALUES ('C','National Cooperative','Dummy address','0445-123456','0445-112233','gov@tanzania.com',@CurrentUserID)
	INSERT INTO tblPayer ([PayerType],[PayerName],[PayerAddress],[Phone],[Fax],[eMail],[AuditUserID])
	VALUES ('P','National Private Organization','Dummy address','0445-123456','0445-112233','gov@tanzania.com',@CurrentUserID)

	DECLARE @InsPayerType char(1)
	DECLARE @GCount int
	DECLARE @PCount int
	DECLARE @CCount int
	DECLARE @DCount int
	DECLARE @PayerName nvarchar(100)
	DECLARE @PayerType TABLE (Ptype Char(1))
	INSERT INTO @PayerType VALUES ('G')
	INSERT INTO @PayerType VALUES ('D')
	INSERT INTO @PayerType VALUES ('P')
	INSERT INTO @PayerType VALUES ('C')
	INSERT INTO @PayerType VALUES ('L')
	INSERT INTO @PayerType VALUES ('O')
	SET @GCount = 0 
	SET @PCount = 0 
	SET @CCount = 0 
	SET @DCount = 0 
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @PAYERCount 
		BEGIN
			SELECT TOP 1 @InsPayerType = pType FROM @PayerType ORDER BY NewID()	
			IF @InsPayerType = 'G'
			BEGIN
				SET @GCount = @GCount + 1 
				SET @PayerName = 'Government ' + CAST(@GCount as nvarchar(1000)) + ' in ' + @STR1
			END 
			IF @InsPayerType = 'L'
			BEGIN
				SET @DCount = @DCount + 1 
				SET @PayerName = 'Local Authority ' + CAST(@DCount as nvarchar(1000)) + ' in ' + @STR1
			END 
			IF @InsPayerType = 'C'
			BEGIN
				SET @CCount = @CCount + 1 
				SET @PayerName = 'Cooperative ' + CAST(@CCount as nvarchar(1000)) + ' in ' + @STR1
			END 
			IF @InsPayerType = 'P'
			BEGIN
				SET @PCount = @PCount + 1 
				SET @PayerName = 'Private Organization ' + CAST(@PCount as nvarchar(1000)) + ' in ' + @STR1
			END 
	
			IF @InsPayerType = 'D'
			BEGIN
				SET @PCount = @PCount + 1 
				SET @PayerName = 'Donor ' + CAST(@PCount as nvarchar(1000)) + ' in ' + @STR1
			END 
	
			IF @InsPayerType = 'O'
			BEGIN
				SET @PCount = @PCount + 1 
				SET @PayerName = 'Other ' + CAST(@PCount as nvarchar(1000)) + ' in ' + @STR1
			END 
	
	
			INSERT INTO tblPayer ([PayerType],[PayerName],[DistrictID],[PayerAddress],[Phone],[Fax],[eMail],[AuditUserID])
			VALUES (@InsPayerType,@PayerName,@ID1, 'Dummy address','0445-123456', '0445-112233','payer@tanzania.com',@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1

	--officers
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @OfficerCount 
		BEGIN
			SELECT @DUMMYCODE1 = RIGHT ('000' + CAST(@ID1 as nvarchar(10))  ,3)
			SELECT @DUMMYCODE2 = RIGHT ('00000' + CAST(@Counter1 as nvarchar(10))  ,5)
			INSERT INTO tblOfficer([Code],[LastName],[OtherNames],[DOB],[Phone],[DistrictID],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[AuditUserID])
			VALUES
            (
            @DUMMYCODE1 + @DUMMYCODE2
           ,'Enrolment officer ' + CAST(@Counter1 as nvarchar(1000)) +  ' in ' + @STR1
           ,'test officer'
           ,'1975-01-01'
           ,'0342-090807'
           ,@ID1,
           'VEO-' + CAST(@ID1 as nvarchar(1000)) + '-' + CAST(@Counter1 as nvarchar(1000))
           ,'Village officer ' + CAST(@Counter1 as nvarchar(1000)) +  ' in ' + @STR1
           ,'test village officer'
           ,'1985-01-01'
           ,'0999-123456'
           ,@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1

	--Insert Products
	DECLARE @RelType TABLE (Ptype Char(1))
	INSERT INTO @RelType VALUES ('Y')
	INSERT INTO @RelType VALUES ('M')
	INSERT INTO @RelType VALUES ('Q')
		
	DECLARE @PREMADULT as decimal(18,2)
	DECLARE @PREMCHILD as decimal(18,2)
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT DistrictID, DistrictName FROM tblDistricts
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1,@STR1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @ProductCount 
		BEGIN
			SELECT @PREMADULT = ROUND(RAND() * 10000,-3) 
			SELECT @PREMCHILD =  ROUND(RAND() * 10000,-3) 	
			INSERT INTO [dbo].[tblProduct]
           ([ProductCode]
           ,[ProductName]
           ,[DistrictID]
           ,[InsurancePeriod]
           ,[DateFrom]
           ,[DateTo]
           ,[LumpSum]
           ,[MemberCount]
           ,[PremiumAdult]
           ,[PremiumChild]
           ,[DedTreatment]
           ,[DedOPTreatment]
           ,[DedIPTreatment]
           ,[MaxTreatment]
           ,[MaxOPTreatment]
           ,[MaxIPTreatment]
           ,[DedPolicy]
           ,[DedOPPolicy]
           ,[DedIPPolicy]
           ,[MaxPolicy]
           ,[MaxOPPolicy]
           ,[MaxIPPolicy]
           ,[AuditUserID]
           ,[DedInsuree]
           ,[DedOPInsuree]
           ,[DedIPInsuree]
           ,[MaxInsuree]
           ,[MaxOPInsuree]
           ,[MaxIPInsuree]
           ,[PeriodRelPrices]
           ,[PeriodRelPricesOP]
           ,[PeriodRelPricesIP]
           ,[GracePeriod] 
           ,[AccCodePremiums]
           ,[AccCodeRemuneration])
     VALUES
           ('P-' + CAST(@ID1 as nvarchar(1000)) + '-' + CAST(@Counter1 as nvarchar(1000))
           ,'Product ' + CAST(@Counter1 as nvarchar(1000)) + ' in ' + @STR1
           ,@ID1
           ,12
           ,GETDATE()
           ,DATEADD(yy,1,GETDATE())
           ,100000 + ROUND(RAND() * 100000,-3)
           ,Cast(((8 + 1) - 4) * Rand() + 4 As tinyint)
           ,@PREMADULT
           ,@PREMCHILD
           ,ROUND(RAND() * 100000,-2)   --dedtreat
           ,ROUND(RAND() * 100000,-2)	--dedtreat-op
           ,ROUND(RAND() * 100000,-2)   --dedtreat-ip
           ,ROUND(RAND() * 10000000,-3)
           ,ROUND(RAND() * 10000000,-3)
           ,ROUND(RAND() * 10000000,-3)
           ,10 * (ROUND(RAND() * 100000,-2))
           ,10 * (ROUND(RAND() * 100000,-2))
           ,10 * (ROUND(RAND() * 100000,-2))
           ,2 * ROUND(RAND() * 10000000,-3)
           ,2 * ROUND(RAND() * 10000000,-3)
           ,2 * ROUND(RAND() * 10000000,-3)
           ,@CurrentUserID
           ,(ROUND(RAND() * 10000,-1))
           ,(ROUND(RAND() * 10000,-1))
           ,(ROUND(RAND() * 10000,-1))
           ,2 * (ROUND(RAND() * 100000,-2))
           ,2 * (ROUND(RAND() * 100000,-2))
           ,2 * (ROUND(RAND() * 100000,-2))
           ,'Y'
           ,'M'
           ,'Q'
           ,3
           ,'100-12345'
           ,'200-12345'
           )			

         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1	, @STR1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1	

	-- product services
	INSERT INTO tblProductServices ([ProdID],[ServiceID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[AuditUserID])
    SELECT     tblProduct.ProdID, tblServices.ServiceID,'F','P', tblServices.ServPrice, tblServices.ServPrice ,@CurrentUserID FROM tblProduct CROSS JOIN tblServices
	-- product items
	INSERT INTO tblProductItems ([ProdID],[ItemID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[AuditUserID])
    SELECT     tblProduct.ProdID, tblItems.ItemID,'F','P', tblItems.ItemPrice, tblItems.ItemPrice ,@CurrentUserID FROM tblProduct CROSS JOIN tblItems

	--loop through all Products and set the three relative prices relationships 	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT ProdID FROM tblProduct
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--first insert yearly distribution
		INSERT INTO [dbo].[tblRelDistr]
		   ([DistrType]
		   ,[DistrCareType]
		   ,[ProdID]
		   ,[Period]
		   ,[DistrPerc]
		   ,[AuditUserID])
		VALUES
		   (1
		   ,'B'
		   ,@ID1 
		   ,1
		   ,0.8
		   ,@CurrentUserID )
		   
		  --Secondly insert quarterly distribution
		  SET @ID2 = 1
		  WHILE @ID2 <= 4
		  BEGIN
			INSERT INTO [dbo].[tblRelDistr]
				([DistrType]
				,[DistrCareType]
				,[ProdID]
				,[Period]
				,[DistrPerc]
				,[AuditUserID])
			VALUES
				(4
				,'I'
				,@ID1 
				,@ID2
				,0.2
				,@CurrentUserID )
			SET @ID2 = @ID2 + 1
		  END
		  
		  --Thirdly insert monthly distribution
		  SET @ID2 = 1
		  WHILE @ID2 <= 12
		  BEGIN
			INSERT INTO [dbo].[tblRelDistr]
				([DistrType]
				,[DistrCareType]
				,[ProdID]
				,[Period]
				,[DistrPerc]
				,[AuditUserID])
			VALUES
				(12
				,'O'
				,@ID1 
				,@ID2
				,0.07
				,@CurrentUserID )
			SET @ID2 = @ID2 + 1
		  END
		  FETCH NEXT FROM LOOP1 INTO @ID1
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	--Policies
	
	DECLARE @PRODID as int 
	DECLARE @OFFID as int 
	DECLARE @PolicyValue as decimal(18,2)
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT FamilyID, DistrictID FROM tblFamilies
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1, @ID2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @FamPolicyCount 
		BEGIN
			SELECT top 1 @PRODID = ProdID FROM TblProduct WHERE DistrictID = @ID2 ORDER BY NewID()		
			SELECT top 1 @OFFID = OfficerID FROM TblOfficer WHERE DistrictID = @ID2 ORDER BY NewID()		
			SELECT @PolicyValue = LumpSum FROM TblProduct WHERE ProdID = @PRODID 
			INSERT INTO tblPolicy ([FamilyID],[EnrollDate],[StartDate],[EffectiveDate],[ExpiryDate],[PolicyStatus],[PolicyValue],[ProdID],[OfficerID],[AuditUserID])
			VALUES
           (@ID1
           ,DATEADD(dd,-(ROUND( Cast(((400 + 1) - 10) * Rand() + 10 As int) ,0)),GETDATE())
           ,DATEADD(dd,-(ROUND( Cast(((400 + 1) - 10) * Rand() + 10 As int) ,0)),GETDATE())
           ,DATEADD(dd,-(ROUND( Cast(((400 + 1) - 10) * Rand() + 10 As int) ,0)),GETDATE())
           ,DATEADD(yy,1,DATEADD(dd,-(ROUND( Cast(((400 + 1) - 10) * Rand() + 10 As int) ,0)),GETDATE()))
           ,2
           ,@PolicyValue
           ,@PRODID
           ,@OFFID
           ,@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1, @ID2
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	--Premiums
	DECLARE @POLICYID as int 
	DECLARE @FAMILYID as int 
	--DECLARE @DISTRICTID as int
	DECLARE @PRODUCTID as int 
	DECLARE @PAYERID as int
	DECLARE @AMOUNT as decimal(18,2)
	DECLARE @PAYDATE as datetime
	DECLARE @RECEIPT as int
	DECLARE @PayType TABLE (Pay Char(1))
	INSERT INTO @PayType VALUES ('C')
	INSERT INTO @PayType VALUES ('B')
	INSERT INTO @PayType VALUES ('M')
	DECLARE @InsPayType as char(1)

	SET @Counter1 = 0
	SET @RECEIPT = 1
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT PolicyID, FamilyID , ProdID, StartDate FROM tblPolicy ORDER BY StartDate
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @POLICYID, @FAMILYID, @PRODUCTID ,@PAYDATE
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		
		IF @Counter1 = @SplitPremium1inX AND @SplitPremium1inX > 1 
		BEGIN
			SELECT @DISTRICTID = DistrictID FROM tblFamilies Where FamilyID = @FAMILYID
			SELECT top 1 @PAYERID = PayerID FROM TblPayer WHERE DistrictID = @DISTRICTID ORDER BY NewID()
			SELECT @AMOUNT = (LumpSum/2) From tblProduct Where ProdID = @PRODUCTID
			SELECT top 1 @InsPayType = pay FROM @PayType ORDER BY NewID()
			
			INSERT INTO tblPremium([PolicyID],[PayerID],[Amount],[Receipt],[PayDate],[PayType],[AuditUserID])
			VALUES 
           (@POLICYID
           ,@PAYERID
           ,@AMOUNT
           ,@RECEIPT
           ,@PAYDATE
           ,@InsPayType
           ,@CurrentUserID)

		   SET @RECEIPT = @RECEIPT + 1

		   SELECT top 1 @InsPayType = pay FROM @PayType ORDER BY NewID()	
		   INSERT INTO tblPremium([PolicyID],[Amount],[Receipt],[PayDate],[PayType],[AuditUserID])
			VALUES 
           (@POLICYID
           ,@AMOUNT
           ,@RECEIPT
           ,@PAYDATE
           ,@InsPayType
           ,@CurrentUserID)	

			SET @RECEIPT = @RECEIPT + 1
			SET @Counter1 = 0
		
		END
		ELSE
		BEGIN
			SELECT top 1 @InsPayType = pay FROM @PayType ORDER BY NewID()	
			SELECT @AMOUNT = (LumpSum) From tblProduct Where ProdID = @PRODUCTID
			INSERT INTO tblPremium([PolicyID],[Amount],[Receipt],[PayDate],[PayType],[AuditUserID])
			VALUES 
           (@POLICYID
           ,@AMOUNT
           ,@RECEIPT
           ,@PAYDATE
           ,@InsPayType
           ,@CurrentUserID)	
			SET @RECEIPT = @RECEIPT + 1
			SET @Counter1 = @Counter1 + 1
		END

					
		FETCH NEXT FROM LOOP1 INTO @POLICYID, @FAMILYID, @PRODUCTID, @PAYDATE
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	

END
GO
