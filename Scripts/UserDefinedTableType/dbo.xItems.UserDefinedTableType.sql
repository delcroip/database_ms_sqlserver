/****** Object:  UserDefinedTableType [dbo].[xItems]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xItems] AS TABLE(
	[ItemID] [int] NOT NULL,
	[ItemCode] [nvarchar](6) NOT NULL,
	[ItemName] [nvarchar](100) NOT NULL,
	[ItemType] [char](1) NOT NULL,
	[ItemPackage] [nvarchar](255) NULL,
	[ItemPrice] [decimal](18, 2) NOT NULL,
	[ItemCareType] [char](1) NOT NULL,
	[ItemFrequency] [smallint] NULL,
	[ItemPatCat] [tinyint] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
