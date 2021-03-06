/****** Object:  UserDefinedTableType [dbo].[xRegions]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xRegions] AS TABLE(
	[RegionId] [int] NOT NULL,
	[RegionName] [nvarchar](50) NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[RegionCode] [nvarchar](8) NULL,
	PRIMARY KEY CLUSTERED 
(
	[RegionId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
