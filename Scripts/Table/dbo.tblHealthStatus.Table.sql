/****** Object:  Table [dbo].[tblHealthStatus]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHealthStatus](
	[HealthStatusID] [int] IDENTITY(1,1) NOT NULL,
	[InsureeID] [int] NOT NULL,
	[Description] [nvarchar](255) NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[AuditUserID] [int] NULL,
	[LegacyID] [int] NULL,
 CONSTRAINT [PK_tblHealthStatus] PRIMARY KEY CLUSTERED 
(
	[HealthStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHealthStatus] ADD  CONSTRAINT [DF_tblHealthStatus_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblHealthStatus]  WITH CHECK ADD  CONSTRAINT [FK_tblHealthStatus_tblInsuree] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblHealthStatus] CHECK CONSTRAINT [FK_tblHealthStatus_tblInsuree]
GO
