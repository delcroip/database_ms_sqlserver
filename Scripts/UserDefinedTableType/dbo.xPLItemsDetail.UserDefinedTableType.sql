/****** Object:  UserDefinedTableType [dbo].[xPLItemsDetail]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xPLItemsDetail] AS TABLE(
	[PLItemDetailID] [int] NOT NULL,
	[PLItemID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[PriceOverule] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[PLItemDetailID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
