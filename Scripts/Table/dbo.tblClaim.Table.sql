/****** Object:  Table [dbo].[tblClaim]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClaim](
	[ClaimID] [int] IDENTITY(1,1) NOT NULL,
	[InsureeID] [int] NOT NULL,
	[ClaimCode] [nvarchar](8) NOT NULL,
	[DateFrom] [smalldatetime] NOT NULL,
	[DateTo] [smalldatetime] NULL,
	[ICDID] [int] NOT NULL,
	[ClaimStatus] [tinyint] NOT NULL,
	[Adjuster] [int] NULL,
	[Adjustment] [ntext] NULL,
	[Claimed] [decimal](18, 2) NULL,
	[Approved] [decimal](18, 2) NULL,
	[Reinsured] [decimal](18, 2) NULL,
	[Valuated] [decimal](18, 2) NULL,
	[DateClaimed] [date] NOT NULL,
	[DateProcessed] [smalldatetime] NULL,
	[Feedback] [bit] NOT NULL,
	[FeedbackID] [int] NULL,
	[Explanation] [ntext] NULL,
	[FeedbackStatus] [tinyint] NULL,
	[ReviewStatus] [tinyint] NULL,
	[ApprovalStatus] [tinyint] NULL,
	[RejectionReason] [tinyint] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[ValidityFromReview] [datetime] NULL,
	[ValidityToReview] [datetime] NULL,
	[AuditUserIDReview] [int] NULL,
	[RowID] [timestamp] NULL,
	[HFID] [int] NOT NULL,
	[RunID] [int] NULL,
	[AuditUserIDSubmit] [int] NULL,
	[AuditUserIDProcess] [int] NULL,
	[SubmitStamp] [datetime] NULL,
	[ProcessStamp] [datetime] NULL,
	[Remunerated] [decimal](18, 2) NULL,
	[GuaranteeId] [nvarchar](50) NULL,
	[ClaimAdminId] [int] NULL,
	[ICDID1] [int] NULL,
	[ICDID2] [int] NULL,
	[ICDID3] [int] NULL,
	[ICDID4] [int] NULL,
	[VisitType] [char](1) NULL,
	[ClaimCategory] [char](1) NULL,
 CONSTRAINT [PK_tblClaim] PRIMARY KEY CLUSTERED 
(
	[ClaimID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_ClaimStatus]  DEFAULT ((2)) FOR [ClaimStatus]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_DateClaimed]  DEFAULT (getdate()) FOR [DateClaimed]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_Feedback]  DEFAULT ((0)) FOR [Feedback]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_FeedbackID]  DEFAULT ((0)) FOR [FeedbackID]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_FeedbackStatus]  DEFAULT ((1)) FOR [FeedbackStatus]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_ReviewStatus]  DEFAULT ((1)) FOR [ReviewStatus]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_ApprovalStatus]  DEFAULT ((1)) FOR [ApprovalStatus]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_RejectionReason]  DEFAULT ((0)) FOR [RejectionReason]
GO
ALTER TABLE [dbo].[tblClaim] ADD  CONSTRAINT [DF_tblClaim_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblBatchRun] FOREIGN KEY([RunID])
REFERENCES [dbo].[tblBatchRun] ([RunID])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblBatchRun]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblClaimAdmin] FOREIGN KEY([ClaimAdminId])
REFERENCES [dbo].[tblClaimAdmin] ([ClaimAdminId])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblClaimAdmin]
GO
ALTER TABLE [dbo].[tblClaim]  WITH NOCHECK ADD  CONSTRAINT [FK_tblClaim_tblFeedback-FeedbackID] FOREIGN KEY([FeedbackID])
REFERENCES [dbo].[tblFeedback] ([FeedbackID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[tblClaim] NOCHECK CONSTRAINT [FK_tblClaim_tblFeedback-FeedbackID]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblHF] FOREIGN KEY([HFID])
REFERENCES [dbo].[tblHF] ([HfID])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblHF]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblICDCodes-ICDID] FOREIGN KEY([ICDID])
REFERENCES [dbo].[tblICDCodes] ([ICDID])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblICDCodes-ICDID]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblInsuree-InsureeID] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblInsuree-InsureeID]
GO
ALTER TABLE [dbo].[tblClaim]  WITH CHECK ADD  CONSTRAINT [FK_tblClaim_tblUsers] FOREIGN KEY([Adjuster])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblClaim] CHECK CONSTRAINT [FK_tblClaim_tblUsers]
GO
