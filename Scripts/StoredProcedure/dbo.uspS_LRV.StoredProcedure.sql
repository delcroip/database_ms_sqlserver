/****** Object:  StoredProcedure [dbo].[uspS_LRV]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspS_LRV]

	(
		
		@LRV bigint OUTPUT
	)

AS
		
	set @LRV = @@DBTS 
	RETURN 




GO
