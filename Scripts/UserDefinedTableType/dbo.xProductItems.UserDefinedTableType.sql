/****** Object:  UserDefinedTableType [dbo].[xProductItems]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xProductItems] AS TABLE(
	[ProdItemID] [int] NOT NULL,
	[ProdID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[LimitationType] [char](1) NOT NULL,
	[PriceOrigin] [char](1) NOT NULL,
	[LimitAdult] [decimal](18, 2) NULL,
	[LimitChild] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[WaitingPeriodAdult] [int] NULL,
	[WaitingPeriodChild] [int] NULL,
	[LimitNoAdult] [int] NULL,
	[LimitNoChild] [int] NULL,
	[LimitationTypeR] [char](1) NULL,
	[LimitationTypeE] [char](1) NULL,
	[LimitAdultR] [decimal](18, 2) NULL,
	[LimitAdultE] [decimal](18, 2) NULL,
	[LimitChildR] [decimal](18, 2) NULL,
	[LimitChildE] [decimal](18, 2) NULL,
	[CeilingExclusionAdult] [nvarchar](1) NULL,
	[CeilingExclusionChild] [nvarchar](1) NULL,
	PRIMARY KEY CLUSTERED 
(
	[ProdItemID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
