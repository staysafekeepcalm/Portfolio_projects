SELECT * FROM 
(SELECT Unique_id, PropertyCity
FROM NashvilleHousing) as t2
INNER JOIN 
(SELECT t1.Unique_id, SUBSTRING_INDEX(t1.Owner_City, ',', 1) as OwnerCity
FROM (SELECT Unique_id, SUBSTRING_INDEX(OwnerAddress, ',', -2 ) as Owner_City FROM NashvilleHousing) as t1) as t3
ON t2.Unique_id = t3.Unique_id;

CREATE TEMPORARY TABLE CompareCity (un_id INT, property_city VARCHAR(255), owner_city VARCHAR(255));

INSERT INTO CompareCity (un_id, property_city, owner_city)
SELECT t2.Unique_id, t2.PropertyCity, t3.OwnerCity FROM 
(SELECT Unique_id, PropertyCity
FROM NashvilleHousing) as t2
INNER JOIN 
(SELECT t1.Unique_id, SUBSTRING_INDEX(t1.Owner_City, ',', 1) as OwnerCity
FROM (SELECT Unique_id, SUBSTRING_INDEX(OwnerAddress, ',', -2 ) as Owner_City FROM NashvilleHousing) as t1) as t3
ON t2.Unique_id = t3.Unique_id;

with CitiesCTE as (SELECT *, if(property_city = owner_city, 1, 0) as Compare_cities
from CompareCity
-- WHERE owner_city IS NOT NULL
)

SELECT *
FROM CitiesCTE
WHERE Compare_cities <> 1
AND owner_city IS NOT NULL;

-- compare cities where houses sold and cities where owner live
-- only one deal

SELECT COUNT(DISTINCT Parcel_id)
FROM NashvilleHousing;

SELECT COUNT(DISTINCT Unique_id)
FROM NashvilleHousing;


WITH DoubleSalesCTE AS
(
SELECT Unique_id, Parcel_id, PropertyAddress, SaleDateConvert, SalePrice, 
ROW_NUMBER() OVER (PARTITION BY Parcel_id) as row_numb
FROM NashvilleHousing
)

SELECT *
FROM DoubleSalesCTE
WHERE row_numb > 1
ORDER BY 2;

CREATE TEMPORARY TABLE DoubleSalesParcelID (parcel_id VARCHAR(255));

INSERT INTO DoubleSalesParcelID (parcel_id)
WITH DoubleSalesCTE AS
(
SELECT Unique_id, Parcel_id, PropertyAddress, SaleDateConvert, SalePrice, 
ROW_NUMBER() OVER (PARTITION BY Parcel_id) as row_numb
FROM NashvilleHousing
)

SELECT Parcel_id
FROM DoubleSalesCTE
WHERE row_numb > 1
ORDER BY 1 ASC;

SELECT Unique_id, Parcel_id, PropertyAddress, SaleDateConvert, SalePrice
FROM NashvilleHousing
WHERE Parcel_id IN (SELECT * FROM DoubleSalesParcelID);

SELECT Unique_id, Parcel_id, PropertyAddress, SaleDateConvert, SalePrice, 
ROW_NUMBER() OVER (PARTITION BY Parcel_id) as row_numb
FROM NashvilleHousing
WHERE Parcel_id IN (SELECT * FROM DoubleSalesParcelID);

CREATE TEMPORARY TABLE DoubleSales (Unique_id INT, Parcel_id VARCHAR(255), PropertyAddress VARCHAR(255), 
PropertyCity VARCHAR(255),SaleDateConvert DATE, SalePrice INT, row_num INT);

INSERT INTO DoubleSales (Unique_id, Parcel_id, PropertyAddress, PropertyCity, SaleDateConvert, SalePrice, row_num)
SELECT Unique_id, Parcel_id, PropertyAddress, PropertyCity, SaleDateConvert, SalePrice, 
ROW_NUMBER() OVER (PARTITION BY Parcel_id ORDER BY SaleDateConvert) as row_numb
FROM NashvilleHousing
WHERE Parcel_id IN (SELECT * FROM DoubleSalesParcelID)
ORDER BY Parcel_id, SaleDateConvert ASC;

CREATE TEMPORARY TABLE TotalPriceDifference (Parcel_id VARCHAR(255), PropertyAddress VARCHAR(255), 
total_price_difference INT);

INSERT INTO TotalPriceDifference (Parcel_id, PropertyAddress, total_price_difference)
WITH PriceDiffCTE AS 
(
SELECT tt.Unique_id, tt.Parcel_id, tt.PropertyAddress, tt.SaleDateConvert, tt.SalePrice, tt.row_num,
if(tt.row_num = 1, n.SalePrice * -1, n.SalePrice) as for_count
FROM DoubleSales tt INNER JOIN NashvilleHousing n
ON tt.Unique_id = n.Unique_id
)

SELECT Parcel_id, PropertyAddress, sum(for_count) OVER (PARTITION BY Parcel_id) as total_price_difference
FROM PriceDiffCTE
WHERE row_num = 2;

CREATE TEMPORARY TABLE DoubleSales1 
SELECT * FROM DoubleSales;

SELECT t1.Parcel_id, t1.PropertyCity, tpd.total_price_difference, t1. SalePrice, 
round((tpd.total_price_difference/t1. SalePrice), 2)*100 as percent_of_grows,
round((DATEDIFF(t2.SaleDateConvert,t1.SaleDateConvert)/365), 1) as years_of_grows
FROM 
(SELECT *
FROM DoubleSales
WHERE row_num = 1) as t1
JOIN
(SELECT *
FROM DoubleSales1
WHERE row_num = 2) as t2
ON t1.Parcel_id = t2.Parcel_id
JOIN TotalPriceDifference as tpd
ON t2.Parcel_id = tpd.Parcel_id
ORDER BY 1, 3 ASC;

-- compare  difference in price between sales of same house in different transactions (also look by date of sale)

SELECT DISTINCT SaleDateConvert
FROM NashvilleHousing;

DELETE FROM NashvilleHousing
WHERE YEAR(SaleDateConvert) >= 2019;

SELECT SaleDateConvert, SUM(SalePrice)
FROM NashvilleHousing
GROUP BY SaleDateConvert
ORDER BY SaleDateConvert ASC;

-- look for most deals by date (also look by money)

SELECT PropertyCity, COUNT(PropertyCity), SUM(SalePrice)
FROM NashvilleHousing
GROUP BY PropertyCity;

-- look for number of transactions and revenue by city