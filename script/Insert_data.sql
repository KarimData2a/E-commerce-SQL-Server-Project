USE EcommerceDB;
GO




-- 1) Remplir la table Clients : 5 000 clients

DECLARE @i INT = 1;

WHILE @i <= 5000
BEGIN
    INSERT INTO Clients (Prenom, Nom, Email, DateInscription, Pays)
    VALUES (
        'Prenom_' + CAST(@i AS NVARCHAR(10)),
        'Nom_' + CAST(@i AS NVARCHAR(10)),
        'client' + CAST(@i AS NVARCHAR(10)) + '@mail.com',
        DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID())) % 3650, GETDATE()),
        CASE WHEN @i % 5 = 0 THEN 'France'
             WHEN @i % 5 = 1 THEN 'Allemagne'
             WHEN @i % 5 = 2 THEN 'Espagne'
             WHEN @i % 5 = 3 THEN 'Italie'
             ELSE 'Belgique'
        END
    );
    SET @i += 1;
END

-- contrôle 
select * from Clients




-- 2) Remplir la table Produits: 1000 produits

DECLARE @i INT = 1;

SET @i = 1;

WHILE @i <= 1000
BEGIN
    INSERT INTO Produits (NomProduit, Categorie, Prix, DateAjout)
    VALUES (
        'Produit_' + CAST(@i AS NVARCHAR(10)),
        CASE WHEN @i % 4 = 0 THEN 'Electronique'
             WHEN @i % 4 = 1 THEN 'Maison'
             WHEN @i % 4 = 2 THEN 'Vêtements'
             ELSE 'Livres'
        END,
        ROUND(10 + (RAND() * 990), 2), -- prix entre 10 et 1000
        DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID())) % 1460, GETDATE())
    );
    SET @i += 1;
END

-- contrôle 
select * from Produits





-- 3) Remplir la table Stocks
--un stock par produit

DECLARE @i INT = 1;

SET @i = 1;

WHILE @i <= 1000
BEGIN
    INSERT INTO Stocks (ProduitID, QuantiteEnStock)
    VALUES (
        @i,
        ABS(CHECKSUM(NEWID())) % 500 -- stock entre 0 et 500
    );
    SET @i += 1;
END


-- contrôle 
select * from Stocks



-- 4) Remplir la table Commandes: 50 000 commandes

DECLARE @i INT = 1;

SET @i = 1;

WHILE @i <= 50000
BEGIN
    DECLARE @ClientID INT = 1 + ABS(CHECKSUM(NEWID())) % 5000;
    DECLARE @DateCommande DATE = DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID())) % 1460, GETDATE());
    DECLARE @MontantTotal DECIMAL(12,2) = 0; -- sera recalculé ensuite

    INSERT INTO Commandes (ClientID, DateCommande, Statut, MontantTotal)
    VALUES (
        @ClientID,
        @DateCommande,
        CASE WHEN @i % 10 = 0 THEN 'Annulée'
             WHEN @i % 10 = 1 THEN 'En préparation'
             ELSE 'Livrée'
        END,
        @MontantTotal
    );

    SET @i += 1;
END

-- contrôle
select * from Commandes




-- 5) Remplir la table Lignes_Commandes : 200 000 lignes de commandes
-- 4 lignes par commande en moyenne


DECLARE @i INT = 1;
SET @i = 1;

WHILE @i <= 10000
BEGIN
    DECLARE @NbLignes INT = 1 + ABS(CHECKSUM(NEWID())) % 5; -- 1 à 5 produits par commande
    DECLARE @j INT = 1;

    WHILE @j <= @NbLignes
    BEGIN
        DECLARE @ProduitID INT = 1 + ABS(CHECKSUM(NEWID())) % 1000;
        DECLARE @Quantite INT = 1 + ABS(CHECKSUM(NEWID())) % 10;
        DECLARE @PrixUnitaire DECIMAL(10,2) = (SELECT Prix FROM Produits WHERE ProduitID = @ProduitID);

        INSERT INTO Lignes_Commandes (CommandeID, ProduitID, Quantite, PrixUnitaire)
        VALUES (
            @i,
            @ProduitID,
            @Quantite,
            @PrixUnitaire
        );

        SET @j += 1;
    END

    SET @i += 1;
END



-- contrôle
select * from Lignes_Commandes





-- 6) Remplir la table Retours : 2 000 retours

DECLARE @i INT = 1;

SET @i = 1;

WHILE @i <= 2000
BEGIN
    DECLARE @CommandeID INT = 1 + ABS(CHECKSUM(NEWID())) % 10000; -- sur 10k commandes déjà insérées
    DECLARE @ProduitID INT = 1 + ABS(CHECKSUM(NEWID())) % 1000;

    INSERT INTO Retours (CommandeID, ProduitID, DateRetour, Raison, MontantRembourse)
    VALUES (
        @CommandeID,
        @ProduitID,
        DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID())) % 365, GETDATE()),
        'Produit non conforme',
        ROUND(10 + (RAND() * 200), 2)
    );

    SET @i += 1;
END



select * from Retours





-- 7) Remplir la table Promotions: 50 promos


DECLARE @i INT = 1;
SET @i = 1;

WHILE @i <= 50
BEGIN
    DECLARE @ProduitID INT = 1 + ABS(CHECKSUM(NEWID())) % 1000;
    DECLARE @Start DATE = DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID())) % 365, GETDATE());
    DECLARE @End DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 30, @Start);

    INSERT INTO Promotions (ProduitID, PourcentageReduction, DateDebut, DateFin)
    VALUES (
        @ProduitID,
        5 + ABS(CHECKSUM(NEWID())) % 50, -- entre 5% et 50%
        @Start,
        @End
    );

    SET @i += 1;
END


select * from Promotions
