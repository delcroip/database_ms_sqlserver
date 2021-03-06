/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspExportOffLineExtract2]
	
	@LocationId as int,
	@RowID as bigint = 0
	
AS
BEGIN
	SET NOCOUNT ON
	
	--**S Items**
	SELECT [ItemID],[ItemCode],[ItemName],[ItemType],[ItemPackage],[ItemPrice],[ItemCareType],[ItemFrequency],[ItemPatCat],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblItems] WHERE RowID > @RowID
	
	--**S Services**
	SELECT [ServiceID],[ServCode],[ServName],[ServType],[ServLevel],[ServPrice],[ServCareType],[ServFrequency],[ServPatCat],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],ServCategory FROM [dbo].[tblServices] WHERE RowID > @RowID
	
	--**S PLItems**
	SELECT [PLItemID],[PLItemName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblPLItems] WHERE RowID > @RowID --AND (( (CASE @DistrictID  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @DistrictID) OR (DistrictID IS NULL))
	
	--**S PLItemsDetails**
	SELECT [PLItemDetailID],[dbo].[tblPLItemsDetail].[PLItemID],[ItemID],[PriceOverule],[dbo].[tblPLItemsDetail].[ValidityFrom],[dbo].[tblPLItemsDetail].[ValidityTo],[dbo].[tblPLItemsDetail].[LegacyID],[dbo].[tblPLItemsDetail].[AuditUserID] FROM [dbo].[tblPLItemsDetail] INNER JOIN [dbo].[tblPLItems] ON [dbo].[tblPLItems].PLItemID = [dbo].[tblPLItemsDetail].PLItemID WHERE [dbo].[tblPLItemsDetail].RowID > @RowID --AND (( (CASE @DistrictID  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @DistrictID) OR (DistrictID IS NULL))
		
	--**S PLServices**
	SELECT [PLServiceID],[PLServName],[DatePL],[LocationId],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblPLServices] WHERE RowID > @RowID --AND (( (CASE @DistrictID  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @DistrictID) OR (DistrictID IS NULL))
	
	--**S PLServicesDetails**
	SELECT [PLServiceDetailID],[dbo].[tblPLServicesDetail].[PLServiceID],[ServiceID],[PriceOverule],[dbo].[tblPLServicesDetail].[ValidityFrom],[dbo].[tblPLServicesDetail].[ValidityTo],[dbo].[tblPLServicesDetail].[LegacyID],[dbo].[tblPLServicesDetail].[AuditUserID] FROM [dbo].[tblPLServicesDetail] INNER JOIN [dbo].[tblPLServices] ON [dbo].[tblPLServicesDetail].PLServiceID = [dbo].[tblPLServices].PLServiceID  WHERE [dbo].[tblPLServicesDetail].RowID > @RowID --AND (( (CASE @DistrictID  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @DistrictID) OR (DistrictID IS NULL))
				
END
GO
