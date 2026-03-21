IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;

                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'IsActive')
                BEGIN
                    ALTER TABLE Employees ADD IsActive BIT NOT NULL DEFAULT 1;
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Phone')
                BEGIN
                    ALTER TABLE Employees ADD Phone NVARCHAR(20) NOT NULL DEFAULT '';
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Position')
                BEGIN
                    ALTER TABLE Employees ADD Position NVARCHAR(100) NOT NULL DEFAULT '';
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'CreatedAt')
                BEGIN
                    ALTER TABLE Employees ADD CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE();
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'UpdatedAt')
                BEGIN
                    ALTER TABLE Employees ADD UpdatedAt DATETIME2 NULL;
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Salary')
                BEGIN
                    ALTER TABLE Employees ADD Salary DECIMAL(18,2) NULL;
                END
            


                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'HireDate')
                BEGIN
                    ALTER TABLE Employees ADD HireDate DATETIME2 NULL;
                END
            

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260304060619_AddMissingEmployeeColumns', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260305065210_UpdateEmployeeModel', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260305110125_AddGRN', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260305120228_AddRefundedQuantityToOrderItem', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260305162154_AddExpensesTable', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260306035748_SyncPendingModelChanges', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260306040407_ResolvePendingChanges', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260309052905_AddFinanceAndCostPrice', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260309095355_AddPayroll', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260309122733_AddPurchaseOrders', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260321095022_AddCategoryImageUrlOnly', N'10.0.3');

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260321115312_InitialCreate', N'10.0.3');
-- COMMIT;
GO




-- COMMIT;
GO

BEGIN TRANSACTION;

-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260306040407_ResolvePendingChanges', N'10.0.3');
-- COMMIT;
GO

BEGIN TRANSACTION;
-- ALTER TABLE [SaleItems] ADD [UnitCost] decimal(18,2) NOT NULL DEFAULT 0.0;

-- ALTER TABLE [Products] ADD [CostPrice] decimal(18,2) NOT NULL DEFAULT 0.0;


-- CREATE TABLE [Expenses] (
--     [Id] int NOT NULL IDENTITY,
--     [Description] nvarchar(max) NOT NULL,
--     [Amount] decimal(18,2) NOT NULL,
--     [Date] datetime2 NOT NULL DEFAULT (SYSUTCDATETIME()),
--     [Category] nvarchar(max) NOT NULL,
--     [CreatedBy] nvarchar(max) NULL,
--     CONSTRAINT [PK_Expenses] PRIMARY KEY ([Id])
-- );


-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260309052905_AddFinanceAndCostPrice', N'10.0.3');

COMMIT;
GO


-- BEGIN TRANSACTION;
-- CREATE TABLE [Payrolls] (
--     [Id] int NOT NULL IDENTITY,
--     [EmployeeId] int NOT NULL,
--     [MonthYear] nvarchar(max) NOT NULL,
--     [PeriodStart] datetime2 NOT NULL,
--     [PeriodEnd] datetime2 NOT NULL,
--     [BasicSalary] decimal(18,2) NOT NULL,
--     [WorkedDays] int NOT NULL,
--     [OvertimeHours] float NOT NULL,
--     [OvertimeRate] decimal(18,2) NOT NULL,
--     [Bonuses] decimal(18,2) NOT NULL,
--     [Advances] decimal(18,2) NOT NULL,
--     [OtherDeductions] decimal(18,2) NOT NULL,
--     [Epf8] decimal(18,2) NOT NULL,
--     [Tax] decimal(18,2) NOT NULL,
--     [Epf12] decimal(18,2) NOT NULL,
--     [Etf3] decimal(18,2) NOT NULL,
--     [NetSalary] decimal(18,2) NOT NULL,
--     [Status] int NOT NULL,
--     [GeneratedDate] datetime2 NOT NULL,
--     CONSTRAINT [PK_Payrolls] PRIMARY KEY ([Id]),
--     CONSTRAINT [FK_Payrolls_Employees_EmployeeId] FOREIGN KEY ([EmployeeId]) REFERENCES [Employees] ([Id]) ON DELETE CASCADE
-- );

-- CREATE TABLE [SalaryAdvances] (
--     [Id] int NOT NULL IDENTITY,
--     [EmployeeId] int NOT NULL,
--     [Amount] decimal(18,2) NOT NULL,
--     [Date] datetime2 NOT NULL,
--     [Note] nvarchar(500) NOT NULL,
--     [IsDeducted] bit NOT NULL,
--     [PayrollId] int NULL,
--     CONSTRAINT [PK_SalaryAdvances] PRIMARY KEY ([Id]),
--     CONSTRAINT [FK_SalaryAdvances_Employees_EmployeeId] FOREIGN KEY ([EmployeeId]) REFERENCES [Employees] ([Id]) ON DELETE CASCADE,
--     CONSTRAINT [FK_SalaryAdvances_Payrolls_PayrollId] FOREIGN KEY ([PayrollId]) REFERENCES [Payrolls] ([Id])
-- );

-- CREATE INDEX [IX_Payrolls_EmployeeId] ON [Payrolls] ([EmployeeId]);

-- CREATE INDEX [IX_SalaryAdvances_EmployeeId] ON [SalaryAdvances] ([EmployeeId]);

-- CREATE INDEX [IX_SalaryAdvances_PayrollId] ON [SalaryAdvances] ([PayrollId]);


-- INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
-- VALUES (N'20260309095355_AddPayroll', N'10.0.3');

COMMIT;
GO


-- BEGIN TRANSACTION;
-- CREATE TABLE [PurchaseOrders] (
--     [Id] int NOT NULL IDENTITY,
--     [SupplierId] int NOT NULL,
--     [OrderDate] datetime2 NOT NULL,
--     [Status] nvarchar(50) NOT NULL,
--     [TotalAmount] decimal(18,2) NOT NULL,
--     CONSTRAINT [PK_PurchaseOrders] PRIMARY KEY ([Id]),
--     CONSTRAINT [FK_PurchaseOrders_Suppliers_SupplierId] FOREIGN KEY ([SupplierId]) REFERENCES [Suppliers] ([Id]) ON DELETE NO ACTION
-- );

-- CREATE TABLE [PurchaseOrderItems] (
--     [Id] int NOT NULL IDENTITY,
--     [PurchaseOrderId] int NOT NULL,
--     [ProductId] int NOT NULL,
--     [Quantity] int NOT NULL,
--     [UnitCost] decimal(18,2) NOT NULL,
--     CONSTRAINT [PK_PurchaseOrderItems] PRIMARY KEY ([Id]),
--     CONSTRAINT [FK_PurchaseOrderItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE NO ACTION,
--     CONSTRAINT [FK_PurchaseOrderItems_PurchaseOrders_PurchaseOrderId] FOREIGN KEY ([PurchaseOrderId]) REFERENCES [PurchaseOrders] ([Id]) ON DELETE CASCADE
-- );

-- CREATE INDEX [IX_PurchaseOrderItems_ProductId] ON [PurchaseOrderItems] ([ProductId]);

-- CREATE INDEX [IX_PurchaseOrderItems_PurchaseOrderId] ON [PurchaseOrderItems] ([PurchaseOrderId]);

-- CREATE INDEX [IX_PurchaseOrders_SupplierId] ON [PurchaseOrders] ([SupplierId]);

COMMIT;
GO

BEGIN TRANSACTION;
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260309122733_AddPurchaseOrders', N'10.0.3');

COMMIT;
GO

BEGIN TRANSACTION;
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260321095022_AddCategoryImageUrlOnly', N'10.0.3');

COMMIT;
GO

BEGIN TRANSACTION;
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260321115312_InitialCreate', N'10.0.3');

COMMIT;
GO

