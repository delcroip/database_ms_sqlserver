/****** Object:  UserDefinedTableType [dbo].[xRelDistr]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xRelDistr] AS TABLE(
	[DistrID] [int] NOT NULL,
	[DistrType] [tinyint] NOT NULL,
	[DistrCareType] [char](1) NOT NULL,
	[ProdID] [int] NOT NULL,
	[Period] [tinyint] NOT NULL,
	[DistrPerc] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[DistrID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
