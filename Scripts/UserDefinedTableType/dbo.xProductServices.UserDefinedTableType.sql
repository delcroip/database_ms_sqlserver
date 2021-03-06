/****** Object:  UserDefinedTableType [dbo].[xProductServices]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xProductServices] AS TABLE(
	[ProdServiceID] [int] NOT NULL,
	[ProdID] [int] NOT NULL,
	[ServiceID] [int] NOT NULL,
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
	[ProdServiceID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
