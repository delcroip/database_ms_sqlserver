/****** Object:  Table [dbo].[tblFeedback]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeedback](
	[FeedbackID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimID] [int] NOT NULL,
	[CareRendered] [bit] NULL,
	[PaymentAsked] [bit] NULL,
	[DrugPrescribed] [bit] NULL,
	[DrugReceived] [bit] NULL,
	[Asessment] [tinyint] NULL,
	[CHFOfficerCode] [int] NULL,
	[FeedbackDate] [datetime] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
 CONSTRAINT [PK_tblFeedback] PRIMARY KEY CLUSTERED 
(
	[FeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFeedback] ADD  CONSTRAINT [DF_tblFeedback_CareRendered]  DEFAULT ((0)) FOR [CareRendered]
GO
ALTER TABLE [dbo].[tblFeedback] ADD  CONSTRAINT [DF_tblFeedback_PaymentAsked]  DEFAULT ((0)) FOR [PaymentAsked]
GO
ALTER TABLE [dbo].[tblFeedback] ADD  CONSTRAINT [DF_tblFeedback_DrugPrescribed]  DEFAULT ((0)) FOR [DrugPrescribed]
GO
ALTER TABLE [dbo].[tblFeedback] ADD  CONSTRAINT [DF_tblFeedback_DrugReceived]  DEFAULT ((0)) FOR [DrugReceived]
GO
ALTER TABLE [dbo].[tblFeedback] ADD  CONSTRAINT [DF_tblFeedback_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblFeedback]  WITH CHECK ADD  CONSTRAINT [FK_tblFeedback_tblClaim-ClaimID] FOREIGN KEY([ClaimID])
REFERENCES [dbo].[tblClaim] ([ClaimID])
GO
ALTER TABLE [dbo].[tblFeedback] CHECK CONSTRAINT [FK_tblFeedback_tblClaim-ClaimID]
GO
