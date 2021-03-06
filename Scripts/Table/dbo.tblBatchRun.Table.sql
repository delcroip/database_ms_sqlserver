/****** Object:  Table [dbo].[tblBatchRun]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBatchRun](
	[RunID] [int] IDENTITY(1,1) NOT NULL,
	[LocationId] [int] NULL,
	[RunDate] [datetime] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RunYear] [int] NOT NULL,
	[RunMonth] [tinyint] NOT NULL,
 CONSTRAINT [PK_tblMonthlyRuns] PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBatchRun] ADD  CONSTRAINT [DF_tblBatchRun_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblBatchRun]  WITH CHECK ADD  CONSTRAINT [FK_tblBatchRun_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblBatchRun] CHECK CONSTRAINT [FK_tblBatchRun_tblLocations]
GO
