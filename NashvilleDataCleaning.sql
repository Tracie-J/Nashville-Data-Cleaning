--Data Cleaning Process

--Look at raw data
SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------
--Standardize Date

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--Mispelled Converted the first time. Accidently created column 'SaleDateConveted' which will be removed later.

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------------

-- Populate Property Addresses

SELECT*
FROM NashvilleProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
c a
JOIN NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------

--Dividing address into (Address, City, State)

SELECT PropertyAddress
FROM NashvilleProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
FROM NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


SELECT*
FROM NashvilleProject.dbo.NashvilleHousing



SELECT OwnerAddress
FROM NashvilleProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


SELECT*
FROM NashvilleProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------

--Change Y & N to 'Yes' and 'No' in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

FROM NashvilleProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
--ORDER BY PropertyAddress

--Check to see if it worked.
WITH RowNumCTE as(
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

FROM NashvilleProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress




-----------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDateConveted

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN SaleDate