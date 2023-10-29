SELECT *
FROM NashvilleHousing;

desc NashvilleHousing;

SELECT SaleDate, CONVERT(SaleDate,DATE)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing ADD SaleDateConvert DATE AFTER PropertyAddress;

UPDATE NashvilleHousing
SET SaleDateConvert = CONVERT(SaleDate,DATE);

ALTER TABLE NashvilleHousing DROP SaleDate;

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousing
ORDER BY Parcel_id;

SELECT t1.Parcel_id, t1.PropertyAddress, t2.Parcel_id, t2.PropertyAddress, IFNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleHousing as t1
INNER JOIN NashvilleHousing as t2
ON t1.Parcel_id = t2.Parcel_id
AND t1.Unique_id <> t2.Unique_id
WHERE t1.PropertyAddress IS NULL;


UPDATE NashvilleHousing as t1 INNER JOIN NashvilleHousing as t2
ON t1.Parcel_id = t2.Parcel_id AND t1.Unique_id <> t2.Unique_id
SET t1.PropertyAddress = IFNULL(t1.PropertyAddress, t2.PropertyAddress)
WHERE t1.PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT SUBSTR(PropertyAddress, 1, LOCATE(',',PropertyAddress) -1) as Adress,
SUBSTR(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress))  as City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing ADD PropertyCity VARCHAR(255) AFTER PropertyAddress;

UPDATE NashvilleHousing
SET PropertyCity = SUBSTR(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress));

UPDATE NashvilleHousing
SET PropertyAddress = SUBSTR(PropertyAddress, 1, LOCATE(',',PropertyAddress) -1);

SELECT PropertyAddress FROM NashvilleHousing;

SELECT OwnerAddress 
FROM NashvilleHousing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1 ) as Owner_Adress,
SUBSTRING_INDEX(OwnerAddress, ',', -1 ) as OwnerState,
FROM NashvilleHousing;

SELECT SUBSTRING_INDEX(t1.Owner_City, ',', 1) as OwnerCity
FROM (SELECT SUBSTRING_INDEX(OwnerAddress, ',', -2 ) as Owner_City FROM NashvilleHousing) as t1;

ALTER TABLE NashvilleHousing ADD OwnerAdressSplit VARCHAR(255) AFTER OwnerAddress;
ALTER TABLE NashvilleHousing ADD OwnerCity VARCHAR(255) AFTER OwnerAdressSplit;
ALTER TABLE NashvilleHousing ADD OwnerState VARCHAR(255) AFTER OwnerCity;

UPDATE NashvilleHousing
SET OwnerAdressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);
UPDATE NashvilleHousing
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1 );

UPDATE NashvilleHousing as n JOIN (SELECT Unique_id, SUBSTRING_INDEX(OwnerAddress, ',', -2 ) as Owner_City FROM NashvilleHousing) as t1
ON n.Unique_id = t1.Unique_id
SET n.OwnerCity = SUBSTRING_INDEX(t1.Owner_City, ',', 1);

-- both for some reason stuck in endless processing

/*CREATE TEMPORARY TABLE OwnerCity (owner_id int, owner_city VARCHAR(255));

INSERT INTO OwnerCity (owner_id, owner_city)
SELECT t1.Unique_id, SUBSTRING_INDEX(t1.Owner_City, ',', 1)
FROM (SELECT Unique_id, SUBSTRING_INDEX(OwnerAddress, ',', -2 ) as Owner_City FROM NashvilleHousing) as t1;

SELECT * FROM OwnerCity;

UPDATE NashvilleHousing JOIN OwnerCity ON NashvilleHousing.Unique_id = OwnerCity.owner_id
SET NashvilleHousing.OwnerCity = OwnerCity.owner_city;*/

SELECT * FROM NashvilleHousing;

SELECT DISTINCT SoldAsVacant 
FROM NashvilleHousing;

SELECT SoldAsVacant,
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end 
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end;

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing;

SELECT COUNT(*)
FROM NashvilleHousing
GROUP BY Parcel_id, PropertyAddress, SaleDateConvert, LegalReference
HAVING COUNT(*) > 1;
-- 104 rows 

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY Parcel_id, PropertyAddress, SaleDateConvert, LegalReference) as row_num
FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;
-- 104 rows

DELETE FROM NashvilleHousing
WHERE Unique_id IN
(
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY Parcel_id, PropertyAddress, SaleDateConvert, LegalReference) as row_num
FROM NashvilleHousing
)

SELECT Unique_id
FROM RowNumCTE
WHERE row_num > 1
);

SELECT COUNT(*)
FROM NashvilleHousing
GROUP BY Parcel_id, PropertyAddress, SaleDateConvert, LegalReference
HAVING COUNT(*) > 1;
-- 0 rows

SELECT * FROM NashvilleHousing;