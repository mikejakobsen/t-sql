-- Code from TSQL Fundamentals book
-- ensuring that database is dropped before creating one
USE master;

-- Drop database
IF DB_ID('Shop') IS NOT NULL DROP DATABASE Shop;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Starting assignment
CREATE DATABASE Shop;
GO

USE Shop;

CREATE TABLE dbo.ShopOrder 
(
	OrderId INT PRIMARY KEY IDENTITY,
	CustomerId INT,
	OrderDate DATETIME,
	OrderTotal INT
);

CREATE TABLE dbo.ShopProduct
(
	ProductId INT PRIMARY KEY IDENTITY,
	ProductName NVARCHAR(50),
	ProductDescription NVARCHAR(150),
	ProductPrice MONEY,
	ProductStock INT
);

CREATE TABLE dbo.ShopOrderLine
(
	OrderLineId INT PRIMARY KEY IDENTITY,
	OrderId INT,
	ProductId INT,
	ProductPrice MONEY,
	ProductQuantity INT,
	ProductPriceSum MONEY,
	CONSTRAINT FK_ShopOrderLine_ShopProduct_ProductId
    FOREIGN KEY (ProductId) 
    REFERENCES ShopProduct(ProductId)
);
GO

CREATE TABLE dbo.ShopLog
(
  AuditLsn INT NOT NULL IDENTITY PRIMARY KEY,
  Dt DATETIME NOT NULL DEFAULT(SYSDATETIME()),
  LoginName sysname NOT NULL DEFAULT(ORIGINAL_LOGIN()),
  OrderId INT NOT NULL,
	CustomerId INT,
	OrderDate DATETIME,
	OrderTotal INT
);
GO

CREATE TRIGGER TriggerShopOrderInsertAudit ON dbo.ShopOrder AFTER INSERT
AS
SET NOCOUNT ON;
INSERT INTO dbo.ShopLog(OrderId, CustomerId, OrderDate, OrderTotal)
SELECT OrderId, CustomerId, OrderDate, OrderTotal FROM inserted
GO

CREATE TRIGGER TriggerShopOrderUpdateDelteAudit ON dbo.ShopOrder AFTER UPDATE, DELETE
AS
SET NOCOUNT ON;
INSERT INTO dbo.ShopLog(OrderId, CustomerId, OrderDate, OrderTotal)
SELECT OrderId, CustomerId, OrderDate, OrderTotal FROM inserted;
INSERT INTO dbo.ShopLog(OrderId, CustomerId, OrderDate, OrderTotal)
SELECT OrderId, CustomerId, OrderDate, OrderTotal FROM deleted;
GO

-- INSERT test data
INSERT INTO dbo.ShopProduct 
VALUES (N'Tattinger', N'Tattinger', 299.99, 10),
	(N'Cûvee', N'Cûvee', 250.50, 10),
	(N'Möet', N'Möet', 349.00, 10),
	(N'Bollinger', N'Bollinger', 475.00, 10);
GO

CREATE TYPE dbo.OrderLineTable AS TABLE(
	OrderLineId int NOT NULL IDENTITY(1, 1),
	ProductId int,
	ProductQuantity int
)
GO

CREATE PROCEDURE dbo.sprocCreateOrder
	@CustomerId int,
	@OrderLineTable OrderLineTable READONLY
	AS
	DECLARE @OrderId int
	DECLARE @StockError int
	
	BEGIN TRANSACTION
	
		INSERT INTO ShopOrder
		(CustomerId)
		VALUES
		(@CustomerId)
		
		SET @OrderId = SCOPE_IDENTITY();
		
		INSERT INTO ShopOrderLine
		(OrderId, ProductId, ProductQuantity, ProductPrice, ProductPriceSum)
		SELECT 
			@OrderId, 
			O.ProductId, 
			O.ProductQuantity, 
			SP.ProductPrice, 
			(SP.ProductPrice * O.ProductQuantity)
		FROM @OrderLineTable AS O
		INNER JOIN 
			ShopProduct AS SP ON SP.ProductId = O.ProductId
			
		UPDATE ShopOrder 
		SET OrderTotal = (SELECT 
							SUM(ProductPriceSum) 
							FROM ShopOrderLine
							WHERE OrderId = @OrderId
						)
		WHERE OrderId = @OrderId
				
		UPDATE ShopProduct
		SET ProductStock = (ProductStock - O.ProductQuantity)
		FROM (SELECT ProductId, ProductQuantity FROM @OrderLineTable) AS O
		INNER JOIN
			ShopProduct ON ShopProduct.ProductId = O.ProductId		
				
		SELECT @StockError = count(SP.ProductId)
		FROM ShopProduct AS SP
		INNER JOIN 
			@OrderLineTable AS O ON O.ProductId = SP.ProductId
		WHERE ProductStock < 0
		
		IF (@StockError > 0)
			BEGIN
				SELECT SP.ProductId, ProductStock AS NegativeProductStock
				FROM ShopProduct AS SP
				INNER JOIN 
					@OrderLineTable AS O ON O.ProductId = SP.ProductId
				WHERE ProductStock < 0

				ROLLBACK TRANSACTION
			END				
		ELSE
			BEGIN
				SELECT * FROM ShopOrder
				SELECT * FROM ShopOrderLine		
				SELECT * FROM ShopProduct	
				COMMIT TRANSACTION
			END
	GO
	
DECLARE @PurchasedProduct OrderLineTable;

-- Resetting the stocks
--UPDATE ShopProduct SET ProductStock = 20 WHERE ProductId = 1
--UPDATE ShopProduct SET ProductStock = 200 WHERE ProductId = 2

DELETE FROM dbo.ShopOrderLine
DELETE FROM dbo.ShopOrder

INSERT INTO @PurchasedProduct VALUES (1, 1), (2, 4)
EXEC sprocCreateOrder 1, @PurchasedProduct