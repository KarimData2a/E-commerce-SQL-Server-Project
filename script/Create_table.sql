-- ========================================
-- Base de données : E-commerce
-- Description : Création des tables




--  Créer la base de données 
IF DB_ID('EcommerceDB') IS NULL
    CREATE DATABASE EcommerceDB;
GO

USE EcommerceDB;
GO

----------------------
----- Table : Clients
----------------------


CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    Prenom NVARCHAR(50),
    Nom NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    DateInscription DATE,
    Pays NVARCHAR(50)
);


---------------------
-- Table : Produits
---------------------

CREATE TABLE Produits (
    ProduitID INT IDENTITY(1,1) PRIMARY KEY,
    NomProduit NVARCHAR(100),
    Categorie NVARCHAR(50),
    Prix DECIMAL(10,2),
    DateAjout DATE
);



-------------------
-- Table : Stocks
-------------------

CREATE TABLE Stocks (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    ProduitID INT FOREIGN KEY REFERENCES Produits(ProduitID),
    QuantiteEnStock INT
);



----------------------
-- Table : Commandes
----------------------

CREATE TABLE Commandes (
    CommandeID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT FOREIGN KEY REFERENCES Clients(ClientID),
    DateCommande DATE,
    Statut NVARCHAR(50),
    MontantTotal DECIMAL(12,2)
);




----------------------------
-- Table : Lignes_Commandes
----------------------------

CREATE TABLE Lignes_Commandes (
    LigneID INT IDENTITY(1,1) PRIMARY KEY,
    CommandeID INT FOREIGN KEY REFERENCES Commandes(CommandeID),
    ProduitID INT FOREIGN KEY REFERENCES Produits(ProduitID),
    Quantite INT,
    PrixUnitaire DECIMAL(10,2)
);



-----------------------
-- Table : Retours
-----------------------

CREATE TABLE Retours (
    RetourID INT IDENTITY(1,1) PRIMARY KEY,
    CommandeID INT FOREIGN KEY REFERENCES Commandes(CommandeID),
    ProduitID INT FOREIGN KEY REFERENCES Produits(ProduitID),
    DateRetour DATE,
    Raison NVARCHAR(255),
    MontantRembourse DECIMAL(10,2)
);



---------------------------
-- Table : Promotions
---------------------------

CREATE TABLE Promotions (
    PromoID INT IDENTITY(1,1) PRIMARY KEY,
    ProduitID INT FOREIGN KEY REFERENCES Produits(ProduitID),
    PourcentageReduction INT CHECK (PourcentageReduction BETWEEN 0 AND 100),
    DateDebut DATE,
    DateFin DATE
);


-----------------------------
-- Index supplémentaires
-----------------------------

-- Index sur colonnes utiles pour perfs
CREATE INDEX IX_Commandes_ClientID ON Commandes(ClientID);
CREATE INDEX IX_Commandes_DateCommande ON Commandes(DateCommande);
CREATE INDEX IX_Lignes_Commandes_ProduitID ON Lignes_Commandes(ProduitID);
CREATE INDEX IX_Stocks_ProduitID ON Stocks(ProduitID);


