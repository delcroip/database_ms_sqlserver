/****** Object:  Table [dbo].[tblProductServices]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductServices](
	[ProdServiceID] [int] IDENTITY(1,1) NOT NULL,
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
	[RowID] [timestamp] NULL,
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
 CONSTRAINT [PK_tblProductServices] PRIMARY KEY CLUSTERED 
(
	[ProdServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProductServices] ADD  CONSTRAINT [DF_tblProductServices_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblProductServices]  WITH CHECK ADD  CONSTRAINT [FK_tblProductServices_tblProduct-ProductID] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblProductServices] CHECK CONSTRAINT [FK_tblProductServices_tblProduct-ProductID]
GO
ALTER TABLE [dbo].[tblProductServices]  WITH CHECK ADD  CONSTRAINT [FK_tblProductServices_tblServices-ServiceID] FOREIGN KEY([ServiceID])
REFERENCES [dbo].[tblServices] ([ServiceID])
GO
ALTER TABLE [dbo].[tblProductServices] CHECK CONSTRAINT [FK_tblProductServices_tblServices-ServiceID]
GO
