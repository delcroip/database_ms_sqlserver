/****** Object:  UserDefinedTableType [dbo].[xWards]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xWards] AS TABLE(
	[WardID] [int] NOT NULL,
	[DistrictID] [int] NOT NULL,
	[WardName] [nvarchar](50) NOT NULL,
	[WardCode] [nvarchar](8) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[WardID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
