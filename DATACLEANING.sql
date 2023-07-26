
SELECT *
FROM nashvillehousing

-- CONVERTING DATA TYPES

SELECT SaleDate,CONVERT(date,SaleDate)
FROM NashvilleHousing

--date column must be converted to date type

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

--Populate Property Address data
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- WE FOUND OUT THAT THE SAME PARCEID HAVE THE SAME PROPETRYADRESS,SO...
--let's do join for the table to it self to be sure that values in propertyaddress typical for the same parceID

SELECT a.ParcelID , a.PropertyAddress,b.ParcelID,b.PropertyAddress,A.[UniqueID ],B.[UniqueID ]
FROM NashvilleHousing  a
	JOIN NashvilleHousing  b
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE a.PropertyAddress is null

--now let's update the null values

SELECT a.ParcelID , a.PropertyAddress,b.ParcelID,b.PropertyAddress,A.[UniqueID ],B.[UniqueID ], ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing  a
	JOIN NashvilleHousing  b
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing  a
	JOIN NashvilleHousing b
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX (',' ,PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX (',' ,PropertyAddress) + 1,  LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

--let's make Property Address seperated into two columns (using SUBSTRING & CHARINDEX)

ALTER TABLE nashvillehousing
ADD PropertySplitAddress nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX (',' ,PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',' ,PropertyAddress) + 1,  LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

--now Owner address need to be seperated as well ( using parsename )

SELECT owneraddress
FROM NashvilleHousing


SELECT 
PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),3),
PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),2),
PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),1)
FROM NashvilleHousing

--now let's create 3 new columns for spliting the owner address

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),3)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),2)

ALTER TABLE nashvillehousing
ADD OwnerSplitSate nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitSate = PARSENAME(REPLACE ( owneraddress, ',' ,'.' ),1)

SELECT *
FROM NashvilleHousing

--CHANGE Y AND N TO YES AND NO IN " soldAsVacant"
SELECT Distinct (SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
order by 2

select SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from NashvilleHousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

SELECT Distinct (SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
order by 2


--REMOVE DUPLICATES
--first let's find out how many rows duplicated 

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,propertyaddress,saleprice,saledate,legalreference 
	ORDER BY uniqueID ) as row_num

FROM NashvilleHousing
)
--now we will delete it using CTE
--DELETE 
--FROM ROWNUMCTE
--WHERE row_num > 1

SELECT *
FROM ROWNUMCTE
WHERE row_num > 1

--DELETE UNUSED COLUMNS 
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress,taxdistrict, propertyaddress, saledate

SELECT *
FROM NashvilleHousing











