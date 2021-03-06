/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract1]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspExportOffLineExtract1]
	
	@RowID as bigint = 0
AS
BEGIN
	SET NOCOUNT ON

	SELECT LocationId, LocationCode, LocationName, ParentLocationId, LocationType, ValidityFrom, ValidityTo, LegacyId, AuditUserId 
	FROM tblLocations
	WHERE RowID > @RowID;

	
END
GO
