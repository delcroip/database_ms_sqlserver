/****** Object:  StoredProcedure [dbo].[uspMoveLocation]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspMoveLocation](
	@SourceId INT,
	@DestinationId INT,
	@LocationType CHAR(1),		--'D' : District, 'W' : Ward, 'V' : Village
	@AuditUserId INT,
	@ErrorMessage INT = 0 OUTPUT
)
AS	
BEGIN
	BEGIN TRY
	    SET @ErrorMessage=-1;
		DECLARE @DistrictId INT,
				@WardId INT, 
				@Region INT

		BEGIN TRAN LOC
			--Check if the @LocationType parameter is right
				IF @LocationType  NOT IN ('D', 'W', 'V')
				BEGIN
					SET @ErrorMessage=1;
					RAISERROR(N'Invalid Location Type', 16, 1);
				END
			
			--Check if the destination is already a parent
			IF EXISTS(SELECT 1 FROM tblLocations WHERE LocationId = @SourceId AND ParentLocationId = @DestinationId AND ValidityTo IS NULL)
			BEGIN
				SET @ErrorMessage=2;
				RAISERROR('Source location already belongs to the Destination Location', 16, 1);
			END

			--Make a copy of an existing record
			INSERT INTO tblLocations(LocationCode, LocationName, ParentLocationId, LocationType, ValidityFrom, ValidityTo, LegacyId, AuditUserId,MalePopulation,FemalePopulation,OtherPopulation,Families)
			SELECT LocationCode, Locationname, ParentLocationId, LocationType, ValidityFrom, GETDATE() ValidityTo, LocationId, AuditUserId ,MalePopulation,FemalePopulation,OtherPopulation,Families
			FROM tblLocations
			WHERE LocationId = @SourceId;


			--Update the location
			UPDATE tblLocations SET ParentLocationId = @DestinationId
			WHERE LocationId = @SourceId;
			
			SET @ErrorMessage=0;
		
		COMMIT TRAN LOC;
	END TRY
	BEGIN CATCH
		SELECT   ERROR_MESSAGE();

		SET @ErrorMessage = 99;
		IF @@TRANCOUNT  > 0 ROLLBACK TRAN LOC;
	END CATCH
END
GO
