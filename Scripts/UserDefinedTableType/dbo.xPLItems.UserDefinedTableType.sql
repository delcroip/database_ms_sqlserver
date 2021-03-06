/****** Object:  UserDefinedTableType [dbo].[xPLItems]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xPLItems] AS TABLE(
	[PLItemID] [int] NOT NULL,
	[PLItemName] [nvarchar](100) NOT NULL,
	[DatePL] [date] NOT NULL,
	[LocationId] [int] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[PLItemID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
