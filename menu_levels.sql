-- Code from TSQL Fundamentals book
-- ensuring that database is dropped before creating one
USE master;

-- Drop database
IF DB_ID('Webshop') IS NOT NULL DROP DATABASE Webshop;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Starting assignment
CREATE DATABASE Webshop;

USE Webshop;

CREATE TABLE dbo.ProductGroup
(
  ProductGroupId INT NOT NULL,
  ProductGroup VARCHAR(256) NOT NULL,
  ProductGroupParentId INT,
  CONSTRAINT PK_ProductGroupId
    PRIMARY KEY(ProductGroupId)
);

CREATE TABLE dbo.Product
(
  ProductId INT NOT NULL IDENTITY,
  Product VARCHAR(256) NOT NULL,
  Price MONEY NOT NULL,
  ProductGroupId INT NOT NULL,
  CONSTRAINT PK_ProcutId
    PRIMARY KEY(ProductId),
  CONSTRAINT FK_ProductId_ProductGroupId
    FOREIGN KEY(ProductGroupId)
    REFERENCES dbo.ProductGroup(ProductGroupId)
);

INSERT INTO dbo.ProductGroup (ProductGroupId, ProductGroup, ProductGroupParentId)
  VALUES
    (1, 'Sound', null),
    (2, 'Dictaphone', 1),
    (3, 'Headsets', 1),
    (4, 'Loudspeakers', 1),
    (5, 'Wireless headsets', 3),
    (6, 'Headphones', 3),
    (7, 'PC Headsets', 3),
    (8, 'Keyboard', null);

SELECT
  L1.ProductGroup,
  L2.ProductGroup,
  L3.ProductGroup
FROM dbo.ProductGroup AS L1
   LEFT OUTER JOIN dbo.ProductGroup AS L2
    ON L1.ProductGroupId = L2.ProductGroupParentId
   LEFT OUTER JOIN dbo.ProductGroup AS L3
    ON L2.ProductGroupId = L3.Pr
  oductGroupParentId
WHERE L1.ProductGroupParentId IS NULL;