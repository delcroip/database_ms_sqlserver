/****** Object:  Table [dbo].[tblPLServicesDetail]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPLServicesDetail](
	[PLServiceDetailID] [int] IDENTITY(1,1) NOT NULL,
	[PLServiceID] [int] NOT NULL,
	[ServiceID] [int] NOT NULL,
	[PriceOverule] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblPLServiceDetail] PRIMARY KEY CLUSTERED 
(
	[PLServiceDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPLServicesDetail] ADD  CONSTRAINT [DF_tblPLServicesDetail_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPLServicesDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblPLServicesDetail_tblPLServices-PLServiceID] FOREIGN KEY([PLServiceID])
REFERENCES [dbo].[tblPLServices] ([PLServiceID])
GO
ALTER TABLE [dbo].[tblPLServicesDetail] CHECK CONSTRAINT [FK_tblPLServicesDetail_tblPLServices-PLServiceID]
GO
ALTER TABLE [dbo].[tblPLServicesDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblPLServicesDetail_tblServices-ServiceID] FOREIGN KEY([ServiceID])
REFERENCES [dbo].[tblServices] ([ServiceID])
GO
ALTER TABLE [dbo].[tblPLServicesDetail] CHECK CONSTRAINT [FK_tblPLServicesDetail_tblServices-ServiceID]
GO
