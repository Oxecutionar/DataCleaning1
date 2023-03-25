
SELECT *
FROM PortfolioProject1..NashvilleHousing


--standardize date format

SELECT SaleDate, convert(date, saledate)
FROM PortfolioProject1..NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


--Populate Property Address data - uses ParcelID to populate PropAddress, used a self join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- Parsing out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject1..NashvilleHousing


--- takes above split and adds into separate columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- doing 2nd address, owner address, Address/city/state

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(Replace(OwnerAddress, ',', '.') , 3),
PARSENAME(Replace(OwnerAddress, ',', '.') , 2),
PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing

--creat new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

--populate columns
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change y and N to Yes and No in 'Sold as Vacant'

SELECT Distinct(SoldAsVacant), count(SoldAsvacant)
FROM NashvilleHousing
Group by Soldasvacant
order by 2

SELECT SoldAsVacant,
CASE	When SoldAsVacant = 'y' THEN 'Yes'
		When SoldAsVacant  = 'n' THEN 'No'
		else SoldAsvacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	When SoldAsVacant = 'y' THEN 'Yes'
		When SoldAsVacant  = 'n' THEN 'No'
		else SoldAsvacant
		END


-- Creates CTE to call later

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					uniqueID
					) row_num

FROM NashvilleHousing)

--- delete duplicate rows once placed in CTE
DELETE
FROM RowNumCTE
WHERE row_num > 1



--Delete unused columns

SELECT *
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN SaleDate







