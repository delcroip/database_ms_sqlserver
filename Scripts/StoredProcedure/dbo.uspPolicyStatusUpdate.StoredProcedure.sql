/****** Object:  StoredProcedure [dbo].[uspPolicyStatusUpdate]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspPolicyStatusUpdate]
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @PolicyID as int 
	
	UPDATE tblPolicy SET PolicyStatus = 8 WHERE ValidityTo IS NULL AND ExpiryDate < CAST (GETDATE() as DATE)
    
END
GO
