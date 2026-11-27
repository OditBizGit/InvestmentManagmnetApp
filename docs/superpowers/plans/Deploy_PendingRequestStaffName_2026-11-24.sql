/*
    Deploy : Pending Request card - staff name (2026-11-24)
    Database: MARIBEL_WELLNESS_CENTRE

    What this does
      Replaces dbo.Api_InvestorManage (CREATE OR ALTER) so that Action 18
      (GetPaymentRequests) also returns StaffName: the investor's staff,
      comma-separated, primary staff first, falling back to
      UserRegistration.AssignedStaffId when there are no allocation rows.
      Additive column only. No table, column, index or data change.

    IMPORTANT - read before running
      1. This script contains the WHOLE procedure from the repo
         (Api_InvestorManage.sql). It overwrites the live procedure with that
         version. If the live procedure has changes that are not in the repo,
         they would be lost. Take a backup first (step 2).
      2. BACKUP: in SSMS, right-click dbo.Api_InvestorManage >
         Script Stored Procedure as > CREATE To > File, and keep that file.
         That file is also your rollback (run it to restore).
      3. Deploy order: this SQL first, then the API, then the app.
         The old API ignores the new column, so running this first is safe.
      4. Run it against the LIVE server only when you intend to. The pre-flight
         below prints the server and database name; if a check fails, nothing
         in the procedure part runs (SET NOEXEC ON).

    How to run (SSMS: open this file and Execute), or:
      sqlcmd -S <server> -d MARIBEL_WELLNESS_CENTRE -E -I -b -i Deploy_PendingRequestStaffName_2026-11-24.sql
    (use -U/-P instead of -E for SQL authentication)
*/

USE MARIBEL_WELLNESS_CENTRE;
GO

SET NOEXEC OFF;
GO

PRINT 'Server  : ' + @@SERVERNAME;
PRINT 'Database: ' + DB_NAME();
GO

/* ---------------- Pre-flight checks (read-only) ---------------- */
DECLARE @err NVARCHAR(400) = NULL;

IF (SELECT compatibility_level FROM sys.databases WHERE name = DB_NAME()) < 140
    SET @err = 'Compatibility level is below 140: STRING_AGG is not available.';
ELSE IF OBJECT_ID('dbo.Api_InvestorManage', 'P') IS NULL
    SET @err = 'dbo.Api_InvestorManage does not exist in this database.';
ELSE IF OBJECT_ID('dbo.InvestorPaymentRequests', 'U') IS NULL
    SET @err = 'dbo.InvestorPaymentRequests is missing.';
ELSE IF OBJECT_ID('dbo.InvestorStaffAllocation', 'U') IS NULL
    SET @err = 'dbo.InvestorStaffAllocation is missing.';
ELSE IF OBJECT_ID('dbo.Staff', 'U') IS NULL
    SET @err = 'dbo.Staff is missing.';
ELSE IF COL_LENGTH('dbo.UserRegistration', 'AssignedStaffId') IS NULL
    SET @err = 'dbo.UserRegistration.AssignedStaffId is missing.';
ELSE IF OBJECT_ID('dbo.fn_InvestorEffectiveDueDate') IS NULL
    SET @err = 'dbo.fn_InvestorEffectiveDueDate is missing (deploy Api_InvestorInstallmentDueDateOverride.sql first).';

IF @err IS NOT NULL
BEGIN
    RAISERROR('PRE-FLIGHT FAILED - nothing will be changed: %s', 16, 1, @err);
    SET NOEXEC ON;   -- skips every later batch until SET NOEXEC OFF
END
ELSE
    PRINT 'Pre-flight OK. Applying procedure...';
GO

/* ---------------- Procedure (from Api_InvestorManage.sql) ---------------- */
/*
    Database : MARIBEL_WELLNESS_CENTRE
    Action 4 submits a pending InvestorPaymentRequests row.
    It does not insert AccountTransaction or InvestorSettlement.

    Action 1 advance: creates Pending InvestorPaymentRequests only
    (no AccountTransaction Payment until Action 19 approves).

    Action 16 update investor: updates investor/allocation/investment
    details only. It must NEVER create, modify, or delete payment
    ledger entries or payment requests.

    Action 19 approval: posts AccountTransaction Payment exactly once
    for a still-Pending request (UPDLOCK + Status/PaymentEntryNo guards).

    Calculated installment due dates use dbo.fn_InvestorCalculatedDueDate.
    Effective installment due dates use dbo.fn_InvestorEffectiveDueDate.
    Investor-level paid/pending use dbo.fn_InvestorNetPaidAmount /
    dbo.fn_InvestorPendingAmount
    (requires Api_InvestorInstallmentDueDateOverride.sql deployed first).

    How to deploy (sqlcmd):
      sqlcmd -S <server> -d MARIBEL_WELLNESS_CENTRE -U <user> -P <password> -C -i Api_InvestorManage.sql
*/

USE MARIBEL_WELLNESS_CENTRE;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Api_InvestorManage]
(
    @UserId             INT = NULL,
    @Username           VARCHAR(100) = NULL,
    @PasswordHash       VARCHAR(250) = NULL,
    @FullName           VARCHAR(250) = NULL,
    @Email              VARCHAR(250) = NULL,
    @PhoneNumber        VARCHAR(50) = NULL,
	@AlternativeNumber VARCHAR(50) = NULL,
    @InvestorCode       VARCHAR(100) = NULL,

    @InvestorType       VARCHAR(100) = NULL,
    @Organization       VARCHAR(250) = NULL,
    @Address            VARCHAR(500) = NULL,

    @InvestmentAmount   DECIMAL(18,2) = NULL,
    @InvestmentDate     DATE = NULL,
	@InvestmentSplitMonths INT = NULL,
	@InvestmentSplitGap INT = NULL,
	@InvestmentSplitType VARCHAR(20) = NULL,
	@InvestmentAdvanceAmount DECIMAL(18,2) = NULL,
	@PaymentMethod VARCHAR(50) = NULL,
	@AadhaarNumber VARCHAR(20) = NULL,
	@PanCardNumber VARCHAR(20) = NULL,
	@AccountNumber VARCHAR(50) = NULL,
	@IFSCCode VARCHAR(20) = NULL,
	@BankName VARCHAR(250) = NULL,
	@DateOfBirth DATE = NULL,

	@NomineeName VARCHAR(250) = NULL,
	@NomineeRelationship VARCHAR(100) = NULL,
	@NomineeAddress VARCHAR(500) = NULL,
	@NomineeDateOfBirth DATE = NULL,
	@NomineeAadhaarNumber VARCHAR(50) = NULL,
	@NomineePanCardCode VARCHAR(20) = NULL,
	@NomineePhoneNumber VARCHAR(50) = NULL,
    @NomineeProfilePhoto VARCHAR(500) = NULL,
    @Createdby          INT = NULL,
    @ProfileImage       VARCHAR(500) = NULL,
	@PaidAmount DECIMAL(18,2) = NULL,
	@PaymentDate DATE = NULL,
	@Narration VARCHAR(500) = NULL,
	@Complaint VARCHAR(1000) = NULL,
	@ComplaintId INT = NULL,
	@FromDate DATE = NULL,
    @ToDate DATE = NULL,
	@AadhaarPhoto VARCHAR(500) = NULL,
	@PanCardPhoto VARCHAR(500) = NULL,
	@NomineesJson NVARCHAR(MAX) = NULL,
	@StaffId INT = NULL,
	@StaffId2 INT = NULL,
	@StaffAllocationPercentage DECIMAL(5,2) = NULL,
	@Staff2AllocationPercentage DECIMAL(5,2) = NULL,
	@Description NVARCHAR(MAX) = NULL,
	@IsActive BIT = NULL,
	@IsFullSettlement BIT = 0,
	@DiscountAmount DECIMAL(18,2) = 0,
	@Remarks NVARCHAR(500) = NULL,
	@MedicalAllowance NVARCHAR(500) = NULL,
	@ExtraAmount DECIMAL(18,2) = 0,
	@Days INT = 0,
	@Status VARCHAR(20) = 'All',
	@PaymentRequestId INT = NULL,
	@BlockRequestId INT = NULL,
	@Action INT = NULL,

	-- Defaults allow callers that omit OUTPUT args (avoids live "parameter not supplied").
	@IsException BIT = 0 OUTPUT,
	@ExceptionMessage NVARCHAR(500) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SET @IsException = 0;
        SET @ExceptionMessage = NULL;



      IF @Action = 1
BEGIN

    /* Username uniqueness for RegisterInvestor: Investor role only. */
    IF EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE Username = @Username
          AND UserRole = 'Investor'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Username already exists.';
        RETURN;
    END;

	IF @StaffId IS NULL OR @StaffId <= 0
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage = 'Valid StaffId is required.';
    RETURN;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM Staff
    WHERE StaffId = @StaffId
      AND IsActive = 1
)
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage = 'Invalid or inactive StaffId.';
    RETURN;
END;

    /* Optional second staff + allocation percentages (max 2 staff). */
    DECLARE @HasStaff2 BIT =
        CASE
            WHEN @StaffId2 IS NOT NULL AND @StaffId2 > 0 THEN 1
            ELSE 0
        END;

    DECLARE @Staff1Percentage DECIMAL(5,2);
    DECLARE @Staff2Percentage DECIMAL(5,2);
    DECLARE @Staff1AllocatedAmount DECIMAL(18,2);
    DECLARE @Staff2AllocatedAmount DECIMAL(18,2);

    IF @HasStaff2 = 1
    BEGIN
        IF @StaffId2 = @StaffId
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'StaffId and StaffId2 must be different.';
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Staff
            WHERE StaffId = @StaffId2
              AND IsActive = 1
        )
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage = 'Invalid or inactive StaffId2.';
            RETURN;
        END;

        IF @StaffAllocationPercentage IS NULL
           OR @Staff2AllocationPercentage IS NULL
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Allocation percentages are required for both staff members.';
            RETURN;
        END;

        IF @StaffAllocationPercentage <= 0
           OR @StaffAllocationPercentage > 100
           OR @Staff2AllocationPercentage <= 0
           OR @Staff2AllocationPercentage > 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Each staff allocation percentage must be greater than 0 and at most 100.';
            RETURN;
        END;

        IF @StaffAllocationPercentage + @Staff2AllocationPercentage <> 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Combined staff allocation percentages must equal 100.';
            RETURN;
        END;

        SET @Staff1Percentage = @StaffAllocationPercentage;
        SET @Staff2Percentage = @Staff2AllocationPercentage;
    END
    ELSE
    BEGIN
        SET @Staff1Percentage =
            ISNULL(@StaffAllocationPercentage, 100);

        IF @Staff1Percentage <> 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'When only one staff member is assigned, allocation percentage must be 100.';
            RETURN;
        END;

        SET @Staff2Percentage = NULL;
        SET @StaffId2 = NULL;
    END;

    IF @InvestmentAmount IS NULL
       OR @InvestmentAmount <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment amount must be greater than zero.';
        RETURN;
    END;


    IF @InvestmentDate IS NULL
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment date is required.';
        RETURN;
    END;

	IF @InvestmentSplitMonths IS NULL
   OR @InvestmentSplitMonths <= 0
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage =
        'Investment split months must be greater than zero.';
    RETURN;
END;

IF @InvestmentSplitGap IS NULL
   OR @InvestmentSplitGap <= 0
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage =
        'Investment split gap must be greater than zero.';
    RETURN;
END;

IF @InvestmentAdvanceAmount IS NULL
    SET @InvestmentAdvanceAmount = 0;

IF @InvestmentAdvanceAmount < 0
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage =
        'Advance amount cannot be negative.';
    RETURN;
END;

IF @InvestmentAdvanceAmount > @InvestmentAmount
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage =
        'Advance amount cannot be greater than investment amount.';
    RETURN;
END;

IF @InvestmentSplitType IS NULL
   OR @InvestmentSplitType NOT IN ('Day', 'Week', 'Month')
BEGIN
    SET @IsException = 1;
    SET @ExceptionMessage =
        'Investment split type must be Day, Week or Month.';
    RETURN;
END;

DECLARE @RemainingInvestmentAmount DECIMAL(18,2);

DECLARE @MonthlyInvestmentAmount DECIMAL(18,2);

SET @RemainingInvestmentAmount =
    @InvestmentAmount - @InvestmentAdvanceAmount;

SET @MonthlyInvestmentAmount =
    ROUND(
        @RemainingInvestmentAmount / @InvestmentSplitMonths,
        2
    );

    /* Staff allocated amounts from total investment (not remaining after advance). */
    SET @Staff1AllocatedAmount =
        ROUND(@InvestmentAmount * @Staff1Percentage / 100.0, 2);

    IF @HasStaff2 = 1
    BEGIN
        /* Second amount absorbs rounding so percentages total the full investment. */
        SET @Staff2AllocatedAmount =
            @InvestmentAmount - @Staff1AllocatedAmount;
    END
    ELSE
    BEGIN
        SET @Staff1AllocatedAmount = @InvestmentAmount;
        SET @Staff2AllocatedAmount = NULL;
    END;


    BEGIN TRANSACTION;



    DECLARE @NewInvestorCode VARCHAR(100);

    DECLARE @NextInvestorNumber INT;

    /*
      Sequential investor number from existing Investor / MWC codes.
      New registrations only: prefix MWC (e.g. MWC001). Existing codes unchanged.
    */
    SELECT
        @NextInvestorNumber =
            ISNULL(
                MAX(
                    TRY_CONVERT(
                        INT,
                        CASE
                            WHEN LEFT(ISNULL(InvestorCode, ''), 3) = 'MWC'
                                THEN SUBSTRING(InvestorCode, 4, LEN(InvestorCode))
                            ELSE InvestorCode
                        END
                    )
                ),
                0
            ) + 1
    FROM UserRegistration
    WHERE UserRole = 'Investor';


    SET @NewInvestorCode =
        'MWC' +
        RIGHT(
            '000' + CAST(@NextInvestorNumber AS VARCHAR(10)),
            3
        );

   INSERT INTO UserRegistration
(
    Username,
    PasswordHash,
    FullName,
    Email,
    PhoneNumber,
    AlternativeNumber,
    ProfileImage,
	AadhaarPhoto,
    PanCardPhoto,
    InvestorCode,
    InvestorType,
    Organization,
    Address,
	Description,
    InvestmentSplitMonths,
	InvestmentSplitGap,
    InvestmentSplitType,
    InvestmentAdvanceAmount,
    MonthlyInvestmentAmount,
    InvestmentStartDate,
    AadhaarNumber,
    PanCardNumber,
    AccountNumber,
    IFSCCode,
    BankName,
    DateOfBirth,
    IsActive,
    CreatedDate,
    UserRole,
	AssignedStaffId
)
VALUES
(
    @Username,
    @PasswordHash,
    @FullName,
    @Email,
    @PhoneNumber,
    @AlternativeNumber,
    @ProfileImage,
	@AadhaarPhoto,
    @PanCardPhoto,
    @NewInvestorCode,
    @InvestorType,
    @Organization,
    @Address,
	@Description,
    @InvestmentSplitMonths,
	@InvestmentSplitGap,
    @InvestmentSplitType,
    @InvestmentAdvanceAmount,
    @MonthlyInvestmentAmount,
    @InvestmentDate,
    @AadhaarNumber,
    @PanCardNumber,
    @AccountNumber,
    @IFSCCode,
    @BankName,
    @DateOfBirth,

    1,
    GETDATE(),
    'Investor',
	@StaffId
);

    DECLARE @NewUserId INT;

    SET @NewUserId =
        CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.InvestorStaffAllocation
    (
        UserId,
        StaffId,
        AllocationPercentage,
        AllocatedAmount,
        CreatedDate
    )
    VALUES
    (
        @NewUserId,
        @StaffId,
        @Staff1Percentage,
        @Staff1AllocatedAmount,
        GETDATE()
    );

    INSERT INTO dbo.InvestorStaffAllocationHistory
    (
        UserId,
        StaffId,
        AllocationPercentage,
        EffectiveFromDate,
        EffectiveToDate,
        CreatedDate
    )
    VALUES
    (
        @NewUserId,
        @StaffId,
        @Staff1Percentage,
        CAST(GETDATE() AS DATE),
        NULL,
        GETDATE()
    );

    IF @HasStaff2 = 1
    BEGIN
        INSERT INTO dbo.InvestorStaffAllocation
        (
            UserId,
            StaffId,
            AllocationPercentage,
            AllocatedAmount,
            CreatedDate
        )
        VALUES
        (
            @NewUserId,
            @StaffId2,
            @Staff2Percentage,
            @Staff2AllocatedAmount,
            GETDATE()
        );

        INSERT INTO dbo.InvestorStaffAllocationHistory
        (
            UserId,
            StaffId,
            AllocationPercentage,
            EffectiveFromDate,
            EffectiveToDate,
            CreatedDate
        )
        VALUES
        (
            @NewUserId,
            @StaffId2,
            @Staff2Percentage,
            CAST(GETDATE() AS DATE),
            NULL,
            GETDATE()
        );
    END;

		 INSERT INTO InvestorMOU
    (
        InvestorId,
        Status,
        CreatedDateTime,
        ModifiedDateTime
    )
    VALUES
    (
        @NewUserId,
        'Pending',
        GETDATE(),
        NULL
    );
    INSERT INTO InvestorLLP
    (
        InvestorId,
        Status,
        CreatedDateTime,
        ModifiedDateTime
    )
    VALUES
    (
        @NewUserId,
        'Pending',
        GETDATE(),
        NULL
    );


		IF ISJSON(@NomineesJson) = 1
BEGIN

    INSERT INTO InvestorNominee
    (
        in_userid,
        in_name,
        in_relationship,
        in_address,
        in_dateofbirth,
        in_aadharnumber,
        in_pancardnumber,
        in_phonenumber,
        in_profilephoto,
        in_aadhaarphoto,
        in_pancardphoto,
        in_createdby,
        in_createddate,
        in_status
    )
    SELECT
        @NewUserId,
        J.NomineeName,
        J.NomineeRelationship,
        J.NomineeAddress,
        J.NomineeDateOfBirth,
        J.NomineeAadhaarNumber,
        J.NomineePanCardNumber,
        J.NomineePhoneNumber,
        J.NomineeProfilePhoto,
        J.NomineeAadhaarPhoto,
        J.NomineePanCardPhoto,
        @Createdby,
        GETDATE(),
        1
    FROM OPENJSON(@NomineesJson)
    WITH
    (
        NomineeName NVARCHAR(250)
            '$.NomineeName',

        NomineeRelationship NVARCHAR(100)
            '$.NomineeRelationship',

        NomineeAddress NVARCHAR(500)
            '$.NomineeAddress',

        NomineeDateOfBirth DATE
            '$.NomineeDateOfBirth',

        NomineeAadhaarNumber NVARCHAR(50)
            '$.NomineeAadhaarNumber',

        NomineePanCardNumber NVARCHAR(20)
            '$.NomineePanCardNumber',

        NomineePhoneNumber NVARCHAR(50)
            '$.NomineePhoneNumber',

        NomineeProfilePhoto NVARCHAR(500)
            '$.NomineeProfilePhoto',

        NomineeAadhaarPhoto NVARCHAR(500)
            '$.NomineeAadhaarPhoto',

        NomineePanCardPhoto NVARCHAR(500)
            '$.NomineePanCardPhoto'
    ) J
    WHERE J.NomineeName IS NOT NULL
      AND LTRIM(RTRIM(J.NomineeName)) <> '';

END;

    DECLARE @NewEntryNo INT;

    SELECT
        @NewEntryNo =
            ISNULL(MAX(EntryNo), 0) + 1
    FROM AccountTransaction WITH (UPDLOCK, HOLDLOCK);

    INSERT INTO AccountTransaction
(
    [Date],
    [Name],
    [Type],
    [EntryNo],
    [DebitAmount],
    [CreditAmount],
    [Narration],
    [Createdby],
    [CreatedDate]
)
VALUES
(
    @InvestmentDate,
    @NewUserId,
    'Investment',
    @NewEntryNo,
    0,
    @InvestmentAmount,
    'Investor Investment',
    @Createdby,
    GETDATE()
);

	IF @InvestmentAdvanceAmount > 0
BEGIN

    INSERT INTO dbo.InvestorPaymentRequests
    (
        UserId,
        PaidAmount,
        Narration,
        PaymentMethod,
        IsFullSettlement,
        DiscountAmount,
        Remarks,
        MedicalAllowance,
        Status,
        RequestedBy,
        RequestedDate
    )
    VALUES
    (
        @NewUserId,
        @InvestmentAdvanceAmount,
        'Investor Advance Payment',
        @PaymentMethod,
        0,
        0,
        NULL,
        NULL,
        'Pending',
        @Createdby,
        GETDATE()
    );

END;
    COMMIT TRANSACTION;

    SELECT
    UserId,
    Username,
    FullName,
    Email,
    PhoneNumber,
    ProfileImage,
    InvestorCode,
    InvestorType,
    Organization,
    Address,
    InvestmentSplitMonths,
    MonthlyInvestmentAmount,
    InvestmentStartDate,
    UserRole,
    IsActive,
    CreatedDate
FROM UserRegistration
WHERE UserId = @NewUserId;

END;

IF @Action = 2
BEGIN

    SELECT
    UR.UserId,
	UR.Username,
	UR.PasswordHash,
    UR.FullName,
    UR.Email,
    UR.PhoneNumber,
    UR.AlternativeNumber,
    UR.ProfileImage,
    UR.InvestorCode,
    UR.InvestorType,
    UR.Organization,
    UR.Address,
	UR.Description,
	-- UR.AssignedStaffId AS StaffId,
    -- S.FullName AS StaffName,
    UR.AadhaarNumber,
    UR.PanCardNumber,
	UR.AadhaarPhoto,
    UR.PanCardPhoto,
    UR.AccountNumber,
    UR.IFSCCode,
    UR.BankName,
    UR.DateOfBirth,
    ISNULL(
    (
        SELECT SUM(ISNULL(ATX.CreditAmount, 0))
        FROM AccountTransaction ATX
        WHERE ATX.Name = UR.UserId
          AND ATX.Type = 'Investment'
    ),
    0
) AS InvestmentAmount,
    UR.InvestmentStartDate AS InvestmentDate,
    UR.InvestmentSplitMonths,
    UR.InvestmentSplitType,
    UR.InvestmentSplitGap,
    UR.InvestmentAdvanceAmount,
    AP.PaymentMethod AS PaymentMethod,
    UR.IsActive,
    UR.CreatedDate,
    UR.ModifiedDate,
    UR.UserRole,
	JSON_QUERY
(
    (
        SELECT
		    INO.in_id AS NomineeId,
            INO.in_name AS NomineeName,
            INO.in_relationship AS NomineeRelationship,
            INO.in_address AS NomineeAddress,
            INO.in_dateofbirth AS NomineeDateOfBirth,
            INO.in_aadharnumber AS NomineeAadhaarNumber,
            INO.in_pancardnumber AS NomineePanCardNumber,
            INO.in_phonenumber AS NomineePhoneNumber,
            INO.in_profilephoto AS NomineeProfilePhoto,
            INO.in_aadhaarphoto AS NomineeAadhaarPhoto,
            INO.in_pancardphoto AS NomineePanCardPhoto

        FROM InvestorNominee INO
        WHERE INO.in_userid = UR.UserId
          AND INO.in_status = 1
        FOR JSON PATH
    )
) AS Nominees,
JSON_QUERY
(
    (
        SELECT
            X.StaffId,
            X.StaffName,
            X.StaffPhoneNumber,
            X.AllocationPercentage,
            X.AllocatedAmount
        FROM
        (
            SELECT
                ISA.StaffId AS StaffId,
                ST.FullName AS StaffName,
                ST.PhoneNumber AS StaffPhoneNumber,
                ISA.AllocationPercentage AS AllocationPercentage,
                ISA.AllocatedAmount AS AllocatedAmount,
                CASE
                    WHEN ISA.StaffId = UR.AssignedStaffId THEN 0
                    ELSE 1
                END AS SortOrder,
                ISA.AllocationId AS SortId
            FROM dbo.InvestorStaffAllocation ISA
            INNER JOIN dbo.Staff ST
                ON ST.StaffId = ISA.StaffId
            WHERE ISA.UserId = UR.UserId

            UNION ALL

            /* Legacy investors without InvestorStaffAllocation rows. */
            SELECT
                UR.AssignedStaffId AS StaffId,
                S.FullName AS StaffName,
                S.PhoneNumber AS StaffPhoneNumber,
                CAST(100.00 AS DECIMAL(5, 2)) AS AllocationPercentage,
                CAST(
                    ISNULL(
                        (
                            SELECT SUM(ISNULL(ATX.CreditAmount, 0))
                            FROM AccountTransaction ATX
                            WHERE ATX.Name = UR.UserId
                              AND ATX.Type = 'Investment'
                        ),
                        0
                    ) AS DECIMAL(18, 2)
                ) AS AllocatedAmount,
                0 AS SortOrder,
                0 AS SortId
            WHERE UR.AssignedStaffId IS NOT NULL
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM dbo.InvestorStaffAllocation ISA2
                  WHERE ISA2.UserId = UR.UserId
              )
        ) X
        ORDER BY
            X.SortOrder,
            X.SortId
        FOR JSON PATH
    )
) AS StaffAllocations,
        ISNULL(
            (
                SELECT SUM(ISNULL(ATX.CreditAmount, 0))
                FROM AccountTransaction ATX
                WHERE ATX.Name = UR.UserId
                  AND ATX.Type = 'Investment'
            ),
            0
        ) AS TotalInvestmentAmount,
        dbo.fn_InvestorNetPaidAmount(UR.UserId) AS TotalPaidAmount,
        dbo.fn_InvestorPendingAmount(UR.UserId) AS TotalPendingAmount,

ISNULL(
    (
        SELECT SUM(ISNULL(IR.RefundAmount, 0))
        FROM dbo.InvestorRefund IR
        WHERE IR.UserId = UR.UserId
    ),
    0
) AS RefundAmount,

ISNULL(
    (
        SELECT SUM(ISNULL(SETT.DiscountAmount, 0))
        FROM dbo.InvestorSettlement SETT
        WHERE SETT.UserId = UR.UserId
    ),
    0
) AS DiscountAmount,

		CASE
    WHEN dbo.fn_InvestorNetPaidAmount(UR.UserId) > 0
    THEN 'Received'
    ELSE 'Not Received'
END AS Status,

        ISNULL(LP.DebitAmount, 0) AS LatestPaymentAmount,
		ISNULL(ND.NextDueAmount, 0) AS NextDueAmount,
        ND.NextDueDate AS NextDueDate

   FROM UserRegistration UR
   LEFT JOIN Staff S
        ON S.StaffId = UR.AssignedStaffId

OUTER APPLY
(
    SELECT TOP 1
        ATX.DebitAmount
    FROM AccountTransaction ATX
    WHERE ATX.Name = UR.UserId
      AND ATX.Type = 'Payment'
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.InvestorPaymentVerification V
          WHERE V.TransactionId = ATX.id
            AND V.Status = 'Rejected'
      )
    ORDER BY
        ATX.[Date] DESC,
        ATX.EntryNo DESC,
        ATX.id DESC
) LP

	OUTER APPLY
    (
        SELECT TOP 1
            S.DueDate AS NextDueDate,
            CASE
                WHEN S.InstallmentAmount - S.PaidAmount > 0
                    THEN S.InstallmentAmount - S.PaidAmount
                ELSE CAST(0 AS DECIMAL(18, 2))
            END AS NextDueAmount
        FROM
        (
            SELECT
                I.InstallmentNumber,
                I.DueDate,
                I.InstallmentAmount,
                CASE
                    WHEN NP.NetPaid
                         - I.PreviousInstallmentTotal <= 0
                        THEN CAST(0 AS DECIMAL(18, 2))
                    WHEN NP.NetPaid
                         - I.PreviousInstallmentTotal
                         >= I.InstallmentAmount
                        THEN I.InstallmentAmount
                    ELSE
                        NP.NetPaid - I.PreviousInstallmentTotal
                END AS PaidAmount
            FROM
            (
                SELECT
                    N.Number AS InstallmentNumber,

                    dbo.fn_InvestorEffectiveDueDate(
                        UR.UserId,
                        N.Number,
                        dbo.fn_InvestorCalculatedDueDate(
                            UR.InvestmentSplitType,
                            UR.InvestmentSplitGap,
                            UR.InvestmentStartDate,
                            N.Number
                        )
                    ) AS DueDate,

                    CAST(
                        CASE
                            WHEN N.Number < UR.InvestmentSplitMonths
                                THEN ISNULL(UR.MonthlyInvestmentAmount, 0)
                            WHEN
                                ISNULL(INV.InvestmentAmount, 0)
                                - ISNULL(UR.InvestmentAdvanceAmount, 0)
                                - (
                                    ISNULL(UR.MonthlyInvestmentAmount, 0)
                                    * (UR.InvestmentSplitMonths - 1)
                                  ) > 0
                            THEN
                                ISNULL(INV.InvestmentAmount, 0)
                                - ISNULL(UR.InvestmentAdvanceAmount, 0)
                                - (
                                    ISNULL(UR.MonthlyInvestmentAmount, 0)
                                    * (UR.InvestmentSplitMonths - 1)
                                  )
                            ELSE CAST(0 AS DECIMAL(18, 2))
                        END
                        AS DECIMAL(18, 2)
                    ) AS InstallmentAmount,

                    CAST(
                        CASE
                            WHEN N.Number <= 1
                                THEN CAST(0 AS DECIMAL(18, 2))
                            WHEN N.Number < UR.InvestmentSplitMonths
                                THEN
                                    ISNULL(UR.MonthlyInvestmentAmount, 0)
                                    * (N.Number - 1)
                            ELSE
                                ISNULL(UR.MonthlyInvestmentAmount, 0)
                                * (UR.InvestmentSplitMonths - 1)
                        END
                        AS DECIMAL(18, 2)
                    ) AS PreviousInstallmentTotal
                FROM
                (
                    SELECT TOP 100
                        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Number
                    FROM sys.all_objects
                ) N
                CROSS APPLY
                (
                    SELECT
                        ISNULL(
                            (
                                SELECT SUM(ISNULL(ATX.CreditAmount, 0))
                                FROM AccountTransaction ATX
                                WHERE ATX.Name = UR.UserId
                                  AND ATX.Type = 'Investment'
                            ),
                            0
                        ) AS InvestmentAmount
                ) INV
                WHERE N.Number <= UR.InvestmentSplitMonths
            ) I
            CROSS APPLY
            (
                SELECT
                    CASE
                        WHEN
                            ISNULL(PAY.GrossPaid, 0)
                            - ISNULL(REF.TotalRefund, 0) > 0
                        THEN
                            ISNULL(PAY.GrossPaid, 0)
                            - ISNULL(REF.TotalRefund, 0)
                        ELSE CAST(0 AS DECIMAL(18, 2))
                    END AS NetPaid
                FROM
                (
                    SELECT
                        SUM(ISNULL(ATX.DebitAmount, 0)) AS GrossPaid
                    FROM AccountTransaction ATX
                    WHERE ATX.Name = UR.UserId
                      AND ATX.Type = 'Payment'
                      AND ISNULL(ATX.Narration, '')
                            <> 'Investor Advance Payment'
                      AND NOT EXISTS
                      (
                          SELECT 1
                          FROM dbo.InvestorPaymentVerification V
                          WHERE V.TransactionId = ATX.id
                            AND V.Status = 'Rejected'
                      )
                ) PAY
                OUTER APPLY
                (
                    SELECT
                        SUM(ISNULL(IR.RefundAmount, 0)) AS TotalRefund
                    FROM dbo.InvestorRefund IR
                    WHERE IR.UserId = UR.UserId
                ) REF
            ) NP
        ) S
        CROSS APPLY
        (
            SELECT
                ISNULL(
                    (
                        SELECT SUM(ISNULL(ATX.CreditAmount, 0))
                        FROM AccountTransaction ATX
                        WHERE ATX.Name = UR.UserId
                          AND ATX.Type = 'Investment'
                    ),
                    0
                ) AS InvestmentAmount,
                CASE
                    WHEN
                        ISNULL(
                            (
                                SELECT SUM(ISNULL(ATX.DebitAmount, 0))
                                FROM AccountTransaction ATX
                                WHERE ATX.Name = UR.UserId
                                  AND ATX.Type = 'Payment'
                                  AND NOT EXISTS
                                  (
                                      SELECT 1
                                      FROM dbo.InvestorPaymentVerification V
                                      WHERE V.TransactionId = ATX.id
                                        AND V.Status = 'Rejected'
                                  )
                            ),
                            0
                        )
                        -
                        ISNULL(
                            (
                                SELECT SUM(ISNULL(IR.RefundAmount, 0))
                                FROM dbo.InvestorRefund IR
                                WHERE IR.UserId = UR.UserId
                            ),
                            0
                        ) > 0
                    THEN
                        ISNULL(
                            (
                                SELECT SUM(ISNULL(ATX.DebitAmount, 0))
                                FROM AccountTransaction ATX
                                WHERE ATX.Name = UR.UserId
                                  AND ATX.Type = 'Payment'
                                  AND NOT EXISTS
                                  (
                                      SELECT 1
                                      FROM dbo.InvestorPaymentVerification V
                                      WHERE V.TransactionId = ATX.id
                                        AND V.Status = 'Rejected'
                                  )
                            ),
                            0
                        )
                        -
                        ISNULL(
                            (
                                SELECT SUM(ISNULL(IR.RefundAmount, 0))
                                FROM dbo.InvestorRefund IR
                                WHERE IR.UserId = UR.UserId
                            ),
                            0
                        )
                    ELSE CAST(0 AS DECIMAL(18, 2))
                END AS NetAllPaid
        ) TOT
        WHERE S.DueDate IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.InvestorSettlement ST
              WHERE ST.UserId = UR.UserId
          )
          AND TOT.InvestmentAmount - TOT.NetAllPaid > 0.01
          AND S.InstallmentAmount - S.PaidAmount > 0.01
        ORDER BY
            S.InstallmentNumber
    ) ND

	OUTER APPLY
(
    SELECT TOP 1
        ATX.PaymentMethod
    FROM AccountTransaction ATX
    WHERE ATX.Name = UR.UserId
      AND ATX.Type = 'Payment'
      AND ISNULL(ATX.Narration, '') = 'Investor Advance Payment'
    ORDER BY
        ATX.[Date] DESC,
        ATX.EntryNo DESC,
        ATX.id DESC
) AP

    WHERE UR.UserRole = 'Investor'

    ORDER BY UR.UserId DESC;

    SELECT
        ISNULL(
            (
                SELECT SUM(ISNULL(ATX.CreditAmount, 0))
                FROM dbo.AccountTransaction ATX
                INNER JOIN dbo.UserRegistration UR
                    ON UR.UserId = ATX.Name
                WHERE UR.UserRole = 'Investor'
                  AND ATX.Type = 'Investment'
            ),
            0
        ) AS TotalInvestmentAmount,

        ISNULL(
            (
                SELECT SUM(ISNULL(ATX.DebitAmount, 0))
                FROM dbo.AccountTransaction ATX
                INNER JOIN dbo.UserRegistration UR
                    ON UR.UserId = ATX.Name
                WHERE UR.UserRole = 'Investor'
                  AND ATX.Type = 'Payment'
                  AND NOT EXISTS
                  (
                      SELECT 1
                      FROM dbo.InvestorPaymentVerification V
                      WHERE V.TransactionId = ATX.id
                        AND V.Status = 'Rejected'
                  )
            ),
            0
        )
        -
        ISNULL(
            (
                SELECT SUM(ISNULL(IR.RefundAmount, 0))
                FROM dbo.InvestorRefund IR
                INNER JOIN dbo.UserRegistration UR2
                    ON UR2.UserId = IR.UserId
                WHERE UR2.UserRole = 'Investor'
            ),
            0
        ) AS TotalPaidAmount;

END;


 IF @Action = 3
BEGIN


    SELECT TOP 1
        UR.UserId,
        UR.Username,
        UR.FullName,
        UR.Email,
        UR.PhoneNumber,
        UR.AlternativeNumber,
        -- UR.AssignedStaffId AS StaffId,
        -- S.FullName AS StaffName,
		-- S.PhoneNumber AS StaffPhoneNumber,
        UR.ProfileImage,
        UR.InvestorCode,
        UR.InvestorType,
        UR.Organization,
        UR.Address,
        UR.AadhaarNumber,
        UR.PanCardNumber,
		UR.AadhaarPhoto,
		UR.PanCardPhoto,
        UR.AccountNumber,
        UR.IFSCCode,
        UR.BankName,
        UR.DateOfBirth,
		UR.Description,

        ISNULL(ATX.CreditAmount, 0) AS InvestmentAmount,
        ATX.Date AS InvestmentDate,

        ISNULL(UR.InvestmentAdvanceAmount, 0)
            AS InvestmentAdvanceAmount,

        ISNULL(UR.InvestmentSplitMonths, 0)
            AS InvestmentSplitMonths,

        ISNULL(UR.InvestmentSplitGap, 0)
            AS InvestmentSplitGap,

        UR.InvestmentSplitType AS InvestmentSplitType,

        dbo.fn_InvestorNetPaidAmount(UR.UserId) AS TotalPaidAmount,
        dbo.fn_InvestorPendingAmount(UR.UserId) AS TotalPendingAmount,
		ISNULL
(
    (
        SELECT SUM(ISNULL(ST.DiscountAmount, 0))
        FROM dbo.InvestorSettlement ST
        WHERE ST.UserId = UR.UserId
    ),
    0
) AS DiscountAmount,

(
    SELECT TOP 1
        CONCAT(
            CASE
                WHEN AT.ExtraAmount = FLOOR(AT.ExtraAmount)
                    THEN CONVERT(VARCHAR(30), CONVERT(BIGINT, AT.ExtraAmount))
                ELSE CONVERT(VARCHAR(30), AT.ExtraAmount)
            END,
            ' for ',
            AT.[Days],
            ' days'
        )
    FROM dbo.AccountTransaction AT
    WHERE AT.Name = UR.UserId
      AND AT.Type = 'Payment'
      AND (ISNULL(AT.ExtraAmount, 0) <> 0 OR ISNULL(AT.[Days], 0) <> 0)
    ORDER BY AT.id DESC
) AS MedicalAllowance,

        CAST(ISNULL(MED.ExtraAmount, 0) AS DECIMAL(18, 2)) AS ExtraAmount,
        CAST(ISNULL(MED.[Days], 0) AS INT) AS [Days],

        ISNULL(LP.DebitAmount, 0) AS LastPaymentAmount,
        LP.PaymentDate AS LastPaymentDate,

        JSON_QUERY
        (
            (
                SELECT
                    X.StaffId,
                    X.StaffName,
                    X.StaffPhoneNumber,
                    X.AllocationPercentage,
                    X.AllocatedAmount
                FROM
                (
                    SELECT
                        ISA.StaffId AS StaffId,
                        ST.FullName AS StaffName,
                        ST.PhoneNumber AS StaffPhoneNumber,
                        ISA.AllocationPercentage AS AllocationPercentage,
                        ISA.AllocatedAmount AS AllocatedAmount,
                        CASE
                            WHEN ISA.StaffId = UR.AssignedStaffId THEN 0
                            ELSE 1
                        END AS SortOrder,
                        ISA.AllocationId AS SortId
                    FROM dbo.InvestorStaffAllocation ISA
                    INNER JOIN dbo.Staff ST
                        ON ST.StaffId = ISA.StaffId
                    WHERE ISA.UserId = UR.UserId

                    UNION ALL

                    /* Legacy investors without InvestorStaffAllocation rows. */
                    SELECT
                        UR.AssignedStaffId AS StaffId,
                        S.FullName AS StaffName,
                        S.PhoneNumber AS StaffPhoneNumber,
                        CAST(100.00 AS DECIMAL(5, 2)) AS AllocationPercentage,
                        CAST(
                            ISNULL(ATX.CreditAmount, 0) AS DECIMAL(18, 2)
                        ) AS AllocatedAmount,
                        0 AS SortOrder,
                        0 AS SortId
                    WHERE UR.AssignedStaffId IS NOT NULL
                      AND NOT EXISTS
                      (
                          SELECT 1
                          FROM dbo.InvestorStaffAllocation ISA2
                          WHERE ISA2.UserId = UR.UserId
                      )
                ) X
                ORDER BY
                    X.SortOrder,
                    X.SortId
                FOR JSON PATH
            )
        ) AS StaffAllocations,

        UR.IsActive,
        UR.CreatedDate,
        UR.ModifiedDate,
        UR.UserRole

    FROM UserRegistration UR

    LEFT JOIN Staff S
        ON S.StaffId = UR.AssignedStaffId

    OUTER APPLY
    (
        SELECT
            ISNULL(SUM(ISNULL(AT.CreditAmount, 0)), 0) AS CreditAmount,
            MAX(AT.[Date]) AS Date
        FROM AccountTransaction AT
        WHERE AT.Name = UR.UserId
          AND AT.Type = 'Investment'
    ) ATX

    OUTER APPLY
    (
        SELECT TOP 1
            AT.DebitAmount,
            AT.[Date] AS PaymentDate
        FROM AccountTransaction AT
        WHERE AT.Name = UR.UserId
          AND AT.Type = 'Payment'
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.InvestorPaymentVerification V
              WHERE V.TransactionId = AT.id
                AND V.Status = 'Rejected'
          )
        ORDER BY
            AT.[Date] DESC,
            AT.EntryNo DESC,
            AT.id DESC
    ) LP

    /* Same latest Payment row as MedicalAllowance subquery filters. */
    OUTER APPLY
    (
        SELECT TOP (1)
            AT.ExtraAmount,
            AT.[Days]
        FROM dbo.AccountTransaction AT
        WHERE AT.Name = UR.UserId
          AND AT.Type = 'Payment'
          AND (ISNULL(AT.ExtraAmount, 0) <> 0 OR ISNULL(AT.[Days], 0) <> 0)
        ORDER BY AT.id DESC
    ) MED

    WHERE UR.UserId = @UserId
      AND UR.UserRole = 'Investor';



    DECLARE @SplitMonths INT;
    DECLARE @SplitType VARCHAR(20);
    DECLARE @SplitGap INT;
    DECLARE @StartDate DATE;
    DECLARE @MonthlyAmount DECIMAL(18,2);

    SELECT
        @SplitMonths = InvestmentSplitMonths,
        @SplitType = InvestmentSplitType,
        @SplitGap = InvestmentSplitGap,
        @StartDate = InvestmentStartDate,
        @MonthlyAmount = MonthlyInvestmentAmount
    FROM UserRegistration
    WHERE UserId = @UserId
      AND UserRole = 'Investor';


    IF @SplitMonths IS NOT NULL
       AND @SplitMonths > 0
       AND @StartDate IS NOT NULL
       AND @MonthlyAmount IS NOT NULL
    BEGIN

        CREATE TABLE #InstallmentResult
        (
            InstallmentNumber INT,
            DueDate DATE,
            InstallmentAmount DECIMAL(18,2),
            PaidAmount DECIMAL(18,2),
            PendingAmount DECIMAL(18,2),
            Status VARCHAR(50)
        );


        ;WITH DueDateList AS
        (
            SELECT
                1 AS InstallmentNumber,

                dbo.fn_InvestorCalculatedDueDate(
                    @SplitType,
                    @SplitGap,
                    @StartDate,
                    1
                ) AS DueDate

            UNION ALL

            SELECT
                InstallmentNumber + 1,

                dbo.fn_InvestorCalculatedDueDate(
                    @SplitType,
                    @SplitGap,
                    @StartDate,
                    InstallmentNumber + 1
                ) AS DueDate

            FROM DueDateList
            WHERE InstallmentNumber < @SplitMonths
        ),

        PaymentTotal AS
        (
            SELECT
                CASE
                    WHEN
                        ISNULL
                        (
                            (
                                SELECT SUM(ISNULL(AT.DebitAmount, 0))
                                FROM AccountTransaction AT
                                WHERE AT.Name = @UserId
                                  AND AT.Type = 'Payment'
                                  AND ISNULL(AT.Narration, '')
                                      <> 'Investor Advance Payment'
                                  AND NOT EXISTS
                                  (
                                      SELECT 1
                                      FROM dbo.InvestorPaymentVerification V
                                      WHERE V.TransactionId = AT.id
                                        AND V.Status = 'Rejected'
                                  )
                            ),
                            0
                        )
                        -
                        ISNULL
                        (
                            (
                                SELECT SUM(ISNULL(IR.RefundAmount, 0))
                                FROM dbo.InvestorRefund IR
                                WHERE IR.UserId = @UserId
                            ),
                            0
                        ) > 0

                    THEN
                        ISNULL
                        (
                            (
                                SELECT SUM(ISNULL(AT.DebitAmount, 0))
                                FROM AccountTransaction AT
                                WHERE AT.Name = @UserId
                                  AND AT.Type = 'Payment'
                                  AND ISNULL(AT.Narration, '')
                                      <> 'Investor Advance Payment'
                                  AND NOT EXISTS
                                  (
                                      SELECT 1
                                      FROM dbo.InvestorPaymentVerification V
                                      WHERE V.TransactionId = AT.id
                                        AND V.Status = 'Rejected'
                                  )
                            ),
                            0
                        )
                        -
                        ISNULL
                        (
                            (
                                SELECT SUM(ISNULL(IR.RefundAmount, 0))
                                FROM dbo.InvestorRefund IR
                                WHERE IR.UserId = @UserId
                            ),
                            0
                        )

                    ELSE 0
                END AS TotalPaid
        ),

        InstallmentAmounts AS
        (
            SELECT
                D.InstallmentNumber,
                D.DueDate,

                CASE
                    WHEN D.InstallmentNumber < @SplitMonths
                        THEN @MonthlyAmount

                    ELSE
                        (
                            (@MonthlyAmount * (@SplitMonths - 1)) * -1
                        )
                        +
                        (
                            SELECT
                                ISNULL(
                                    (
                                        SELECT SUM(ISNULL(AT.CreditAmount, 0))
                                        FROM AccountTransaction AT
                                        WHERE AT.Name = URX.UserId
                                          AND AT.Type = 'Investment'
                                    ),
                                    0
                                )
                                -
                                ISNULL(URX.InvestmentAdvanceAmount, 0)
                            FROM UserRegistration URX
                            WHERE URX.UserId = @UserId
                        )
                END AS InstallmentAmount

            FROM DueDateList D
        ),

        InstallmentCalculation AS
        (
            SELECT
                A.InstallmentNumber,
                A.DueDate,
                A.InstallmentAmount,

                ISNULL(
                    CASE
                        WHEN
                            ISNULL(P.TotalPaid, 0)
                            - ISNULL(
                                SUM(A.InstallmentAmount) OVER
                                (
                                    ORDER BY A.InstallmentNumber
                                    ROWS BETWEEN
                                        UNBOUNDED PRECEDING
                                        AND 1 PRECEDING
                                ),
                                0
                            ) <= 0
                        THEN CAST(0 AS DECIMAL(18, 2))

                        WHEN
                            ISNULL(P.TotalPaid, 0)
                            - ISNULL(
                                SUM(A.InstallmentAmount) OVER
                                (
                                    ORDER BY A.InstallmentNumber
                                    ROWS BETWEEN
                                        UNBOUNDED PRECEDING
                                        AND 1 PRECEDING
                                ),
                                0
                            ) >= A.InstallmentAmount
                        THEN A.InstallmentAmount

                        ELSE
                            ISNULL(P.TotalPaid, 0)
                            - ISNULL(
                                SUM(A.InstallmentAmount) OVER
                                (
                                    ORDER BY A.InstallmentNumber
                                    ROWS BETWEEN
                                        UNBOUNDED PRECEDING
                                        AND 1 PRECEDING
                                ),
                                0
                            )
                    END,
                    0
                ) AS PaidAmount

            FROM InstallmentAmounts A
            CROSS JOIN PaymentTotal P
        )

        INSERT INTO #InstallmentResult
        (
            InstallmentNumber,
            DueDate,
            InstallmentAmount,
            PaidAmount,
            PendingAmount,
            Status
        )
        SELECT
    InstallmentNumber,
    dbo.fn_InvestorEffectiveDueDate(
        @UserId,
        InstallmentNumber,
        DueDate
    ) AS DueDate,
    InstallmentAmount,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM dbo.InvestorSettlement ST
            WHERE ST.UserId = @UserId
        )
        THEN InstallmentAmount

        ELSE PaidAmount
    END AS PaidAmount,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM dbo.InvestorSettlement ST
            WHERE ST.UserId = @UserId
        )
        THEN CAST(0 AS DECIMAL(18,2))

        WHEN InstallmentAmount - PaidAmount > 0
            THEN InstallmentAmount - PaidAmount

        ELSE 0
    END AS PendingAmount,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM dbo.InvestorSettlement ST
            WHERE ST.UserId = @UserId
        )
        THEN 'Completed'

        WHEN PaidAmount >= InstallmentAmount
            THEN 'Completed'

        WHEN PaidAmount > 0
            THEN 'Partially Completed'

        ELSE 'Pending'
    END AS Status

FROM InstallmentCalculation

OPTION (MAXRECURSION 100);


        /* RESULT SET 2: INSTALLMENT DUE DATES */

        SELECT
            InstallmentNumber,
            DueDate,
            InstallmentAmount,
            PaidAmount,
            PendingAmount,
            Status
        FROM #InstallmentResult
        ORDER BY InstallmentNumber;


        /* RESULT SET 3: INSTALLMENT PAYMENT ALLOCATION */

        ;WITH PaymentWithCumulative AS
        (
            SELECT
                AT.id,
                ISNULL(AT.DebitAmount, 0) AS DebitAmount,
                AT.PaymentMethod,
                AT.[Date],
                AT.EntryNo,

                SUM(ISNULL(AT.DebitAmount, 0)) OVER
                (
                    ORDER BY AT.[Date], AT.EntryNo, AT.id
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS CumulativePaid,

                ISNULL
                (
                    SUM(ISNULL(AT.DebitAmount, 0)) OVER
                    (
                        ORDER BY AT.[Date], AT.EntryNo, AT.id
                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                    ),
                    0
                ) AS PreviousCumulativePaid

            FROM AccountTransaction AT
            WHERE AT.Name = @UserId
              AND AT.Type = 'Payment'
              AND ISNULL(AT.Narration, '') <> 'Investor Advance Payment'
              AND ISNULL(AT.DebitAmount, 0) > 0
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM dbo.InvestorPaymentVerification V
                  WHERE V.TransactionId = AT.id
                    AND V.Status = 'Rejected'
              )
        ),

        InstallmentBoundaries AS
        (
            SELECT
                IR.InstallmentNumber,
                IR.InstallmentAmount,

                ISNULL
                (
                    SUM(IR.InstallmentAmount) OVER
                    (
                        ORDER BY IR.InstallmentNumber
                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                    ),
                    0
                ) AS PreviousInstallmentTotal,

                SUM(IR.InstallmentAmount) OVER
                (
                    ORDER BY IR.InstallmentNumber
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS CumulativeInstallmentTotal

            FROM #InstallmentResult IR
        ),

        RawPaymentAllocation AS
        (
            SELECT
                IB.InstallmentNumber,
                IB.InstallmentAmount,
                IB.PreviousInstallmentTotal,
                IB.CumulativeInstallmentTotal,
                P.id,
                P.PaymentMethod,
                P.[Date],
                P.EntryNo,

                CAST
                (
                    CASE
                        WHEN P.CumulativePaid < IB.CumulativeInstallmentTotal
                            THEN P.CumulativePaid
                        ELSE IB.CumulativeInstallmentTotal
                    END
                    -
                    CASE
                        WHEN P.PreviousCumulativePaid > IB.PreviousInstallmentTotal
                            THEN P.PreviousCumulativePaid
                        ELSE IB.PreviousInstallmentTotal
                    END
                    AS DECIMAL(18,2)
                ) AS AllocatedAmount

            FROM InstallmentBoundaries IB

            INNER JOIN PaymentWithCumulative P
                ON P.CumulativePaid > IB.PreviousInstallmentTotal
               AND P.PreviousCumulativePaid < IB.CumulativeInstallmentTotal
        ),

        ValidPaymentAllocation AS
        (
            SELECT *
            FROM RawPaymentAllocation
            WHERE AllocatedAmount > 0
        ),

        RefundTotal AS
        (
            SELECT
                ISNULL(SUM(IR.RefundAmount), 0) AS TotalRefund
            FROM dbo.InvestorRefund IR
            WHERE IR.UserId = @UserId
        ),

        RefundAllocation AS
        (
            SELECT
                V.*,

                SUM(V.AllocatedAmount) OVER
                (
                    ORDER BY
                        V.InstallmentNumber DESC,
                        V.[Date] DESC,
                        V.EntryNo DESC,
                        V.id DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS CumulativeAllocationFromLatest,

                ISNULL
                (
                    SUM(V.AllocatedAmount) OVER
                    (
                        ORDER BY
                            V.InstallmentNumber DESC,
                            V.[Date] DESC,
                            V.EntryNo DESC,
                            V.id DESC
                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                    ),
                    0
                ) AS PreviousAllocationFromLatest

            FROM ValidPaymentAllocation V
        )

        SELECT
            RA.InstallmentNumber,

            CAST
            (
                CASE
                    WHEN
                        RA.AllocatedAmount
                        -
                        CASE
                            WHEN RT.TotalRefund <= RA.PreviousAllocationFromLatest
                                THEN 0

                            WHEN RT.TotalRefund >= RA.CumulativeAllocationFromLatest
                                THEN RA.AllocatedAmount

                            ELSE RT.TotalRefund - RA.PreviousAllocationFromLatest
                        END > 0

                    THEN
                        RA.AllocatedAmount
                        -
                        CASE
                            WHEN RT.TotalRefund <= RA.PreviousAllocationFromLatest
                                THEN 0

                            WHEN RT.TotalRefund >= RA.CumulativeAllocationFromLatest
                                THEN RA.AllocatedAmount

                            ELSE RT.TotalRefund - RA.PreviousAllocationFromLatest
                        END

                    ELSE 0
                END
                AS DECIMAL(18,2)
            ) AS Amount,

            RA.PaymentMethod

        FROM RefundAllocation RA
        CROSS JOIN RefundTotal RT

        WHERE RA.PaymentMethod IS NOT NULL
          AND LTRIM(RTRIM(RA.PaymentMethod)) <> ''

          AND
          (
              RA.AllocatedAmount
              -
              CASE
                  WHEN RT.TotalRefund <= RA.PreviousAllocationFromLatest
                      THEN 0

                  WHEN RT.TotalRefund >= RA.CumulativeAllocationFromLatest
                      THEN RA.AllocatedAmount

                  ELSE RT.TotalRefund - RA.PreviousAllocationFromLatest
              END
          ) > 0

        ORDER BY
            RA.InstallmentNumber,
            RA.[Date],
            RA.EntryNo,
            RA.id;


        DROP TABLE #InstallmentResult;

    END
    ELSE
    BEGIN

        /* RESULT SET 2: EMPTY INSTALLMENTS */

        SELECT
            CAST(NULL AS INT) AS InstallmentNumber,
            CAST(NULL AS DATE) AS DueDate,
            CAST(NULL AS DECIMAL(18,2)) AS InstallmentAmount,
            CAST(NULL AS DECIMAL(18,2)) AS PaidAmount,
            CAST(NULL AS DECIMAL(18,2)) AS PendingAmount,
            CAST(NULL AS VARCHAR(50)) AS Status
        WHERE 1 = 0;


        /* RESULT SET 3: EMPTY PAYMENT ALLOCATION */

        SELECT
            CAST(NULL AS INT) AS InstallmentNumber,
            CAST(NULL AS DECIMAL(18,2)) AS Amount,
            CAST(NULL AS VARCHAR(50)) AS PaymentMethod
        WHERE 1 = 0;

    END;


    /* RESULT SET 4: ALL ACTIVE NOMINEES */

    SELECT
        INM.in_id AS NomineeId,
        INM.in_name AS NomineeName,
        INM.in_relationship AS NomineeRelationship,
        INM.in_address AS NomineeAddress,
        INM.in_dateofbirth AS NomineeDateOfBirth,
        INM.in_aadharnumber AS NomineeAadhaarNumber,
        INM.in_pancardnumber AS NomineePanCardNumber,
        INM.in_phonenumber AS NomineePhoneNumber,
        INM.in_profilephoto AS NomineeProfilePhoto,
        INM.in_aadhaarphoto AS NomineeAadhaarPhoto,
        INM.in_pancardphoto AS NomineePanCardPhoto

    FROM InvestorNominee INM
    WHERE INM.in_userid = @UserId
      AND INM.in_status = 1

    ORDER BY INM.in_id;


    RETURN;

END;

IF @Action = 4
BEGIN

    SET @IsException = 0;
    SET @ExceptionMessage = NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor not found.';
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
          AND ISNULL(IsActive, 0) = 0
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Payment cannot be processed because this investor is inactive.';
        RETURN;
    END;

    IF @PaidAmount IS NULL OR @PaidAmount <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Paid amount must be greater than zero.';
        RETURN;
    END;


    IF ISNULL(@DiscountAmount, 0) < 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Discount amount cannot be negative.';
        RETURN;
    END;


    DECLARE @TotalInvestment DECIMAL(18,2);
    DECLARE @TotalPaid DECIMAL(18,2);
    DECLARE @TotalRefunded DECIMAL(18,2);
    DECLARE @PendingAmount DECIMAL(18,2);
    DECLARE @ReservedAmount DECIMAL(18,2);
    DECLARE @AvailableAmount DECIMAL(18,2);
    DECLARE @SettlementAmount DECIMAL(18,2);
    DECLARE @RequestId INT;


    BEGIN TRY

        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM UserRegistration WITH (UPDLOCK, HOLDLOCK)
            WHERE UserId = @UserId
              AND UserRole = 'Investor'
        )
        BEGIN
            THROW 50001, 'Investor not found.', 1;
        END;


        SELECT
            @TotalInvestment =
                ISNULL(SUM(ISNULL(CreditAmount, 0)), 0)
        FROM AccountTransaction
        WHERE Name = @UserId
          AND Type = 'Investment';

        /* Net paid excludes Rejected payment verifications. */
        SET @TotalPaid = dbo.fn_InvestorNetPaidAmount(@UserId);

        SELECT
            @TotalRefunded =
                ISNULL(SUM(ISNULL(RefundAmount, 0)), 0)
        FROM dbo.InvestorRefund
        WHERE UserId = @UserId;

        SET @TotalInvestment =
            ISNULL(@TotalInvestment, 0);

        SET @TotalPaid =
            ISNULL(@TotalPaid, 0);

        SET @TotalRefunded =
            ISNULL(@TotalRefunded, 0);

        IF @TotalPaid < 0
        BEGIN
            SET @TotalPaid = 0;
        END;

        SET @PendingAmount =
            @TotalInvestment - @TotalPaid;


        IF @PendingAmount < 0
        BEGIN
            SET @PendingAmount = 0;
        END;

        SELECT
            @ReservedAmount =
                ISNULL(SUM(ISNULL(PaidAmount, 0)), 0)
        FROM dbo.InvestorPaymentRequests WITH (UPDLOCK, HOLDLOCK)
        WHERE UserId = @UserId
          AND Status = 'Pending';

        SET @ReservedAmount = ISNULL(@ReservedAmount, 0);

        SET @AvailableAmount = @PendingAmount - @ReservedAmount;

        IF @AvailableAmount < 0
        BEGIN
            SET @AvailableAmount = 0;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.InvestorSettlement WITH (UPDLOCK, HOLDLOCK)
            WHERE UserId = @UserId
        )
        BEGIN
            THROW 50002,
                'This investor is already fully settled.',
                1;
        END;

        IF @AvailableAmount <= 0
        BEGIN
            SET @ExceptionMessage =
                'No amount is available for a new payment request. Existing pending requests already reserve the outstanding balance.';

            THROW 50007,
                'No amount is available for a new payment request.',
                1;
        END;


        IF ISNULL(@IsFullSettlement, 0) = 1
        BEGIN

            IF ISNULL(@DiscountAmount, 0) >= @AvailableAmount
            BEGIN
                SET @ExceptionMessage =
                    'Discount amount must be less than the available pending amount. Available pending amount is '
                    + CAST(@AvailableAmount AS VARCHAR(50))
                    + '.';

                THROW 50003,
                    'Discount amount must be less than the pending amount.',
                    1;
            END;

            SET @SettlementAmount =
                @AvailableAmount - ISNULL(@DiscountAmount, 0);

            IF @PaidAmount <> @SettlementAmount
            BEGIN

                SET @ExceptionMessage =
                    'Paid amount must match the final settlement amount. '
                    + 'Expected amount is '
                    + CAST(@SettlementAmount AS VARCHAR(50))
                    + '.';

                THROW 50004,
                    'Paid amount does not match the settlement amount.',
                    1;

            END;

        END

        ELSE

        BEGIN

            IF ISNULL(@DiscountAmount, 0) > 0
            BEGIN
                THROW 50005,
                    'Discount is allowed only for full settlement.',
                    1;
            END;


            IF @PaidAmount > @AvailableAmount
            BEGIN

                SET @ExceptionMessage =
                    'Paid amount cannot be greater than the pending amount. Pending amount is '
                    + CAST(@AvailableAmount AS VARCHAR(50))
                    + '.';

                THROW 50006,
                    'Paid amount exceeds pending amount.',
                    1;

            END;

        END;

        INSERT INTO dbo.InvestorPaymentRequests
        (
            UserId,
            PaidAmount,
            Narration,
            PaymentMethod,
            IsFullSettlement,
            DiscountAmount,
            Remarks,
            MedicalAllowance,
            ExtraAmount,
            [Days],
            Status,
            RequestedBy,
            RequestedDate
        )
        VALUES
        (
            @UserId,
            @PaidAmount,
            ISNULL(
                @Narration,
                CASE
                    WHEN ISNULL(@IsFullSettlement, 0) = 1
                        THEN 'Investor Full Settlement'
                    ELSE 'Investor Payment'
                END
            ),
            @PaymentMethod,
            ISNULL(@IsFullSettlement, 0),
            ISNULL(@DiscountAmount, 0),
            @Remarks,
            @MedicalAllowance,
            ISNULL(@ExtraAmount, 0),
            ISNULL(@Days, 0),
            'Pending',
            @Createdby,
            GETDATE()
        );

        SET @RequestId = SCOPE_IDENTITY();


        COMMIT TRANSACTION;


        SELECT TOP 1

            UR.UserId,

            UR.InvestorCode,

            UR.FullName,

            @TotalInvestment AS TotalInvestmentAmount,

            /* Same countable-payment rules as Action 4 validation. */
            CAST(dbo.fn_InvestorNetPaidAmount(UR.UserId) AS DECIMAL(18, 2))
                AS TotalPaidAmount,

            CAST(dbo.fn_InvestorPendingAmount(UR.UserId) AS DECIMAL(18, 2))
                AS RemainingAmount,

            @PaidAmount AS PaidAmount,

            @RequestId AS RequestId,

            CAST('Pending' AS VARCHAR(20)) AS Status,

            CAST(0 AS INT) AS EntryNo

        FROM UserRegistration UR

        WHERE UR.UserId = @UserId
          AND UR.UserRole = 'Investor';


    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;


        SET @IsException = 1;


        IF @ExceptionMessage IS NULL
        BEGIN
            SET @ExceptionMessage = ERROR_MESSAGE();
        END;


        RETURN;

    END CATCH;

END;

IF @Action = 5
BEGIN
    SELECT
        it_id AS InvestorTypeId,
        it_name AS InvestorTypeName
    FROM InvestorTypeList
    WHERE it_status = 1
    ORDER BY it_id;

    RETURN;
END;


IF @Action = 6
BEGIN

    ;WITH PaymentHistory AS
    (
        SELECT
            ATX.id AS TransactionId,
            CONVERT(INT, ATX.Name) AS UserId,
            UR.InvestorCode,
            UR.FullName,
            ATX.[Date],
            ISNULL(ATX.EntryNo, 0) AS EntryNo,
            ISNULL(ATX.DebitAmount, 0) AS GrossPaidAmount,
            ATX.Narration,
			ATX.PaymentMethod,

            ISNULL(
                (
                    SELECT SUM(ISNULL(INV.CreditAmount, 0))
                    FROM AccountTransaction INV
                    WHERE INV.Name = ATX.Name
                      AND INV.Type = 'Investment'
                ),
                0
            ) AS InvestmentAmount

        FROM AccountTransaction ATX

        INNER JOIN UserRegistration UR
            ON UR.UserId = ATX.Name

        WHERE UR.UserRole = 'Investor'
          AND ATX.Type = 'Payment'
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.InvestorPaymentVerification V
              WHERE V.TransactionId = ATX.id
                AND V.Status = 'Rejected'
          )
    ),
    RefundTotals AS
    (
        SELECT
            IR.UserId,
            SUM(ISNULL(IR.RefundAmount, 0)) AS TotalRefund
        FROM dbo.InvestorRefund IR
        GROUP BY IR.UserId
    ),
    RefundAllocation AS
    (
        SELECT
            PH.*,
            ISNULL(RT.TotalRefund, 0) AS TotalRefund,
            SUM(PH.GrossPaidAmount) OVER
            (
                PARTITION BY PH.UserId
                ORDER BY
                    PH.[Date] DESC,
                    PH.EntryNo DESC,
                    PH.TransactionId DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS CumulativeFromLatest,
            ISNULL(
                SUM(PH.GrossPaidAmount) OVER
                (
                    PARTITION BY PH.UserId
                    ORDER BY
                        PH.[Date] DESC,
                        PH.EntryNo DESC,
                        PH.TransactionId DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                ),
                0
            ) AS PreviousFromLatest
        FROM PaymentHistory PH
        LEFT JOIN RefundTotals RT
            ON RT.UserId = PH.UserId
    ),
    NetPayments AS
    (
        SELECT
            RA.*,
            CAST(
                CASE
                    WHEN RA.TotalRefund <= RA.PreviousFromLatest
                        THEN RA.GrossPaidAmount
                    WHEN RA.TotalRefund >= RA.CumulativeFromLatest
                        THEN 0
                    ELSE RA.GrossPaidAmount
                         - (RA.TotalRefund - RA.PreviousFromLatest)
                END
                AS DECIMAL(18, 2)
            ) AS PaidAmount
        FROM RefundAllocation RA
    ),
    NetRunning AS
    (
        SELECT
            NP.*,
            SUM(NP.PaidAmount) OVER
            (
                PARTITION BY NP.UserId
                ORDER BY
                    NP.[Date],
                    NP.EntryNo,
                    NP.TransactionId
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS ReceivedAmount
        FROM NetPayments NP
    )

    SELECT
        TransactionId,
        UserId,
        InvestorCode,
        FullName,
        [Date],
        EntryNo,
        InvestmentAmount,
		PaidAmount,
        ReceivedAmount,
        /* Settlement discount for this payment only (PaymentEntryNo match). */
        CAST(
            ISNULL(
                (
                    SELECT TOP (1) ST.DiscountAmount
                    FROM dbo.InvestorSettlement ST
                    WHERE ST.UserId = NetRunning.UserId
                      AND ST.PaymentEntryNo = NetRunning.EntryNo
                ),
                0
            ) AS DECIMAL(18, 2)
        ) AS DiscountAmount,
		PaymentMethod,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.InvestorSettlement ST
                WHERE ST.UserId = NetRunning.UserId
            )
                THEN CAST(0 AS DECIMAL(18, 2))
            WHEN InvestmentAmount - ReceivedAmount > 0
                THEN InvestmentAmount - ReceivedAmount
            ELSE CAST(0 AS DECIMAL(18, 2))
        END AS PendingAmount,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.InvestorSettlement ST
                WHERE ST.UserId = NetRunning.UserId
            )
                THEN 'Completed'
            WHEN ReceivedAmount >= InvestmentAmount
                 AND InvestmentAmount > 0
                THEN 'Completed'
            ELSE 'Pending'
        END AS [Status],

        Narration

    FROM NetRunning

    ORDER BY
        [Date] DESC,
        EntryNo DESC,
        TransactionId DESC;

    RETURN;
END;

IF @Action = 7
BEGIN

    ;WITH TopInvestors AS
    (
        SELECT TOP 10

            UR.UserId,

            UR.InvestorCode,

            UR.FullName,

            UR.ProfileImage,

            UR.InvestorType,

            UR.Organization,

            ISNULL(
                (
                    SELECT SUM(
                        ISNULL(AT1.CreditAmount, 0)
                    )
                    FROM AccountTransaction AT1
                    WHERE AT1.Name = UR.UserId
                      AND AT1.Type = 'Investment'
                ),
                0
            ) AS InvestmentAmount,

            dbo.fn_InvestorNetPaidAmount(UR.UserId) AS TotalPaidAmount

        FROM UserRegistration UR

        WHERE UR.UserRole = 'Investor'

        ORDER BY
            InvestmentAmount DESC,
            UR.UserId DESC
    ),
    RankedInvestors AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                ORDER BY
                    InvestmentAmount DESC,
                    UserId DESC
            ) AS InvestorRank
        FROM TopInvestors
    )

    SELECT

        UserId,

        InvestorCode,

        FullName,

        ProfileImage,

        InvestorType,

        Organization,

        InvestmentAmount,

        TotalPaidAmount,

        dbo.fn_InvestorPendingAmount(UserId) AS PendingAmount,

        CAST(
            CASE
                WHEN InvestorRank BETWEEN 1 AND 3
                    THEN 5.0

                WHEN InvestorRank BETWEEN 4 AND 5
                    THEN 4.5

                WHEN InvestorRank BETWEEN 6 AND 8
                    THEN 4.0

                WHEN InvestorRank BETWEEN 9 AND 10
                    THEN 3.5

                ELSE 0
            END
            AS DECIMAL(3,1)
        ) AS Rating

    FROM RankedInvestors

    ORDER BY
        InvestorRank;

    RETURN;

END;

IF @Action = 8
BEGIN


    IF NOT EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor not found.';
        RETURN;
    END;


    SELECT
        UR.UserId,
        UR.InvestorCode,
        UR.FullName,
        UR.ProfileImage,
        UR.Address AS InvestorAddress,

		PL.pl_id AS ProjectId,
		PL.pl_name AS ProjectName,
		PL.pl_description AS ProjectDescription,
		PL.pl_image AS ProjectImage,
		PL.ProjectSignaturePath AS ProjectSignaturePath,

        -- TOTAL INVESTMENT
        ISNULL(
            (
                SELECT SUM(
                    ISNULL(AT1.CreditAmount, 0)
                )
                FROM AccountTransaction AT1
                WHERE AT1.Name = UR.UserId
                  AND AT1.Type = 'Investment'
            ),
            0
        ) AS TotalInvestmentAmount,

        -- TOTAL PAID / PENDING (shared investor-level formula)
        dbo.fn_InvestorNetPaidAmount(UR.UserId) AS TotalPaidAmount,
        dbo.fn_InvestorPendingAmount(UR.UserId) AS TotalPendingAmount,

		NextDue.DueDate AS NextDueDate,

        ISNULL(NextDue.PendingAmount, 0) AS NextDueAmount

    FROM UserRegistration UR

	OUTER APPLY
(
    SELECT TOP 1
        pl_id,
        pl_name,
        pl_description,
        pl_image,
        ProjectSignaturePath
    FROM ProjectList
    WHERE pl_status = 1
    ORDER BY pl_id DESC
) PL

 OUTER APPLY
(
    SELECT TOP 1

        S.DueDate,

        CASE
            WHEN S.InstallmentAmount - S.PaidAmount > 0
                THEN S.InstallmentAmount - S.PaidAmount
            ELSE 0
        END AS PendingAmount

    FROM
    (
        SELECT
            I.InstallmentNumber,
            I.DueDate,
            I.InstallmentAmount,

            /* ========================================
               FIFO PAID AMOUNT
               NET PAID = non-advance payments - refunds
               allocated against actual installment amounts
               ======================================== */
            CASE
                WHEN NP.NetPaid - I.PreviousInstallmentTotal <= 0
                    THEN CAST(0 AS DECIMAL(18, 2))
                WHEN NP.NetPaid - I.PreviousInstallmentTotal
                     >= I.InstallmentAmount
                    THEN I.InstallmentAmount
                ELSE
                    NP.NetPaid - I.PreviousInstallmentTotal
            END AS PaidAmount
        FROM
        (
            SELECT
                N.Number AS InstallmentNumber,

                dbo.fn_InvestorEffectiveDueDate(
                    UR.UserId,
                    N.Number,
                    dbo.fn_InvestorCalculatedDueDate(
                        UR.InvestmentSplitType,
                        UR.InvestmentSplitGap,
                        UR.InvestmentStartDate,
                        N.Number
                    )
                ) AS DueDate,

                /* ========================================
                   EXACT INSTALLMENT AMOUNT
                   LAST INSTALLMENT GETS REMAINING AMOUNT
                   ======================================== */
                CAST(
                    CASE
                        WHEN N.Number <
                             ISNULL(UR.InvestmentSplitMonths, 0)
                        THEN
                            ISNULL(UR.MonthlyInvestmentAmount, 0)

                        WHEN
                            ISNULL(INV.InvestmentAmount, 0)
                            - ISNULL(UR.InvestmentAdvanceAmount, 0)
                            - (
                                ISNULL(UR.MonthlyInvestmentAmount, 0)
                                * (
                                    ISNULL(UR.InvestmentSplitMonths, 0) - 1
                                  )
                              ) > 0
                        THEN
                            ISNULL(INV.InvestmentAmount, 0)
                            - ISNULL(UR.InvestmentAdvanceAmount, 0)
                            - (
                                ISNULL(UR.MonthlyInvestmentAmount, 0)
                                * (
                                    ISNULL(UR.InvestmentSplitMonths, 0) - 1
                                  )
                              )
                        ELSE CAST(0 AS DECIMAL(18, 2))
                    END
                    AS DECIMAL(18, 2)
                ) AS InstallmentAmount,

                CAST(
                    CASE
                        WHEN N.Number <= 1
                            THEN CAST(0 AS DECIMAL(18, 2))
                        WHEN N.Number <
                             ISNULL(UR.InvestmentSplitMonths, 0)
                        THEN
                            ISNULL(UR.MonthlyInvestmentAmount, 0)
                            * (N.Number - 1)
                        ELSE
                            ISNULL(UR.MonthlyInvestmentAmount, 0)
                            * (
                                ISNULL(UR.InvestmentSplitMonths, 0) - 1
                              )
                    END
                    AS DECIMAL(18, 2)
                ) AS PreviousInstallmentTotal
            FROM
            (
                SELECT TOP 100
                    ROW_NUMBER() OVER
                    (
                        ORDER BY (SELECT NULL)
                    ) AS Number
                FROM sys.all_objects
            ) N
            CROSS APPLY
            (
                SELECT
                    ISNULL(
                        (
                            SELECT SUM(
                                ISNULL(I.CreditAmount, 0)
                            )
                            FROM AccountTransaction I
                            WHERE I.Name = UR.UserId
                              AND I.Type = 'Investment'
                        ),
                        0
                    ) AS InvestmentAmount
            ) INV
            WHERE N.Number <=
                  ISNULL(UR.InvestmentSplitMonths, 0)
        ) I
        CROSS APPLY
        (
            SELECT
                CASE
                    WHEN
                        ISNULL(PAY.GrossPaid, 0)
                        - ISNULL(REF.TotalRefund, 0) > 0
                    THEN
                        ISNULL(PAY.GrossPaid, 0)
                        - ISNULL(REF.TotalRefund, 0)
                    ELSE CAST(0 AS DECIMAL(18, 2))
                END AS NetPaid
            FROM
            (
                SELECT
                    SUM(ISNULL(P.DebitAmount, 0)) AS GrossPaid
                FROM AccountTransaction P
                WHERE P.Name = UR.UserId
                  AND P.Type = 'Payment'
                  AND ISNULL(P.Narration, '')
                      <> 'Investor Advance Payment'
                  AND NOT EXISTS
                  (
                      SELECT 1
                      FROM dbo.InvestorPaymentVerification V
                      WHERE V.TransactionId = P.id
                        AND V.Status = 'Rejected'
                  )
            ) PAY
            OUTER APPLY
            (
                SELECT
                    SUM(ISNULL(IR.RefundAmount, 0)) AS TotalRefund
                FROM dbo.InvestorRefund IR
                WHERE IR.UserId = UR.UserId
            ) REF
        ) NP
    ) S

    WHERE S.DueDate IS NOT NULL
	AND NOT EXISTS
(
    SELECT 1
    FROM dbo.InvestorSettlement ST
    WHERE ST.UserId = UR.UserId
)

      /* Ignore already completed installments */

      AND S.InstallmentAmount - S.PaidAmount > 0.01

      /* Do not show anything when overall pending is zero */

      AND
      (
          ISNULL(
              (
                  SELECT SUM(
                      ISNULL(I.CreditAmount, 0)
                  )
                  FROM AccountTransaction I
                  WHERE I.Name = UR.UserId
                    AND I.Type = 'Investment'
              ),
              0
          )
          -
          CASE
              WHEN
                  ISNULL(
                      (
                          SELECT SUM(
                              ISNULL(P.DebitAmount, 0)
                          )
                          FROM AccountTransaction P
                          WHERE P.Name = UR.UserId
                            AND P.Type = 'Payment'
                            AND NOT EXISTS
                            (
                                SELECT 1
                                FROM dbo.InvestorPaymentVerification V
                                WHERE V.TransactionId = P.id
                                  AND V.Status = 'Rejected'
                            )
                      ),
                      0
                  )
                  -
                  ISNULL(
                      (
                          SELECT SUM(
                              ISNULL(IR.RefundAmount, 0)
                          )
                          FROM dbo.InvestorRefund IR
                          WHERE IR.UserId = UR.UserId
                      ),
                      0
                  ) > 0
              THEN
                  ISNULL(
                      (
                          SELECT SUM(
                              ISNULL(P.DebitAmount, 0)
                          )
                          FROM AccountTransaction P
                          WHERE P.Name = UR.UserId
                            AND P.Type = 'Payment'
                            AND NOT EXISTS
                            (
                                SELECT 1
                                FROM dbo.InvestorPaymentVerification V
                                WHERE V.TransactionId = P.id
                                  AND V.Status = 'Rejected'
                            )
                      ),
                      0
                  )
                  -
                  ISNULL(
                      (
                          SELECT SUM(
                              ISNULL(IR.RefundAmount, 0)
                          )
                          FROM dbo.InvestorRefund IR
                          WHERE IR.UserId = UR.UserId
                      ),
                      0
                  )
              ELSE CAST(0 AS DECIMAL(18, 2))
          END
      ) > 0

    ORDER BY
        S.InstallmentNumber

) NextDue

    WHERE UR.UserId = @UserId
      AND UR.UserRole = 'Investor';




    ;WITH PaymentHistory AS
    (
        SELECT
            ATX.id AS TransactionId,

            CONVERT(INT, ATX.Name) AS UserId,

            UR.InvestorCode,

            UR.FullName,

            ATX.[Date],

            ISNULL(ATX.EntryNo, 0) AS EntryNo,

            ISNULL(ATX.DebitAmount, 0) AS GrossPaidAmount,

            ATX.Narration,
			ATX.PaymentMethod,

            ISNULL(
                (
                    SELECT SUM(
                        ISNULL(INV.CreditAmount, 0)
                    )
                    FROM AccountTransaction INV
                    WHERE INV.Name = ATX.Name
                      AND INV.Type = 'Investment'
                ),
                0
            ) AS InvestmentAmount,

			CASE
    WHEN EXISTS
    (
        SELECT 1
        FROM dbo.InvestorSettlement ST
        WHERE ST.UserId = UR.UserId
          AND ST.PaymentEntryNo = ATX.EntryNo
    )
    THEN 1
    ELSE 0
END AS IsSettlementPayment,

ISNULL
(
    (
        SELECT TOP 1 ST.DiscountAmount
        FROM dbo.InvestorSettlement ST
        WHERE ST.UserId = UR.UserId
          AND ST.PaymentEntryNo = ATX.EntryNo
    ),
    0
) AS DiscountAmount

        FROM AccountTransaction ATX

        INNER JOIN UserRegistration UR
            ON UR.UserId = ATX.Name

        WHERE ATX.Name = @UserId
          AND ATX.Type = 'Payment'
          AND UR.UserRole = 'Investor'
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.InvestorPaymentVerification V
              WHERE V.TransactionId = ATX.id
                AND V.Status = 'Rejected'
          )
    ),
    RefundTotals AS
    (
        SELECT
            IR.UserId,
            SUM(ISNULL(IR.RefundAmount, 0)) AS TotalRefund
        FROM dbo.InvestorRefund IR
        WHERE IR.UserId = @UserId
        GROUP BY IR.UserId
    ),
    RefundAllocation AS
    (
        SELECT
            PH.*,
            ISNULL(RT.TotalRefund, 0) AS TotalRefund,
            SUM(PH.GrossPaidAmount) OVER
            (
                PARTITION BY PH.UserId
                ORDER BY
                    PH.[Date] DESC,
                    PH.EntryNo DESC,
                    PH.TransactionId DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS CumulativeFromLatest,
            ISNULL(
                SUM(PH.GrossPaidAmount) OVER
                (
                    PARTITION BY PH.UserId
                    ORDER BY
                        PH.[Date] DESC,
                        PH.EntryNo DESC,
                        PH.TransactionId DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                ),
                0
            ) AS PreviousFromLatest
        FROM PaymentHistory PH
        LEFT JOIN RefundTotals RT
            ON RT.UserId = PH.UserId
    ),
    NetPayments AS
    (
        SELECT
            RA.*,
            CAST(
                CASE
                    WHEN RA.TotalRefund <= RA.PreviousFromLatest
                        THEN RA.GrossPaidAmount
                    WHEN RA.TotalRefund >= RA.CumulativeFromLatest
                        THEN 0
                    ELSE RA.GrossPaidAmount
                         - (RA.TotalRefund - RA.PreviousFromLatest)
                END
                AS DECIMAL(18, 2)
            ) AS PaidAmount
        FROM RefundAllocation RA
    ),
    NetRunning AS
    (
        SELECT
            NP.*,
            SUM(NP.PaidAmount) OVER
            (
                PARTITION BY NP.UserId
                ORDER BY
                    NP.[Date],
                    NP.EntryNo,
                    NP.TransactionId
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS ReceivedAmount
        FROM NetPayments NP
    )

    SELECT

        TransactionId,

        UserId,

        InvestorCode,

        FullName,

        [Date],

        EntryNo,

        InvestmentAmount,

		PaidAmount,

        ReceivedAmount,
		DiscountAmount,

        CASE
    WHEN EXISTS
    (
        SELECT 1
        FROM dbo.InvestorSettlement ST
        WHERE ST.UserId = NetRunning.UserId
    )
    THEN CAST(0 AS DECIMAL(18, 2))

    WHEN IsSettlementPayment = 1 THEN CAST(0 AS DECIMAL(18, 2))

    WHEN InvestmentAmount - ReceivedAmount > 0
    THEN InvestmentAmount - ReceivedAmount

    ELSE CAST(0 AS DECIMAL(18, 2))
END AS PendingAmount,

CASE
    WHEN EXISTS
    (
        SELECT 1
        FROM dbo.InvestorSettlement ST
        WHERE ST.UserId = NetRunning.UserId
    )
    THEN 'Completed'

    WHEN IsSettlementPayment = 1 THEN 'Completed'

    WHEN ReceivedAmount >= InvestmentAmount
         AND InvestmentAmount > 0
    THEN 'Completed'

    ELSE 'Pending'
END AS Status,

        Narration,
		PaymentMethod

    FROM NetRunning

    ORDER BY
        [Date] DESC,
        EntryNo DESC,
        TransactionId DESC;

END;

IF @Action = 9
BEGIN

        IF @UserId IS NULL
           OR @UserId <= 0
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Invalid investor.';
            RETURN;
        END;


        IF NOT EXISTS
        (
            SELECT 1
            FROM UserRegistration
            WHERE UserId = @UserId
              AND UserRole = 'Investor'
              AND IsActive = 1
        )
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Investor not found.';
            RETURN;
        END;


        IF @Complaint IS NULL
           OR LTRIM(RTRIM(@Complaint)) = ''
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Complaint is required.';
            RETURN;
        END;


        INSERT INTO InvestorComplaint
        (
            ic_userid,
            ic_complaint,
            ic_date,
            ic_status,
            ic_createddate
        )
        VALUES
        (
            @UserId,
            @Complaint,
            GETDATE(),
            'Pending',
            GETDATE()
        );


        SELECT
            CAST(SCOPE_IDENTITY() AS INT) AS ComplaintId,

            @UserId AS InvestorId,

            @Complaint AS Complaint,

            GETDATE() AS ComplaintDate,

            'Pending' AS Status;


        RETURN;
END;

IF @Action = 10
BEGIN

        IF @FromDate IS NOT NULL
           AND @ToDate IS NOT NULL
           AND @ToDate < @FromDate
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'To date cannot be before from date.';
            RETURN;
        END;


        SELECT
            IC.ic_id AS ComplaintId,

            IC.ic_userid AS InvestorId,

            UR.InvestorCode AS InvestorCode,

            UR.FullName AS InvestorName,

            UR.ProfileImage AS ProfileImage,

            IC.ic_complaint AS Complaint,

            IC.ic_date AS ComplaintDate,

            IC.ic_status AS Status

        FROM InvestorComplaint IC

        INNER JOIN UserRegistration UR
            ON UR.UserId = IC.ic_userid

        WHERE
            (
                @FromDate IS NULL
                OR IC.ic_date >= @FromDate
            )
            AND
            (
                @ToDate IS NULL
                OR IC.ic_date < DATEADD(DAY, 1, @ToDate)
            )

        ORDER BY
            IC.ic_date DESC,
            IC.ic_id DESC;


        RETURN;
END;

IF @Action = 11
BEGIN

        IF @UserId IS NULL
           OR @UserId <= 0
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Invalid user id.';
            RETURN;
        END;


        IF NOT EXISTS
        (
            SELECT 1
            FROM UserRegistration
            WHERE UserId = @UserId
              AND UserRole = 'Investor'
              AND IsActive = 1
        )
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Investor not found.';
            RETURN;
        END;


        SELECT
            IC.ic_id AS ComplaintId,

            IC.ic_userid AS InvestorId,

            UR.InvestorCode AS InvestorCode,

            UR.FullName AS InvestorName,

            UR.ProfileImage AS ProfileImage,

            IC.ic_complaint AS Complaint,

            IC.ic_date AS ComplaintDate,

            IC.ic_status AS Status

        FROM InvestorComplaint IC

        INNER JOIN UserRegistration UR
            ON UR.UserId = IC.ic_userid

        WHERE IC.ic_userid = @UserId

        ORDER BY
            IC.ic_date DESC,
            IC.ic_id DESC;

        RETURN;
END;

IF @Action = 12
BEGIN

        IF @ComplaintId IS NULL
           OR @ComplaintId <= 0
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Valid complaint id is required.';
            RETURN;
        END;


        IF NOT EXISTS
        (
            SELECT 1
            FROM InvestorComplaint
            WHERE ic_id = @ComplaintId
        )
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Complaint not found.';
            RETURN;
        END;


        UPDATE InvestorComplaint
        SET
            ic_status = 'Viewed'
        WHERE ic_id = @ComplaintId;


        SELECT
            'Viewed' AS Status;


        RETURN;
END;

IF @Action = 13
BEGIN

    IF @ComplaintId IS NULL
       OR @ComplaintId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Valid complaint id is required.';
        RETURN;
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM InvestorComplaint
        WHERE ic_id = @ComplaintId
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Complaint not found.';
        RETURN;
    END;


    UPDATE InvestorComplaint
    SET
        ic_status = 'Solved'
    WHERE ic_id = @ComplaintId;


    SELECT
        ic_userid AS UserId,
        'Solved' AS Status
    FROM InvestorComplaint
    WHERE ic_id = @ComplaintId;


    RETURN;
END;


IF @Action = 14
BEGIN

    BEGIN TRY

        ;WITH MonthList AS
        (
            SELECT
                DATEFROMPARTS(
                    YEAR(@FromDate),
                    MONTH(@FromDate),
                    1
                ) AS MonthDate

            UNION ALL

            SELECT
                DATEADD(MONTH, 1, MonthDate)
            FROM MonthList
            WHERE DATEADD(MONTH, 1, MonthDate)
                  <= DATEFROMPARTS(
                        YEAR(@ToDate),
                        MONTH(@ToDate),
                        1
                     )
        ),



        InvestorBase AS
        (
            SELECT
                UR.UserId,
                UR.InvestmentSplitMonths,
                UR.InvestmentSplitGap,
                UR.InvestmentSplitType,
                UR.InvestmentStartDate,
                UR.MonthlyInvestmentAmount,
                UR.InvestmentAdvanceAmount,

                ISNULL(
                    (
                        SELECT SUM(ISNULL(AT.CreditAmount, 0))
                        FROM AccountTransaction AT
                        WHERE AT.Name = UR.UserId
                          AND AT.Type = 'Investment'
                    ),
                    0
                ) AS TotalInvestment

            FROM UserRegistration UR

            WHERE UR.UserRole = 'Investor'
              AND UR.IsActive = 1
              AND UR.InvestmentSplitMonths > 0
              AND UR.InvestmentSplitGap > 0
              AND UR.InvestmentStartDate IS NOT NULL
        ),


        DueDateList AS
        (
            SELECT
                IB.UserId,
                1 AS InstallmentNumber,

                dbo.fn_InvestorCalculatedDueDate(
                    IB.InvestmentSplitType,
                    IB.InvestmentSplitGap,
                    IB.InvestmentStartDate,
                    1
                ) AS DueDate

            FROM InvestorBase IB

            UNION ALL

            SELECT
                D.UserId,
                D.InstallmentNumber + 1,

                dbo.fn_InvestorCalculatedDueDate(
                    IB.InvestmentSplitType,
                    IB.InvestmentSplitGap,
                    IB.InvestmentStartDate,
                    D.InstallmentNumber + 1
                ) AS DueDate

            FROM DueDateList D

            INNER JOIN InvestorBase IB
                ON IB.UserId = D.UserId

            WHERE D.InstallmentNumber
                  < IB.InvestmentSplitMonths
        ),



        InstallmentCalculation AS
        (
            SELECT
                D.UserId,
                D.InstallmentNumber,
                dbo.fn_InvestorEffectiveDueDate(
                    D.UserId,
                    D.InstallmentNumber,
                    D.DueDate
                ) AS DueDate,

                CAST(
                    CASE

                        WHEN D.InstallmentNumber
                             < IB.InvestmentSplitMonths

                        THEN
                            ISNULL(
                                IB.MonthlyInvestmentAmount,
                                0
                            )

                        ELSE
                            (
                                ISNULL(
                                    IB.TotalInvestment,
                                    0
                                )
                                -
                                ISNULL(
                                    IB.InvestmentAdvanceAmount,
                                    0
                                )
                            )
                            -
                            (
                                ISNULL(
                                    IB.MonthlyInvestmentAmount,
                                    0
                                )
                                *
                                (
                                    IB.InvestmentSplitMonths - 1
                                )
                            )

                    END
                    AS DECIMAL(18,2)
                ) AS InstallmentAmount

            FROM DueDateList D

            INNER JOIN InvestorBase IB
                ON IB.UserId = D.UserId
        ),



        InstallmentWithCumulative AS
        (
            SELECT
                IC.UserId,
                IC.InstallmentNumber,
                IC.DueDate,
                IC.InstallmentAmount,

                ISNULL(
                    SUM(
                        IC.InstallmentAmount
                    ) OVER
                    (
                        PARTITION BY IC.UserId
                        ORDER BY IC.InstallmentNumber
                        ROWS BETWEEN
                            UNBOUNDED PRECEDING
                            AND CURRENT ROW
                    ),
                    0
                ) AS CumulativeInstallment,

                ISNULL(
                    SUM(
                        IC.InstallmentAmount
                    ) OVER
                    (
                        PARTITION BY IC.UserId
                        ORDER BY IC.InstallmentNumber
                        ROWS BETWEEN
                            UNBOUNDED PRECEDING
                            AND 1 PRECEDING
                    ),
                    0
                ) AS PreviousCumulativeInstallment

            FROM InstallmentCalculation IC
        ),


        PaymentWithCumulative AS
        (
            SELECT
                AT.Name AS UserId,

                AT.DebitAmount,

                AT.PaymentMethod,

                AT.[Date] AS PaymentDate,

                AT.EntryNo,

                AT.id,

                ISNULL(
                    SUM(
                        ISNULL(
                            AT.DebitAmount,
                            0
                        )
                    ) OVER
                    (
                        PARTITION BY AT.Name
                        ORDER BY
                            AT.[Date],
                            AT.EntryNo,
                            AT.id
                        ROWS BETWEEN
                            UNBOUNDED PRECEDING
                            AND CURRENT ROW
                    ),
                    0
                ) AS CumulativePaid,

                ISNULL(
                    SUM(
                        ISNULL(
                            AT.DebitAmount,
                            0
                        )
                    ) OVER
                    (
                        PARTITION BY AT.Name
                        ORDER BY
                            AT.[Date],
                            AT.EntryNo,
                            AT.id
                        ROWS BETWEEN
                            UNBOUNDED PRECEDING
                            AND 1 PRECEDING
                    ),
                    0
                ) AS PreviousCumulativePaid

            FROM AccountTransaction AT

            INNER JOIN InvestorBase IB
                ON IB.UserId = AT.Name

            WHERE AT.Type = 'Payment'

              AND ISNULL(
                    AT.Narration,
                    ''
                  ) <> 'Investor Advance Payment'

              AND NOT EXISTS
              (
                  SELECT 1
                  FROM dbo.InvestorPaymentVerification V
                  WHERE V.TransactionId = AT.id
                    AND V.Status = 'Rejected'
              )
        ),



        PaymentInstallmentAllocation AS
        (
            SELECT

                P.UserId,

                I.InstallmentNumber,

                I.DueDate,

                I.InstallmentAmount,

                P.PaymentDate,

                P.DebitAmount,

                P.PaymentMethod,

                P.EntryNo,

                P.id,

                CAST(

                    CASE

                        WHEN
                            P.CumulativePaid
                            <= I.PreviousCumulativeInstallment
                        THEN 0

                        WHEN
                            P.PreviousCumulativePaid
                            >= I.CumulativeInstallment
                        THEN 0

                        ELSE

                            (
                                CASE

                                    WHEN P.CumulativePaid
                                         <
                                         I.CumulativeInstallment
                                    THEN P.CumulativePaid

                                    ELSE I.CumulativeInstallment

                                END
                            )

                            -

                            (
                                CASE

                                    WHEN P.PreviousCumulativePaid
                                         >
                                         I.PreviousCumulativeInstallment
                                    THEN P.PreviousCumulativePaid

                                    ELSE I.PreviousCumulativeInstallment

                                END
                            )

                    END

                    AS DECIMAL(18,2)

                ) AS AllocatedAmount

            FROM PaymentWithCumulative P

            INNER JOIN InstallmentWithCumulative I
                ON I.UserId = P.UserId

            WHERE
                P.CumulativePaid
                    > I.PreviousCumulativeInstallment

                AND

                P.PreviousCumulativePaid
                    < I.CumulativeInstallment
        ),


        MonthlyDue AS
        (
            SELECT

                DATEFROMPARTS(
                    YEAR(IC.DueDate),
                    MONTH(IC.DueDate),
                    1
                ) AS MonthDate,

                SUM(
                    IC.InstallmentAmount
                ) AS DueAmount

            FROM InstallmentCalculation IC

            WHERE IC.DueDate >= @FromDate
              AND IC.DueDate <= @ToDate

            GROUP BY
                DATEFROMPARTS(
                    YEAR(IC.DueDate),
                    MONTH(IC.DueDate),
                    1
                )
        ),


        MonthlyNormalReceived AS
        (
            SELECT

                DATEFROMPARTS(
                    YEAR(P.PaymentDate),
                    MONTH(P.PaymentDate),
                    1
                ) AS MonthDate,

                SUM(
                    P.AllocatedAmount
                ) AS FundingReceived

            FROM PaymentInstallmentAllocation P

            WHERE P.AllocatedAmount > 0

              AND P.PaymentDate >= @FromDate
              AND P.PaymentDate <= @ToDate

            GROUP BY
                DATEFROMPARTS(
                    YEAR(P.PaymentDate),
                    MONTH(P.PaymentDate),
                    1
                )
        ),



        MonthlyAdvanceReceived AS
        (
            SELECT

                DATEFROMPARTS(
                    YEAR(AT.[Date]),
                    MONTH(AT.[Date]),
                    1
                ) AS MonthDate,

                SUM(
                    ISNULL(
                        AT.DebitAmount,
                        0
                    )
                ) AS AdvanceReceived

            FROM AccountTransaction AT

            INNER JOIN InvestorBase IB
                ON IB.UserId = AT.Name

            WHERE AT.Type = 'Payment'

              AND ISNULL(
                    AT.Narration,
                    ''
                  ) = 'Investor Advance Payment'

              AND NOT EXISTS
              (
                  SELECT 1
                  FROM dbo.InvestorPaymentVerification V
                  WHERE V.TransactionId = AT.id
                    AND V.Status = 'Rejected'
              )

              AND AT.[Date] >= @FromDate
              AND AT.[Date] <= @ToDate

            GROUP BY
                DATEFROMPARTS(
                    YEAR(AT.[Date]),
                    MONTH(AT.[Date]),
                    1
                )
        ),


        MonthlyPending AS
        (
            SELECT

                X.MonthDate,

                SUM(
                    CASE

                        WHEN
                            X.DueAmount
                            -
                            ISNULL(
                                X.ReceivedAmount,
                                0
                            )
                            < 0

                        THEN 0

                        ELSE
                            X.DueAmount
                            -
                            ISNULL(
                                X.ReceivedAmount,
                                0
                            )

                    END
                ) AS PendingAmount

            FROM
            (
                SELECT

                    DATEFROMPARTS(
                        YEAR(IC.DueDate),
                        MONTH(IC.DueDate),
                        1
                    ) AS MonthDate,

                    IC.UserId,

                    IC.InstallmentNumber,

                    IC.InstallmentAmount AS DueAmount,

                    ISNULL(
                        (
                            SELECT
                                SUM(
                                    PIA.AllocatedAmount
                                )
                            FROM PaymentInstallmentAllocation PIA

                            WHERE PIA.UserId = IC.UserId

                              AND PIA.InstallmentNumber =
                                  IC.InstallmentNumber
                        ),
                        0
                    ) AS ReceivedAmount

                FROM InstallmentCalculation IC

                WHERE IC.DueDate >= @FromDate
                  AND IC.DueDate <= @ToDate

            ) X

            GROUP BY
                X.MonthDate
        )


SELECT

    DATENAME(
        MONTH,
        ML.MonthDate
    )
    + ' '
    +
    CAST(
        YEAR(ML.MonthDate)
        AS VARCHAR(4)
    ) AS Month,

    ML.MonthDate,

    CAST(
        ISNULL(
            MD.DueAmount,
            0
        )
        AS DECIMAL(18,2)
    ) AS DueAmount,

    CAST(
        ISNULL(
            MNR.FundingReceived,
            0
        )
        +
        ISNULL(
            MAR.AdvanceReceived,
            0
        )
        AS DECIMAL(18,2)
    ) AS FundingReceived,

    CAST(
        ISNULL(
            MP.PendingAmount,
            0
        )
        AS DECIMAL(18,2)
    ) AS PendingAmount

FROM MonthList ML

LEFT JOIN MonthlyDue MD
    ON MD.MonthDate = ML.MonthDate

LEFT JOIN MonthlyNormalReceived MNR
    ON MNR.MonthDate = ML.MonthDate

LEFT JOIN MonthlyAdvanceReceived MAR
    ON MAR.MonthDate = ML.MonthDate

LEFT JOIN MonthlyPending MP
    ON MP.MonthDate = ML.MonthDate

ORDER BY
    ML.MonthDate

OPTION (MAXRECURSION 0);


SELECT

    CAST(
        ISNULL(
            (
                SELECT
                    SUM(
                        ISNULL(pl_total_fund, 0)
                    )
                FROM ProjectList
                WHERE pl_status = 1
            ),
            0
        )
        AS DECIMAL(18,2)
    ) AS ProjectAmount,

    CAST(
        ISNULL(
            (
                SELECT
                    SUM(
                        ISNULL(AT.CreditAmount, 0)
                    )
                FROM AccountTransaction AT

                INNER JOIN UserRegistration UR
                    ON UR.UserId = AT.Name

                WHERE AT.Type = 'Investment'
                  AND UR.UserRole = 'Investor'
            ),
            0
        )
        AS DECIMAL(18,2)
    ) AS TotalInvestmentAmount,

    CAST(
        ISNULL(
            (
                SELECT
                    SUM(dbo.fn_InvestorNetPaidAmount(UR.UserId))
                FROM UserRegistration UR
                WHERE UR.UserRole = 'Investor'
            ),
            0
        )
        AS DECIMAL(18,2)
    ) AS TotalPaidAmount,

    CAST(
        ISNULL(
            (
                SELECT
                    SUM(dbo.fn_InvestorPendingAmount(UR.UserId))
                FROM UserRegistration UR
                WHERE UR.UserRole = 'Investor'
            ),
            0
        )
        AS DECIMAL(18,2)
    ) AS TotalPendingAmount;

    END TRY

    BEGIN CATCH

        SET @IsException = 1;

        SET @ExceptionMessage = ERROR_MESSAGE();

        RETURN;

    END CATCH;

END

IF @Action = 15
BEGIN

        SELECT
            COUNT(*) AS TotalInvestors
        FROM UserRegistration
        WHERE UserRole = 'Investor'
          AND IsActive = 1;


        SELECT

            CASE
                WHEN InvestorType IS NULL
                     OR LTRIM(RTRIM(InvestorType)) = ''
                THEN 'Unknown'

                ELSE LTRIM(RTRIM(InvestorType))
            END AS InvestorType,

            COUNT(*) AS Count

        FROM UserRegistration

        WHERE UserRole = 'Investor'
          AND IsActive = 1

        GROUP BY

            CASE
                WHEN InvestorType IS NULL
                     OR LTRIM(RTRIM(InvestorType)) = ''
                THEN 'Unknown'

                ELSE LTRIM(RTRIM(InvestorType))
            END

        ORDER BY
            InvestorType;


END

IF @Action = 16
BEGIN
    IF @UserId IS NULL OR @UserId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Valid investor id is required.';
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor not found.';
        RETURN;
    END;

    IF @StaffId IS NULL OR @StaffId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Valid StaffId is required.';
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Staff
        WHERE StaffId = @StaffId
          AND IsActive = 1
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Invalid or inactive StaffId.';
        RETURN;
    END;

    /* Optional second staff + allocation percentages (same rules as Action 1). */
    DECLARE @UpdateHasStaff2 BIT =
        CASE
            WHEN @StaffId2 IS NOT NULL AND @StaffId2 > 0 THEN 1
            ELSE 0
        END;

    DECLARE @UpdateStaff1Percentage DECIMAL(5,2);
    DECLARE @UpdateStaff2Percentage DECIMAL(5,2);
    DECLARE @UpdateStaff1AllocatedAmount DECIMAL(18,2);
    DECLARE @UpdateStaff2AllocatedAmount DECIMAL(18,2);

    IF @UpdateHasStaff2 = 1
    BEGIN
        IF @StaffId2 = @StaffId
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'StaffId and StaffId2 must be different.';
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Staff
            WHERE StaffId = @StaffId2
              AND IsActive = 1
        )
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage = 'Invalid or inactive StaffId2.';
            RETURN;
        END;

        IF @StaffAllocationPercentage IS NULL
           OR @Staff2AllocationPercentage IS NULL
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Allocation percentages are required for both staff members.';
            RETURN;
        END;

        IF @StaffAllocationPercentage <= 0
           OR @StaffAllocationPercentage > 100
           OR @Staff2AllocationPercentage <= 0
           OR @Staff2AllocationPercentage > 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Each staff allocation percentage must be greater than 0 and at most 100.';
            RETURN;
        END;

        IF @StaffAllocationPercentage + @Staff2AllocationPercentage <> 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'Combined staff allocation percentages must equal 100.';
            RETURN;
        END;

        SET @UpdateStaff1Percentage = @StaffAllocationPercentage;
        SET @UpdateStaff2Percentage = @Staff2AllocationPercentage;
    END
    ELSE
    BEGIN
        SET @UpdateStaff1Percentage =
            ISNULL(@StaffAllocationPercentage, 100);

        IF @UpdateStaff1Percentage <> 100
        BEGIN
            SET @IsException = 1;
            SET @ExceptionMessage =
                'When only one staff member is assigned, allocation percentage must be 100.';
            RETURN;
        END;

        SET @UpdateStaff2Percentage = NULL;
        SET @StaffId2 = NULL;
    END;

    IF @InvestmentAmount IS NULL OR @InvestmentAmount <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment amount must be greater than zero.';
        RETURN;
    END;

    IF @InvestmentDate IS NULL
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investment date is required.';
        RETURN;
    END;

    IF @InvestmentSplitMonths IS NULL
       OR @InvestmentSplitMonths <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment split months must be greater than zero.';
        RETURN;
    END;

    IF @InvestmentSplitGap IS NULL OR @InvestmentSplitGap <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment split gap must be greater than zero.';
        RETURN;
    END;

    IF @InvestmentSplitType IS NULL
       OR @InvestmentSplitType NOT IN ('Day', 'Week', 'Month')
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Investment split type must be Day, Week or Month.';
        RETURN;
    END;

    IF @InvestmentAdvanceAmount IS NULL
        SET @InvestmentAdvanceAmount = 0;

    IF @InvestmentAdvanceAmount < 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Advance amount cannot be negative.';
        RETURN;
    END;

    IF @InvestmentAdvanceAmount > @InvestmentAmount
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'Advance amount cannot be greater than investment amount.';
        RETURN;
    END;

    SET @UpdateStaff1AllocatedAmount =
        ROUND(@InvestmentAmount * @UpdateStaff1Percentage / 100.0, 2);

    IF @UpdateHasStaff2 = 1
    BEGIN
        SET @UpdateStaff2AllocatedAmount =
            @InvestmentAmount - @UpdateStaff1AllocatedAmount;
    END
    ELSE
    BEGIN
        SET @UpdateStaff1AllocatedAmount = @InvestmentAmount;
        SET @UpdateStaff2AllocatedAmount = NULL;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UpdateRemainingInvestmentAmount DECIMAL(18,2);
        DECLARE @UpdateMonthlyInvestmentAmount DECIMAL(18,2);

        SET @UpdateRemainingInvestmentAmount =
            @InvestmentAmount - @InvestmentAdvanceAmount;

        SET @UpdateMonthlyInvestmentAmount =
            ROUND(
                @UpdateRemainingInvestmentAmount /
                @InvestmentSplitMonths,
                2
            );

        /* =========================================
           1. UPDATE INVESTOR DETAILS
           ========================================= */

        UPDATE UserRegistration
        SET
            FullName = @FullName,
            Email = @Email,
            PhoneNumber = @PhoneNumber,
            AlternativeNumber = @AlternativeNumber,
            InvestorType = @InvestorType,
            Organization = @Organization,
            Address = @Address,
            AadhaarNumber = @AadhaarNumber,
            PanCardNumber = @PanCardNumber,
            AccountNumber = @AccountNumber,
            IFSCCode = @IFSCCode,
            BankName = @BankName,
            DateOfBirth = @DateOfBirth,
            AssignedStaffId = @StaffId,
            Description = @Description,

            InvestmentSplitMonths = @InvestmentSplitMonths,
            InvestmentSplitGap = @InvestmentSplitGap,
            InvestmentSplitType = @InvestmentSplitType,
            InvestmentAdvanceAmount = @InvestmentAdvanceAmount,
            MonthlyInvestmentAmount = @UpdateMonthlyInvestmentAmount,
            InvestmentStartDate = @InvestmentDate,

            ModifiedDate = GETDATE(),

            ProfileImage =
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(@ProfileImage)), '') IS NOT NULL
                    THEN @ProfileImage
                    ELSE ProfileImage
                END,

            AadhaarPhoto =
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(@AadhaarPhoto)), '') IS NOT NULL
                    THEN @AadhaarPhoto
                    ELSE AadhaarPhoto
                END,

            PanCardPhoto =
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(@PanCardPhoto)), '') IS NOT NULL
                    THEN @PanCardPhoto
                    ELSE PanCardPhoto
                END

        WHERE UserId = @UserId
          AND UserRole = 'Investor';

        /* =========================================
           1b. REPLACE STAFF ALLOCATIONS (no duplicates)
               Current table: DELETE + INSERT (unchanged)
               History: close open rows, insert new open rows
           ========================================= */

        UPDATE dbo.InvestorStaffAllocationHistory
        SET EffectiveToDate = CAST(GETDATE() AS DATE)
        WHERE UserId = @UserId
          AND EffectiveToDate IS NULL;

        DELETE FROM dbo.InvestorStaffAllocation
        WHERE UserId = @UserId;

        INSERT INTO dbo.InvestorStaffAllocation
        (
            UserId,
            StaffId,
            AllocationPercentage,
            AllocatedAmount,
            CreatedDate
        )
        VALUES
        (
            @UserId,
            @StaffId,
            @UpdateStaff1Percentage,
            @UpdateStaff1AllocatedAmount,
            GETDATE()
        );

        INSERT INTO dbo.InvestorStaffAllocationHistory
        (
            UserId,
            StaffId,
            AllocationPercentage,
            EffectiveFromDate,
            EffectiveToDate,
            CreatedDate
        )
        VALUES
        (
            @UserId,
            @StaffId,
            @UpdateStaff1Percentage,
            CAST(GETDATE() AS DATE),
            NULL,
            GETDATE()
        );

        IF @UpdateHasStaff2 = 1
        BEGIN
            INSERT INTO dbo.InvestorStaffAllocation
            (
                UserId,
                StaffId,
                AllocationPercentage,
                AllocatedAmount,
                CreatedDate
            )
            VALUES
            (
                @UserId,
                @StaffId2,
                @UpdateStaff2Percentage,
                @UpdateStaff2AllocatedAmount,
                GETDATE()
            );

            INSERT INTO dbo.InvestorStaffAllocationHistory
            (
                UserId,
                StaffId,
                AllocationPercentage,
                EffectiveFromDate,
                EffectiveToDate,
                CreatedDate
            )
            VALUES
            (
                @UserId,
                @StaffId2,
                @UpdateStaff2Percentage,
                CAST(GETDATE() AS DATE),
                NULL,
                GETDATE()
            );
        END;


        /* =========================================
           2. UPDATE INVESTMENT TRANSACTION
           ========================================= */

        UPDATE AccountTransaction
        SET
            [Date] = @InvestmentDate,
            CreditAmount = @InvestmentAmount
        WHERE Name = @UserId
          AND Type = 'Investment'
          AND Narration = 'Investor Investment';

        /*
           Advance / payment ledger entries are intentionally NOT created,
           updated, or deleted here.

           Registration (Action 1) creates a Pending InvestorPaymentRequests
           row for any advance. Only Action 19 (approve payment request)
           may insert the matching AccountTransaction Payment.

           Updating investor details must never touch payment requests or
           payment ledger rows.
        */


        /* =========================================
           3. MULTIPLE NOMINEE UPDATE / INSERT
           ========================================= */

        IF NULLIF(LTRIM(RTRIM(@NomineesJson)), '') IS NOT NULL
        BEGIN
            DECLARE @NomineeInput TABLE
            (
                NomineeId INT NULL,
                NomineeName VARCHAR(250) NULL,
                NomineeRelationship VARCHAR(100) NULL,
                NomineeAddress VARCHAR(500) NULL,
                NomineeDateOfBirth DATE NULL,
                NomineeAadhaarNumber VARCHAR(50) NULL,
                NomineePanCardNumber VARCHAR(20) NULL,
                NomineePhoneNumber VARCHAR(50) NULL,
                NomineeProfilePhoto VARCHAR(500) NULL,
                NomineeAadhaarPhoto VARCHAR(500) NULL,
                NomineePanCardPhoto VARCHAR(500) NULL
            );

            INSERT INTO @NomineeInput
            (
                NomineeId,
                NomineeName,
                NomineeRelationship,
                NomineeAddress,
                NomineeDateOfBirth,
                NomineeAadhaarNumber,
                NomineePanCardNumber,
                NomineePhoneNumber,
                NomineeProfilePhoto,
                NomineeAadhaarPhoto,
                NomineePanCardPhoto
            )
            SELECT
                NomineeId,
                NomineeName,
                NomineeRelationship,
                NomineeAddress,
                NomineeDateOfBirth,
                NomineeAadhaarNumber,
                NomineePanCardNumber,
                NomineePhoneNumber,
                NomineeProfilePhoto,
                NomineeAadhaarPhoto,
                NomineePanCardPhoto
            FROM OPENJSON(@NomineesJson)
            WITH
            (
                NomineeId INT '$.NomineeId',
                NomineeName VARCHAR(250) '$.NomineeName',
                NomineeRelationship VARCHAR(100) '$.NomineeRelationship',
                NomineeAddress VARCHAR(500) '$.NomineeAddress',
                NomineeDateOfBirth DATE '$.NomineeDateOfBirth',
                NomineeAadhaarNumber VARCHAR(50) '$.NomineeAadhaarNumber',
                NomineePanCardNumber VARCHAR(20) '$.NomineePanCardNumber',
                NomineePhoneNumber VARCHAR(50) '$.NomineePhoneNumber',
                NomineeProfilePhoto VARCHAR(500) '$.NomineeProfilePhoto',
                NomineeAadhaarPhoto VARCHAR(500) '$.NomineeAadhaarPhoto',
                NomineePanCardPhoto VARCHAR(500) '$.NomineePanCardPhoto'
            );

            /* Existing nominee ID must belong to this investor. */

            IF EXISTS
            (
                SELECT 1
                FROM @NomineeInput N
                WHERE N.NomineeId IS NOT NULL
                  AND N.NomineeId > 0
                  AND NOT EXISTS
                  (
                      SELECT 1
                      FROM InvestorNominee I
                      WHERE I.in_id = N.NomineeId
                        AND I.in_userid = @UserId
                  )
            )
            BEGIN
                THROW 50001,
                    'One or more nominee IDs do not belong to this investor.',
                    1;
            END;

            /* Do not allow duplicate existing IDs. */

            IF EXISTS
            (
                SELECT NomineeId
                FROM @NomineeInput
                WHERE NomineeId IS NOT NULL
                  AND NomineeId > 0
                GROUP BY NomineeId
                HAVING COUNT(*) > 1
            )
            BEGIN
                THROW 50002,
                    'Duplicate nominee IDs are not allowed.',
                    1;
            END;

            /* Update each existing nominee independently. */

            UPDATE I
            SET
                in_name = N.NomineeName,
                in_relationship = N.NomineeRelationship,
                in_address = N.NomineeAddress,
                in_dateofbirth = N.NomineeDateOfBirth,
                in_aadharnumber = N.NomineeAadhaarNumber,
                in_pancardnumber = N.NomineePanCardNumber,
                in_phonenumber = N.NomineePhoneNumber,

                in_profilephoto =
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(N.NomineeProfilePhoto)), ''),
                        I.in_profilephoto
                    ),

                in_aadhaarphoto =
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(N.NomineeAadhaarPhoto)), ''),
                        I.in_aadhaarphoto
                    ),

                in_pancardphoto =
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(N.NomineePanCardPhoto)), ''),
                        I.in_pancardphoto
                    ),

                in_modifiedby = @Createdby,
                in_modifieddate = GETDATE()

            FROM InvestorNominee I
            INNER JOIN @NomineeInput N
                ON I.in_id = N.NomineeId
            WHERE I.in_userid = @UserId
              AND N.NomineeId > 0;


            /* Insert nominees without an existing ID. */

            INSERT INTO InvestorNominee
            (
                in_userid,
                in_name,
                in_relationship,
                in_address,
                in_dateofbirth,
                in_aadharnumber,
                in_pancardnumber,
                in_phonenumber,
                in_profilephoto,
                in_aadhaarphoto,
                in_pancardphoto,
                in_createdby,
                in_createddate,
                in_status
            )
            SELECT
                @UserId,
                N.NomineeName,
                N.NomineeRelationship,
                N.NomineeAddress,
                N.NomineeDateOfBirth,
                N.NomineeAadhaarNumber,
                N.NomineePanCardNumber,
                N.NomineePhoneNumber,
                N.NomineeProfilePhoto,
                N.NomineeAadhaarPhoto,
                N.NomineePanCardPhoto,
                @Createdby,
                GETDATE(),
                1
            FROM @NomineeInput N
            WHERE ISNULL(N.NomineeId, 0) = 0
              AND NULLIF(LTRIM(RTRIM(N.NomineeName)), '') IS NOT NULL;
        END
        ELSE IF NULLIF(LTRIM(RTRIM(@NomineeName)), '') IS NOT NULL
        BEGIN
            /*
              Legacy compatibility:
              When the old single-nominee fields are used,
              update one nominee only, not every nominee.
            */

            DECLARE @LegacyNomineeId INT;

            SELECT TOP (1)
                @LegacyNomineeId = in_id
            FROM InvestorNominee
            WHERE in_userid = @UserId
            ORDER BY in_id;

            IF @LegacyNomineeId IS NOT NULL
            BEGIN
                UPDATE InvestorNominee
                SET
                    in_name = @NomineeName,
                    in_relationship = @NomineeRelationship,
                    in_address = @NomineeAddress,
                    in_dateofbirth = @NomineeDateOfBirth,
                    in_aadharnumber = @NomineeAadhaarNumber,
                    in_pancardnumber = @NomineePanCardCode,
                    in_phonenumber = @NomineePhoneNumber,

                    in_profilephoto =
                        CASE
                            WHEN NULLIF(
                                LTRIM(RTRIM(@NomineeProfilePhoto)), ''
                            ) IS NOT NULL
                            THEN @NomineeProfilePhoto
                            ELSE in_profilephoto
                        END,

                    in_modifiedby = @Createdby,
                    in_modifieddate = GETDATE()

                WHERE in_id = @LegacyNomineeId
                  AND in_userid = @UserId;
            END
            ELSE
            BEGIN
                INSERT INTO InvestorNominee
                (
                    in_userid,
                    in_name,
                    in_relationship,
                    in_address,
                    in_dateofbirth,
                    in_aadharnumber,
                    in_pancardnumber,
                    in_phonenumber,
                    in_profilephoto,
                    in_createdby,
                    in_createddate,
                    in_status
                )
                VALUES
                (
                    @UserId,
                    @NomineeName,
                    @NomineeRelationship,
                    @NomineeAddress,
                    @NomineeDateOfBirth,
                    @NomineeAadhaarNumber,
                    @NomineePanCardCode,
                    @NomineePhoneNumber,
                    @NomineeProfilePhoto,
                    @Createdby,
                    GETDATE(),
                    1
                );
            END;
        END;

        COMMIT TRANSACTION;

        SELECT 'Updated' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @IsException = 1;
        SET @ExceptionMessage = ERROR_MESSAGE();

        RETURN;
    END CATCH;
END;

IF @Action = 17
BEGIN
    SET NOCOUNT ON;

    IF @UserId IS NULL OR @UserId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Valid investor id is required.';
        RETURN;
    END;

    IF @IsActive IS NULL
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor status is required.';
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor not found.';
        RETURN;
    END;

    /* Unblock remains immediate (no Marketing Manager approval). */
    IF @IsActive = 1
    BEGIN
        UPDATE UserRegistration
        SET
            IsActive = 1,
            ModifiedDate = GETDATE()
        WHERE UserId = @UserId
          AND UserRole = 'Investor';

        SELECT
            UserId,
            FullName,
            IsActive,
            ModifiedDate,
            CAST(NULL AS INT) AS RequestId,
            CAST(NULL AS VARCHAR(20)) AS RequestStatus
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor';

        RETURN;
    END;

    /* Block request: do NOT change IsActive until Marketing Manager approves. */
    IF EXISTS
    (
        SELECT 1
        FROM UserRegistration
        WHERE UserId = @UserId
          AND UserRole = 'Investor'
          AND ISNULL(IsActive, 0) = 0
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Investor is already blocked.';
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.InvestorBlockRequests
        WHERE UserId = @UserId
          AND Status = 'Pending'
    )
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage =
            'A pending block request already exists for this investor.';
        RETURN;
    END;

    DECLARE @NewBlockRequestId INT;

    INSERT INTO dbo.InvestorBlockRequests
    (
        UserId,
        Status,
        Remarks,
        RequestedBy,
        RequestedDate
    )
    VALUES
    (
        @UserId,
        'Pending',
        NULLIF(LTRIM(RTRIM(@Remarks)), ''),
        @Createdby,
        GETDATE()
    );

    SET @NewBlockRequestId = CONVERT(INT, SCOPE_IDENTITY());

    SELECT
        UR.UserId,
        UR.FullName,
        UR.IsActive,
        UR.ModifiedDate,
        @NewBlockRequestId AS RequestId,
        CAST('Pending' AS VARCHAR(20)) AS RequestStatus
    FROM UserRegistration UR
    WHERE UR.UserId = @UserId
      AND UR.UserRole = 'Investor';

    RETURN;
END;

IF @Action = 18
BEGIN
    IF @Status IS NULL OR LTRIM(RTRIM(@Status)) = ''
        SET @Status = 'All';

    /*
        IsFullSettlement / DiscountAmount come from this payment request
        (InvestorPaymentRequests), matching AddInvestorPayment (Action 4).
    */
    SELECT
        R.RequestId,
        R.UserId,
        UR.InvestorCode,
        UR.FullName,
        UR.Email,
        UR.PhoneNumber,
        R.PaidAmount,
        R.Narration,
        R.PaymentMethod,
        CAST(ISNULL(R.IsFullSettlement, 0) AS BIT) AS IsFullSettlement,
        CAST(ISNULL(R.DiscountAmount, 0) AS DECIMAL(18, 2)) AS DiscountAmount,
        R.Remarks,
        R.MedicalAllowance,
        R.Status,
        R.RequestedDate,
        R.RequestedBy,
        RB.FullName AS RequestedByName,
        R.ReviewedBy,
        RV.FullName AS ReviewedByName,
        R.ReviewedDate,
        R.ReviewRemarks,
        R.PaymentEntryNo,
        SN.StaffName AS StaffName
    FROM dbo.InvestorPaymentRequests R
    INNER JOIN dbo.UserRegistration UR
        ON UR.UserId = R.UserId
    LEFT JOIN dbo.UserRegistration RB
        ON RB.UserId = R.RequestedBy
    LEFT JOIN dbo.UserRegistration RV
        ON RV.UserId = R.ReviewedBy
    OUTER APPLY (
        SELECT STRING_AGG(X.StaffName, ', ') WITHIN GROUP (ORDER BY X.SortOrder, X.SortId) AS StaffName
        FROM (
            SELECT ST.FullName AS StaffName,
                   CASE WHEN ISA.StaffId = UR.AssignedStaffId THEN 0 ELSE 1 END AS SortOrder,
                   ISA.AllocationId AS SortId
            FROM dbo.InvestorStaffAllocation ISA
            INNER JOIN dbo.Staff ST ON ST.StaffId = ISA.StaffId
            WHERE ISA.UserId = R.UserId
            UNION ALL
            SELECT LS.FullName, 0, 0
            FROM dbo.Staff LS
            WHERE LS.StaffId = UR.AssignedStaffId
              AND NOT EXISTS (SELECT 1 FROM dbo.InvestorStaffAllocation ISA2 WHERE ISA2.UserId = R.UserId)
        ) X
    ) SN
    WHERE @Status = 'All'
       OR R.Status = @Status
    ORDER BY R.RequestId DESC;

    RETURN;
END;

IF @Action = 19
BEGIN
    DECLARE @PaymentEntryNo INT;
    DECLARE @RequestRemarks NVARCHAR(500);

    IF @PaymentRequestId IS NULL OR @PaymentRequestId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Payment request id is required.';
        RETURN;
    END;

    SET @Status = LTRIM(RTRIM(ISNULL(@Status, '')));

    IF @Status NOT IN ('Approved', 'Rejected')
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Status must be Approved or Rejected.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ExistingPaymentEntryNo INT;

        SELECT
            @UserId = R.UserId,
            @PaidAmount = R.PaidAmount,
            @Narration = R.Narration,
            @PaymentMethod = R.PaymentMethod,
            @IsFullSettlement = R.IsFullSettlement,
            @DiscountAmount = R.DiscountAmount,
            @RequestRemarks = R.Remarks,
            @MedicalAllowance = R.MedicalAllowance,
            @ExtraAmount = R.ExtraAmount,
            @Days = R.[Days],
            @ExistingPaymentEntryNo = R.PaymentEntryNo
        FROM dbo.InvestorPaymentRequests R WITH (UPDLOCK, HOLDLOCK)
        WHERE R.RequestId = @PaymentRequestId
          AND R.Status = 'Pending';

        IF @@ROWCOUNT = 0
        BEGIN
            SET @ExceptionMessage =
                'Payment request not found or is no longer pending.';
            THROW 50008,
                'Payment request not found or is no longer pending.',
                1;
        END;

        /* Pending requests must not already be linked to a ledger entry. */
        IF @ExistingPaymentEntryNo IS NOT NULL
           AND @ExistingPaymentEntryNo > 0
        BEGIN
            SET @ExceptionMessage =
                'Payment request is already linked to a payment entry and cannot be approved again.';
            THROW 50010,
                'Payment request is already linked to a payment entry and cannot be approved again.',
                1;
        END;

        IF @Status = 'Rejected'
        BEGIN
            UPDATE dbo.InvestorPaymentRequests
            SET
                Status = 'Rejected',
                ReviewedBy = @Createdby,
                ReviewedDate = GETDATE(),
                ReviewRemarks = NULLIF(LTRIM(RTRIM(@Remarks)), '')
            WHERE RequestId = @PaymentRequestId
              AND Status = 'Pending'
              AND ISNULL(PaymentEntryNo, 0) = 0;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @ExceptionMessage =
                    'Payment request not found or is no longer pending.';
                THROW 50008,
                    'Payment request not found or is no longer pending.',
                    1;
            END;
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UserRegistration WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId
                  AND UserRole = 'Investor'
            )
            BEGIN
                SET @ExceptionMessage = 'Investor not found.';
                THROW 50001, 'Investor not found.', 1;
            END;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.UserRegistration
                WHERE UserId = @UserId
                  AND UserRole = 'Investor'
                  AND ISNULL(IsActive, 0) = 0
            )
            BEGIN
                SET @ExceptionMessage =
                    'Payment cannot be processed because this investor is inactive.';
                THROW 50009,
                    'Payment cannot be processed because this investor is inactive.',
                    1;
            END;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.InvestorSettlement WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId
            )
            BEGIN
                SET @ExceptionMessage = 'This investor is already fully settled.';
                THROW 50002, 'This investor is already fully settled.', 1;
            END;

            SELECT
                @TotalInvestment = ISNULL(SUM(ISNULL(CreditAmount, 0)), 0)
            FROM dbo.AccountTransaction
            WHERE Name = @UserId
              AND Type = 'Investment';

            /* Net paid excludes Rejected payment verifications. */
            SET @TotalPaid = dbo.fn_InvestorNetPaidAmount(@UserId);

            SELECT
                @TotalRefunded = ISNULL(SUM(ISNULL(RefundAmount, 0)), 0)
            FROM dbo.InvestorRefund
            WHERE UserId = @UserId;

            SET @TotalInvestment = ISNULL(@TotalInvestment, 0);
            SET @TotalPaid = ISNULL(@TotalPaid, 0);

            IF @TotalPaid < 0
                SET @TotalPaid = 0;

            SET @PendingAmount = @TotalInvestment - @TotalPaid;

            IF @PendingAmount < 0
                SET @PendingAmount = 0;

            SELECT
                @ReservedAmount = ISNULL(SUM(ISNULL(PaidAmount, 0)), 0)
            FROM dbo.InvestorPaymentRequests WITH (UPDLOCK, HOLDLOCK)
            WHERE UserId = @UserId
              AND Status = 'Pending'
              AND RequestId <> @PaymentRequestId;

            SET @ReservedAmount = ISNULL(@ReservedAmount, 0);
            SET @AvailableAmount = @PendingAmount - @ReservedAmount;

            IF @AvailableAmount < 0
                SET @AvailableAmount = 0;

            IF ISNULL(@IsFullSettlement, 0) = 1
            BEGIN
                IF ISNULL(@DiscountAmount, 0) >= @AvailableAmount
                BEGIN
                    SET @ExceptionMessage =
                        'Discount amount must be less than the available pending amount. Available pending amount is '
                        + CAST(@AvailableAmount AS VARCHAR(50))
                        + '.';
                    THROW 50003,
                        'Discount amount must be less than the pending amount.',
                        1;
                END;

                SET @SettlementAmount =
                    @AvailableAmount - ISNULL(@DiscountAmount, 0);

                IF @PaidAmount <> @SettlementAmount
                BEGIN
                    SET @ExceptionMessage =
                        'Paid amount must match the final settlement amount. Expected amount is '
                        + CAST(@SettlementAmount AS VARCHAR(50))
                        + '.';
                    THROW 50004,
                        'Paid amount does not match the settlement amount.',
                        1;
                END;
            END
            ELSE
            BEGIN
                IF @PaidAmount > @AvailableAmount
                BEGIN
                    SET @ExceptionMessage =
                        'Paid amount cannot be greater than the pending amount. Pending amount is '
                        + CAST(@AvailableAmount AS VARCHAR(50))
                        + '.';
                    THROW 50006,
                        'Paid amount exceeds pending amount.',
                        1;
                END;
            END;

            SELECT
                @PaymentEntryNo = ISNULL(MAX(ISNULL(EntryNo, 0)), 0) + 1
            FROM dbo.AccountTransaction WITH (UPDLOCK, HOLDLOCK);

            IF @PaymentEntryNo IS NULL OR @PaymentEntryNo <= 0
                SET @PaymentEntryNo = 1;

            IF ISNULL(@IsFullSettlement, 0) = 1
            BEGIN
                INSERT INTO dbo.AccountTransaction
                (
                    [Date],
                    [Name],
                    [Type],
                    [EntryNo],
                    [DebitAmount],
                    [CreditAmount],
                    [Narration],
                    [PaymentMethod],
                    [ExtraAmount],
                    [Days],
                    [Createdby],
                    [CreatedDate]
                )
                VALUES
                (
                    GETDATE(),
                    @UserId,
                    'Payment',
                    @PaymentEntryNo,
                    @PaidAmount,
                    0,
                    ISNULL(@Narration, 'Investor Full Settlement'),
                    @PaymentMethod,
                    ISNULL(@ExtraAmount, 0),
                    ISNULL(@Days, 0),
                    @Createdby,
                    GETDATE()
                );

                INSERT INTO dbo.InvestorSettlement
                (
                    UserId,
                    InvestmentAmount,
                    PreviouslyPaidAmount,
                    DiscountAmount,
                    SettlementAmount,
                    PaymentEntryNo,
                    Remarks,
                    CreatedBy,
                    CreatedDate
                )
                VALUES
                (
                    @UserId,
                    @TotalInvestment,
                    @TotalPaid,
                    ISNULL(@DiscountAmount, 0),
                    @SettlementAmount,
                    @PaymentEntryNo,
                    @RequestRemarks,
                    @Createdby,
                    GETDATE()
                );
            END
            ELSE
            BEGIN
                INSERT INTO dbo.AccountTransaction
                (
                    [Date],
                    [Name],
                    [Type],
                    [EntryNo],
                    [DebitAmount],
                    [CreditAmount],
                    [Narration],
                    [MedicalAllowance],
                    [PaymentMethod],
                    [ExtraAmount],
                    [Days],
                    [Createdby],
                    [CreatedDate]
                )
                VALUES
                (
                    GETDATE(),
                    @UserId,
                    'Payment',
                    @PaymentEntryNo,
                    @PaidAmount,
                    0,
                    ISNULL(@Narration, 'Investor Payment'),
                    @MedicalAllowance,
                    @PaymentMethod,
                    ISNULL(@ExtraAmount, 0),
                    ISNULL(@Days, 0),
                    @Createdby,
                    GETDATE()
                );
            END;

            UPDATE dbo.InvestorPaymentRequests
            SET
                Status = 'Approved',
                ReviewedBy = @Createdby,
                ReviewedDate = GETDATE(),
                ReviewRemarks = NULLIF(LTRIM(RTRIM(@Remarks)), ''),
                PaymentEntryNo = @PaymentEntryNo
            WHERE RequestId = @PaymentRequestId
              AND Status = 'Pending'
              AND ISNULL(PaymentEntryNo, 0) = 0;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @ExceptionMessage =
                    'Payment request not found or is no longer pending.';
                THROW 50008,
                    'Payment request not found or is no longer pending.',
                    1;
            END;
        END;

        SELECT
            @TotalInvestment = ISNULL(SUM(ISNULL(CreditAmount, 0)), 0)
        FROM dbo.AccountTransaction
        WHERE Name = @UserId
          AND Type = 'Investment';

        /* Net paid excludes Rejected payment verifications. */
        SET @TotalPaid = dbo.fn_InvestorNetPaidAmount(@UserId);

        SELECT
            @TotalRefunded = ISNULL(SUM(ISNULL(RefundAmount, 0)), 0)
        FROM dbo.InvestorRefund
        WHERE UserId = @UserId;

        SET @TotalPaid = ISNULL(@TotalPaid, 0);

        IF @TotalPaid < 0
            SET @TotalPaid = 0;

        SET @RequestId = @PaymentRequestId;

        SELECT
            UR.UserId,
            UR.InvestorCode,
            UR.FullName,
            CAST(ISNULL(@TotalInvestment, 0) AS DECIMAL(18, 2))
                AS TotalInvestmentAmount,
            CAST(@TotalPaid AS DECIMAL(18, 2)) AS TotalPaidAmount,
            CAST(
                CASE
                    WHEN EXISTS
                    (
                        SELECT 1
                        FROM dbo.InvestorSettlement S
                        WHERE S.UserId = UR.UserId
                    )
                    THEN 0
                    WHEN ISNULL(@TotalInvestment, 0) - @TotalPaid > 0
                        THEN ISNULL(@TotalInvestment, 0) - @TotalPaid
                    ELSE 0
                END
                AS DECIMAL(18, 2)
            ) AS RemainingAmount,
            @PaidAmount AS PaidAmount,
            @PaymentMethod AS PaymentMethod,
            @RequestId AS RequestId,
            @Status AS Status,
            ISNULL(@PaymentEntryNo, 0) AS EntryNo
        FROM dbo.UserRegistration UR
        WHERE UR.UserId = @UserId
          AND UR.UserRole = 'Investor';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @IsException = 1;

        IF @ExceptionMessage IS NULL
            SET @ExceptionMessage = ERROR_MESSAGE();

        RETURN;
    END CATCH;

    RETURN;
END;

IF @Action = 20
BEGIN
    IF @Status IS NULL OR LTRIM(RTRIM(@Status)) = ''
        SET @Status = 'All';

    SELECT
        R.RequestId,
        R.UserId,
        UR.InvestorCode,
        UR.FullName,
        UR.Email,
        UR.PhoneNumber,
        CAST(UR.IsActive AS BIT) AS IsActive,
        R.Status,
        R.Remarks,
        R.RequestedDate,
        R.RequestedBy,
        RB.FullName AS RequestedByName,
        R.ReviewedBy,
        RV.FullName AS ReviewedByName,
        R.ReviewedDate,
        R.ReviewRemarks
    FROM dbo.InvestorBlockRequests R
    INNER JOIN dbo.UserRegistration UR
        ON UR.UserId = R.UserId
    LEFT JOIN dbo.UserRegistration RB
        ON RB.UserId = R.RequestedBy
    LEFT JOIN dbo.UserRegistration RV
        ON RV.UserId = R.ReviewedBy
    WHERE @Status = 'All'
       OR R.Status = @Status
    ORDER BY R.RequestId DESC;

    RETURN;
END;

IF @Action = 21
BEGIN
    IF @BlockRequestId IS NULL OR @BlockRequestId <= 0
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Block request id is required.';
        RETURN;
    END;

    SET @Status = LTRIM(RTRIM(ISNULL(@Status, '')));

    IF @Status NOT IN ('Approved', 'Rejected')
    BEGIN
        SET @IsException = 1;
        SET @ExceptionMessage = 'Status must be Approved or Rejected.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @UserId = R.UserId
        FROM dbo.InvestorBlockRequests R WITH (UPDLOCK, HOLDLOCK)
        WHERE R.RequestId = @BlockRequestId
          AND R.Status = 'Pending';

        IF @@ROWCOUNT = 0
        BEGIN
            SET @ExceptionMessage =
                'Block request not found or is no longer pending.';
            THROW 50028,
                'Block request not found or is no longer pending.',
                1;
        END;

        IF @Status = 'Rejected'
        BEGIN
            UPDATE dbo.InvestorBlockRequests
            SET
                Status = 'Rejected',
                ReviewedBy = @Createdby,
                ReviewedDate = GETDATE(),
                ReviewRemarks = NULLIF(LTRIM(RTRIM(@Remarks)), '')
            WHERE RequestId = @BlockRequestId
              AND Status = 'Pending';

            IF @@ROWCOUNT = 0
            BEGIN
                SET @ExceptionMessage =
                    'Block request not found or is no longer pending.';
                THROW 50028,
                    'Block request not found or is no longer pending.',
                    1;
            END;
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.UserRegistration WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId
                  AND UserRole = 'Investor'
            )
            BEGIN
                SET @ExceptionMessage = 'Investor not found.';
                THROW 50001, 'Investor not found.', 1;
            END;

            UPDATE dbo.UserRegistration
            SET
                IsActive = 0,
                ModifiedDate = GETDATE()
            WHERE UserId = @UserId
              AND UserRole = 'Investor';

            UPDATE dbo.InvestorBlockRequests
            SET
                Status = 'Approved',
                ReviewedBy = @Createdby,
                ReviewedDate = GETDATE(),
                ReviewRemarks = NULLIF(LTRIM(RTRIM(@Remarks)), '')
            WHERE RequestId = @BlockRequestId
              AND Status = 'Pending';

            IF @@ROWCOUNT = 0
            BEGIN
                SET @ExceptionMessage =
                    'Block request not found or is no longer pending.';
                THROW 50028,
                    'Block request not found or is no longer pending.',
                    1;
            END;
        END;

        SELECT
            R.RequestId,
            R.UserId,
            UR.FullName,
            CAST(UR.IsActive AS BIT) AS IsActive,
            R.Status,
            R.ReviewedBy,
            R.ReviewedDate,
            R.ReviewRemarks
        FROM dbo.InvestorBlockRequests R
        INNER JOIN dbo.UserRegistration UR
            ON UR.UserId = R.UserId
        WHERE R.RequestId = @BlockRequestId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @IsException = 1;

        IF @ExceptionMessage IS NULL
            SET @ExceptionMessage = ERROR_MESSAGE();

        RETURN;
    END CATCH;

    RETURN;
END;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @IsException = 1;
        SET @ExceptionMessage = ERROR_MESSAGE();

    END CATCH
END



GO
SET NOEXEC OFF;
GO

/* ---------------- Verification (read-only) ---------------- */
SELECT CASE
           WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.Api_InvestorManage')) LIKE '%SN.StaffName%'
           THEN 'APPLIED: Action 18 returns StaffName'
           ELSE 'NOT APPLIED'
       END AS DeployResult;
GO

DECLARE @e BIT, @m NVARCHAR(500);
EXEC dbo.Api_InvestorManage
    @Action = 18,
    @Status = 'All',
    @IsException = @e OUTPUT,
    @ExceptionMessage = @m OUTPUT;
SELECT @e AS IsException, @m AS ExceptionMessage;
GO
