/****** Object:  UserDefinedTableType [dbo].[xClaimProcess]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xClaimProcess] AS TABLE(
	[ClaimID] [int] NOT NULL,
	[RowID] [bigint] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[ClaimID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
