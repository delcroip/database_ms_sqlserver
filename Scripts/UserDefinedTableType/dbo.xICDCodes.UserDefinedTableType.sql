/****** Object:  UserDefinedTableType [dbo].[xICDCodes]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xICDCodes] AS TABLE(
	[ICDID] [int] NOT NULL,
	[ICDCode] [nvarchar](6) NOT NULL,
	[ICDName] [nvarchar](255) NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[ICDID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
