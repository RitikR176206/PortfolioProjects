
/*

🏠 Nashville Housing SQL Data Cleaning Project
🔧 Tools Used
SQL Server

T-SQL

📘 Project Overview
This project focuses on cleaning and transforming a real-world housing dataset from Nashville using SQL. The goal was to prepare the dataset for further analysis and visualization (e.g., in Power BI) by resolving common data quality issues such as missing values, inconsistent formatting, and duplicates.

📊 Key Objectives
Standardize date formats

Impute missing property address values

Split compound address fields into separate columns (street, city, state)

Normalize categorical values (e.g., "Y" → "Yes", "N" → "No")

Identify and remove duplicate records

Drop unnecessary columns to streamline the dataset



*/


Select *
From NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- 🧠 Techniques Used
--1. Standardized Sale Date Format



ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


 --------------------------------------------------------------------------------------------------------------------------

--2.Imputed Missing Property Addresses
--Used a self-join on ParcelID to fill in missing PropertyAddress values:

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

	
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

--3. Split Address Fields into Individual Components
--Property Address:


Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));



--Owner Address using PARSENAME:

Select OwnerAddress
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



--------------------------------------------------------------------------------------------------------------------------
--4. Standardized 'SoldAsVacant' Field
-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

UPDATE NashvilleHousing
SET SoldAsVacant = 
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END;
_______________________________________________________________________________

Select SoldAsVacant, 
  CASE 
  When SoldAsVacant = 'Y' THEN 'Yes'
  When SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
END
From NashvilleHousing;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--5. Removed Duplicate Records
--Used ROW_NUMBER() in a CTE to identify duplicates based on key columns:

WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
         ) AS row_num
  FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;


select *
From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

--6. Dropped Unused Columns
	
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
/*✅ Final Outcome
The dataset is now clean, standardized, and ready for downstream usage in Power BI or other data visualization tools. Key outcomes:

✅ Enhanced data consistency and quality

✅ Better readiness for analysis and reporting

✅ Reduced noise by removing duplicates and irrelevant columns*/




