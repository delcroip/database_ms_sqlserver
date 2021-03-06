/****** Object:  Table [dbo].[tblPayer]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPayer](
	[PayerID] [int] IDENTITY(1,1) NOT NULL,
	[PayerType] [char](1) NOT NULL,
	[PayerName] [nvarchar](100) NOT NULL,
	[PayerAddress] [nvarchar](100) NULL,
	[LocationId] [int] NULL,
	[Phone] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[eMail] [nvarchar](50) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblPayer] PRIMARY KEY CLUSTERED 
(
	[PayerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPayer] ADD  CONSTRAINT [DF_tblPayer_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPayer]  WITH CHECK ADD  CONSTRAINT [FK_tblPayer_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblPayer] CHECK CONSTRAINT [FK_tblPayer_tblLocations]
GO
ALTER TABLE [dbo].[tblPayer]  WITH CHECK ADD  CONSTRAINT [FK_tblPayer_tblPayerType] FOREIGN KEY([PayerType])
REFERENCES [dbo].[tblPayerType] ([Code])
GO
ALTER TABLE [dbo].[tblPayer] CHECK CONSTRAINT [FK_tblPayer_tblPayerType]
GO
