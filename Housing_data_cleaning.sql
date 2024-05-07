/*
This project is aimed to clean the Housing Data step by step after importing it into MSSQL database table from Excel
*/

Select *
From PortfolioProject.dbo.HousingData

/* #1	- Standardize Date Format - The datatype of 'SaleDate' column when imported is 'Datetime' and the column values includes timestamps as yyyy-mm-dd 00:00:00. To make the date value readable and usable, a new column 'SaleDateConverted' is created with 'Date' datatype and 'SaleDate' values were converted to 'Date' type and inserted into the new column. Now the date values are standardized to yyyy-mm-dd format.
*/

ALTER TABLE PortfolioProject.dbo.HousingData
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

/* #2 - Its noted for few properties there were two records with identical 'Parcel ID' but one with a NULL value for PropertyAddress'. This query populates the property address for a null value record from the other record that has a value in it.
*/

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/* #3 - Property address stored in one column as '<Property No> <Street Addr>, <County>' is split into 3 columns as 'Address', 'City' and 'State'. The address is now more readable and easy to handle it in SQL queries.
*/

Select PropertyAddress, SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))
From PortfolioProject.dbo.HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress Nvarchar(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity Nvarchar(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
ADD OwnerSplitAddress Nvarchar(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingData
ADD OwnerSplitCity Nvarchar(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HousingData
ADD OwnerSplitState Nvarchar(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

/* #4 -	The column "Sold as Vacant" stores a boolean value 'Y' for Yes and 'N' for No. Below query updates the value 'Y' to 'Yes' AND 'N' to 'No'. This makes the values more readable.
*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

/* #5 -  There were duplicate records identified for one sale of a property. Below query is built to remove the duplicates
*/

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID
	)row_num
From PortfolioProject.dbo.HousingData
)
DELETE FROM RowNumCTE
WHERE row_num > 1

/* #6 - Four columns were identified of no use so dropping those columns to clear the unwanted data
*/

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

Select *
From PortfolioProject.dbo.HousingData
