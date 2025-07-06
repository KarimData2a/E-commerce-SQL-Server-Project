USE EcommerceDB;
GO

-- =======================================
-- CA total par mois
-- =======================================

SELECT
    YEAR(DateCommande) as Annee,
    MONTH(DateCommande)as Mois,
    SUM(MontantTotal)  as ChiffreAffaires
FROM
    Commandes
WHERE
    Statut = 'Livrée'
GROUP BY
    YEAR(DateCommande), MONTH(DateCommande)
ORDER BY Mois





-- =======================================
--  Top 10 clients par CA
-- =======================================

SELECT TOP 10
    C.ClientID,
    C.Prenom,
    C.Nom,
    SUM(Co.MontantTotal) as TotalAchats
FROM
    Clients C
JOIN
    Commandes Co on C.ClientID = Co.ClientID
WHERE
    Co.Statut = 'Livrée'
GROUP BY
    C.ClientID, C.Prenom, C.Nom
ORDER BY
    TotalAchats desc 



-- =======================================
-- Produits les plus retournés
-- =======================================

SELECT
    P.ProduitID,
    P.NomProduit,
    COUNT(R.RetourID) as NbRetours
FROM
    Produits P
JOIN
    Retours R on P.ProduitID = R.ProduitID
GROUP BY
    P.ProduitID, P.NomProduit
ORDER BY
    NbRetours desc




-- =======================================
-- Ruptures de stock potentielles: min 5 qté en stocks
-- =======================================

SELECT
    P.ProduitID,
    P.NomProduit,
    S.QuantiteEnStock
FROM
    Produits P
JOIN
    Stocks S on P.ProduitID = S.ProduitID
WHERE
    S.QuantiteEnStock < 5
ORDER BY
    S.QuantiteEnStock asc 




-- =======================================
-- Impact des promotions sur les ventes
-- =======================================

WITH Commandes_Promo as (
    SELECT
        L.ProduitID,
        COUNT(DISTINCT L.CommandeID) as NbCommandes
    FROM
        Lignes_Commandes L
    JOIN
        Promotions P on L.ProduitID = P.ProduitID
    WHERE
        P.DateDebut <= GETDATE()
        and P.DateFin >= GETDATE()
    GROUP BY
        L.ProduitID
)
SELECT
    Pr.ProduitID,
    Pr.NomProduit,
    CP.NbCommandes,
    P.PourcentageReduction
FROM
    Produits Pr
JOIN
    Commandes_Promo CP on Pr.ProduitID = CP.ProduitID
JOIN
    Promotions P on Pr.ProduitID = P.ProduitID



-- =======================================
-- Montant moyen par panier
-- =======================================

SELECT
    AVG(MontantTotal) as PanierMoyen
FROM
    Commandes
WHERE
    Statut = 'Livrée'



-- =======================================
-- Clients avec commandes annulées
-- =======================================

SELECT
    C.ClientID,
    C.Prenom,
    C.Nom,
    COUNT(Co.CommandeID) as NbCommandesAnnulees
FROM
    Clients C
JOIN
    Commandes Co on C.ClientID = Co.ClientID
WHERE
    Co.Statut = 'Annulée'
GROUP BY
    C.ClientID, C.Prenom, C.Nom
ORDER BY
    NbCommandesAnnulees desc




-- =======================================
-- Vue – CA par produit
-- =======================================

CREATE OR ALTER VIEW V_CA_Produit as
SELECT
    P.ProduitID,
    P.NomProduit,
    SUM(L.Quantite * L.PrixUnitaire) as CA_Produit
FROM
    Produits P
JOIN
    Lignes_Commandes L on P.ProduitID = L.ProduitID
JOIN
    Commandes C on L.CommandeID = C.CommandeID
WHERE
    C.Statut = 'Livrée'
GROUP BY
    P.ProduitID, P.NomProduit




-- =======================================
-- Exemple fonction de fenêtrage – RANK top ventes
-- =======================================

SELECT
    ProduitID,
    NomProduit,
    CA_Produit,
    RANK() OVER (ORDER BY CA_Produit DESC) as Rang
FROM
    V_CA_Produit




-- ============================================
-- CTE : Calculer CA par client
-- ============================================

WITH CA_Par_Client as (
    SELECT
        C.ClientID,
        C.Prenom,
        C.Nom,
        SUM(Co.MontantTotal) as Total_CA
    FROM
        Clients C
    JOIN
        Commandes Co on C.ClientID = Co.ClientID
    WHERE
        Co.Statut = 'Livrée'
    GROUP BY
        C.ClientID, C.Prenom, C.Nom
)

-- ============================================
-- Requête principale : RANK() sur le CA total
-- ============================================

SELECT
    ClientID,
    Prenom,
    Nom,
    Total_CA,
    RANK() OVER (ORDER BY Total_CA DESC) as Rang
FROM
    CA_Par_Client
ORDER BY
    Rang;

