/****** Object:  UserDefinedTableType [dbo].[xHFCatchment]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xHFCatchment] AS TABLE(
	[HFCatchmentId] [int] NULL,
	[HFID] [int] NULL,
	[LocationId] [int] NULL,
	[Catchment] [int] NULL
)
GO
