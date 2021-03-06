/****** Object:  Table [dbo].[tblClaimItems]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClaimItems](
	[ClaimItemID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[ProdID] [int] NULL,
	[ClaimItemStatus] [tinyint] NOT NULL,
	[Availability] [bit] NOT NULL,
	[QtyProvided] [decimal](18, 2) NOT NULL,
	[QtyApproved] [decimal](18, 2) NULL,
	[PriceAsked] [decimal](18, 2) NOT NULL,
	[PriceAdjusted] [decimal](18, 2) NULL,
	[PriceApproved] [decimal](18, 2) NULL,
	[PriceValuated] [decimal](18, 2) NULL,
	[Explanation] [ntext] NULL,
	[Justification] [ntext] NULL,
	[RejectionReason] [smallint] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[ValidityFromReview] [datetime] NULL,
	[ValidityToReview] [datetime] NULL,
	[AuditUserIDReview] [int] NULL,
	[LimitationValue] [decimal](18, 2) NULL,
	[Limitation] [char](1) NULL,
	[PolicyID] [int] NULL,
	[RemuneratedAmount] [decimal](18, 2) NULL,
	[DeductableAmount] [decimal](18, 2) NULL,
	[ExceedCeilingAmount] [decimal](18, 2) NULL,
	[PriceOrigin] [char](1) NULL,
	[ExceedCeilingAmountCategory] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblClaimItems] PRIMARY KEY CLUSTERED 
(
	[ClaimItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimItems] ADD  CONSTRAINT [DF_tblClaimItems_ClaimItemStatus]  DEFAULT ((1)) FOR [ClaimItemStatus]
GO
ALTER TABLE [dbo].[tblClaimItems] ADD  CONSTRAINT [DF_tblClaimItems_Availability]  DEFAULT ((1)) FOR [Availability]
GO
ALTER TABLE [dbo].[tblClaimItems] ADD  CONSTRAINT [DF_tblClaimItems_RejectionReason]  DEFAULT ((0)) FOR [RejectionReason]
GO
ALTER TABLE [dbo].[tblClaimItems] ADD  CONSTRAINT [DF_tblClaimItems_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblClaimItems]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimItems_tblClaim-ClaimID] FOREIGN KEY([ClaimID])
REFERENCES [dbo].[tblClaim] ([ClaimID])
GO
ALTER TABLE [dbo].[tblClaimItems] CHECK CONSTRAINT [FK_tblClaimItems_tblClaim-ClaimID]
GO
ALTER TABLE [dbo].[tblClaimItems]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimItems_tblItems-ItemID] FOREIGN KEY([ItemID])
REFERENCES [dbo].[tblItems] ([ItemID])
GO
ALTER TABLE [dbo].[tblClaimItems] CHECK CONSTRAINT [FK_tblClaimItems_tblItems-ItemID]
GO
ALTER TABLE [dbo].[tblClaimItems]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimItems_tblProduct-ProdID] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblClaimItems] CHECK CONSTRAINT [FK_tblClaimItems_tblProduct-ProdID]
GO
