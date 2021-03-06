/****** Object:  StoredProcedure [dbo].[uspImportOffLineExtract2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspImportOffLineExtract2]
	
	@HFID as int = 0,
	@LocationId INT = 0,
	@AuditUser as int = 0 ,
	@xtItems dbo.xItems READONLY,
	@xtServices dbo.xServices READONLY,
	@xtPLItems dbo.xPLItems READONLY,
	@xtPLItemsDetail dbo.xPLItemsDetail READONLY,
	@xtPLServices dbo.xPLServices READONLY,
	@xtPLServicesDetail dbo.xPLServicesDetail READONLY,
	@ItemsIns as bigint = 0 OUTPUT  ,
	@ItemsUpd as bigint = 0 OUTPUT  ,
	@ServicesIns as bigint = 0 OUTPUT  ,
	@ServicesUpd as bigint  = 0 OUTPUT  ,
	@PLItemsIns as bigint = 0 OUTPUT  ,
	@PLItemsUpd as bigint  = 0 OUTPUT,
	@PLItemsDetailIns as bigint = 0 OUTPUT  ,
	@PLItemsDetailUpd as bigint  = 0 OUTPUT , 
	@PLServicesIns as bigint = 0 OUTPUT  ,
	@PLServicesUpd as bigint  = 0 OUTPUT,
	@PLServicesDetailIns as bigint = 0 OUTPUT  ,
	@PLServicesDetailUpd as bigint  = 0 OUTPUT
	
	
AS
BEGIN
	
	--**S Items**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.ItemCode = Etr.ItemCode ,Src.ItemName = Etr.ItemName ,Src.ItemType = Etr.ItemType , Src.ItemPackage = Etr.ItemPackage , Src.ItemPrice = Etr.ItemPrice , Src.ItemCareType = Etr.ItemCareType, Src.ItemFrequency = Etr.ItemFrequency, Src.[ItemPatCat] = Etr.ItemPatCat,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser  FROM tblItems  Src , @xtItems  Etr WHERE Src.ItemID  = Etr.ItemID   
	SET @ItemsUpd  = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblItems] ON
	
	INSERT INTO dbo.tblItems ([ItemID],[ItemCode],[ItemName],[ItemType],[ItemPackage],[ItemPrice],[ItemCareType],[ItemFrequency],[ItemPatCat],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID]) 
	SELECT [ItemID],[ItemCode],[ItemName],[ItemType],[ItemPackage],[ItemPrice],[ItemCareType],[ItemFrequency],[ItemPatCat],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtItems WHERE [ItemID] NOT IN 
	(SELECT ItemID FROM tblItems)
	
	SET @ItemsIns  = @@ROWCOUNT
	SET IDENTITY_INSERT [tblItems] OFF
	SET NOCOUNT ON
	--**E Items**
	
	--**S Services**
	SET NOCOUNT OFF
	UPDATE Src SET Src.[ServCode] = Etr.[ServCode], Src.[ServName] = Etr.[ServName] ,Src.[ServType] = Etr.[ServType] ,Src.ServLevel = Etr.ServLevel ,Src.ServPrice = Etr.ServPrice, Src.ServCareType = Etr.ServCareType ,Src.ServFrequency = Etr.ServFrequency, Src.ServPatCat = Etr.ServPatCat , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser FROM tblServices Src , @xtServices Etr WHERE Src.ServiceID  = Etr.ServiceID 
	SET @ServicesUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblServices] ON
	INSERT INTO dbo.tblServices ([ServiceID],[ServCode],[ServName],[ServType],[ServLevel],[ServPrice],[ServCareType],[ServFrequency],[ServPatCat],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID]) 
	SELECT [ServiceID],[ServCode],[ServName],[ServType],[ServLevel],[ServPrice],[ServCareType],[ServFrequency],[ServPatCat],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtServices  WHERE [ServiceID]  NOT IN 
	(Select ServiceID from tblServices)
	
	SET @ServicesIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblServices] OFF
	SET NOCOUNT ON
	--**E Services**
	
	--**S PLItems**
	SET NOCOUNT OFF
	UPDATE Src SET Src.PLItemName = Etr.PLItemName ,Src.DatePL = Etr.DatePL ,Src.LocationId = Etr.LocationId , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser FROM tblPLItems Src , @xtPLItems Etr WHERE Src.PLItemID  = Etr.PLItemID 
	SET @PLItemsUpd  = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblPLItems] ON
	INSERT INTO dbo.tblPLItems ([PLItemID],[PLItemName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID])
	SELECT [PLItemID],[PLItemName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtPLItems WHERE [PLItemID] NOT IN 
	(SELECT PLItemID FROM tblPLItems)
	--AND (LocationId = @LocationId OR @LocationId = 0)
	
	SET @PLItemsIns  = @@ROWCOUNT
	SET IDENTITY_INSERT [tblPLItems] OFF
	SET NOCOUNT ON
	--**E PLItems**
	
	--**S PLItemsDetail**
	SET NOCOUNT OFF
	UPDATE Src SET Src.PLItemID = Etr.PLItemID, Src.ItemID = Etr.ItemID, Src.PriceOverule = Etr.PriceOverule ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser FROM tblPLItemsDetail Src , @xtPLItemsDetail  Etr WHERE Src.PLItemDetailID   = Etr.PLItemDetailID  
	SET @PLItemsDetailUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblPLItemsDetail] ON
	INSERT INTO [tblPLItemsDetail] ([PLItemDetailID],[PLItemID],[ItemID],[PriceOverule],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID]) 
	SELECT [PLItemDetailID],[PLItemID],[ItemID],[PriceOverule],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser 
	FROM @xtPLItemsDetail 
	WHERE [PLItemDetailID] NOT IN 
	(SELECT PLItemDetailID  FROM tblPLItemsDetail )
	AND PLItemID IN (SELECT PLItemID FROM tblPLItems)
	
	SET @PLItemsDetailIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblPLItemsDetail] OFF
	SET NOCOUNT ON
	--**E PLItemsDetail**
	
		
	--**S PLServices**
	SET NOCOUNT OFF
	UPDATE Src SET Src.PLServName = Etr.PLServName ,Src.DatePL = Etr.DatePL ,Src.LocationId = Etr.LocationId , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser FROM tblPLServices Src , @xtPLServices Etr WHERE Src.PLServiceID  = Etr.PLServiceID 
	SET @PLServicesUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblPLServices] ON
	INSERT INTO dbo.tblPLServices ([PLServiceID],[PLServName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID])
	SELECT [PLServiceID],[PLServName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtPLServices  WHERE [PLServiceID] NOT IN 
	(SELECT PLServiceID FROM tblPLServices)
	--AND (LocationId = @LocationId OR @LocationId = 0)
	
	SET @PLServicesIns  = @@ROWCOUNT
	SET IDENTITY_INSERT [tblPLServices] OFF
	SET NOCOUNT ON
	--**E PLServices**
	
	--**S PLServicesDetail**
	SET NOCOUNT OFF
	UPDATE Src SET Src.PLServiceID = Etr.PLServiceID, Src.ServiceID = Etr.ServiceID, Src.PriceOverule = Etr.PriceOverule ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser FROM tblPLServicesDetail Src , @xtPLServicesDetail  Etr WHERE Src.PLServiceDetailID   = Etr.PLServiceDetailID  
	SET @PLServicesDetailUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblPLServicesDetail] ON
	INSERT INTO [tblPLServicesDetail] ([PLServiceDetailID],[dbo].[tblPLServicesDetail].[PLServiceID],[ServiceID],[PriceOverule],[dbo].[tblPLServicesDetail].[ValidityFrom],[dbo].[tblPLServicesDetail].[ValidityTo],[dbo].[tblPLServicesDetail].[LegacyID],[dbo].[tblPLServicesDetail].[AuditUserID]) 
	SELECT [PLServiceDetailID],[PLServiceID],[ServiceID],[PriceOverule],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtPLServicesDetail WHERE [PLServiceDetailID] NOT IN 
	(SELECT PLServiceDetailID  FROM tblPLServicesDetail )
	AND PLServiceID IN (SELECT PLServiceID FROM tblPLServices)
		
	SET @PLServicesDetailIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblPLServicesDetail] OFF
	SET NOCOUNT ON
	--**E PLServicesDetail**
			
END
GO
