/****** Object:  Table [dbo].[tblHFCatchment]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHFCatchment](
	[HFCatchmentId] [int] IDENTITY(1,1) NOT NULL,
	[HFID] [int] NOT NULL,
	[LocationId] [int] NOT NULL,
	[Catchment] [int] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
 CONSTRAINT [PK_tblHFCatchment] PRIMARY KEY CLUSTERED 
(
	[HFCatchmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHFCatchment] ADD  CONSTRAINT [DF_tblHFCatchment_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblHFCatchment]  WITH CHECK ADD  CONSTRAINT [FK_tblHFCatchment_tbLHF] FOREIGN KEY([HFID])
REFERENCES [dbo].[tblHF] ([HfID])
GO
ALTER TABLE [dbo].[tblHFCatchment] CHECK CONSTRAINT [FK_tblHFCatchment_tbLHF]
GO
ALTER TABLE [dbo].[tblHFCatchment]  WITH CHECK ADD  CONSTRAINT [FK_tblHFCatchment_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblHFCatchment] CHECK CONSTRAINT [FK_tblHFCatchment_tblLocations]
GO
