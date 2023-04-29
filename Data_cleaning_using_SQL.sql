/*

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM portfolio_project.dbo.Nashville_housing

---------------------------------------------------------------------------------------------------------------------

--Standardize Date format

SELECT Sale_date_converted, CONVERT(date,SaleDate)
FROM portfolio_project..Nashville_housing

ALTER TABLE Nashville_housing
ADD Sale_date_converted Date;

UPDATE Nashville_housing
SET Sale_date_converted = CONVERT(date,SaleDate)

---------------------------------------------------------------------------------------------------------------------

--populate property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..Nashville_housing a
JOIN portfolio_project..Nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..Nashville_housing a
JOIN portfolio_project..Nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress,1 ,CHARINDEX(',',PropertyAddress) -1 ) as address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM portfolio_project.dbo.Nashville_housing

ALTER TABLE Nashville_housing
ADD Propert_Split_address Nvarchar(255);

UPDATE Nashville_housing
SET Propert_Split_address = SUBSTRING(PropertyAddress,1 ,CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE Nashville_housing 
ADD Property_City_Address Nvarchar(255);

UPDATE Nashville_housing
SET Property_City_Address = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From portfolio_project..Nashville_housing


ALTER TABLE Nashville_housing
ADD Owner_Split_address Nvarchar(255);

UPDATE Nashville_housing
SET Owner_Split_address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE Nashville_housing 
ADD Owner_City_Address Nvarchar(255);

UPDATE Nashville_housing
SET Owner_City_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE Nashville_housing 
ADD Owner_state_Address Nvarchar(255);

UPDATE Nashville_housing
SET Owner_state_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio_project..Nashville_housing
Group By SoldAsVacant
Order BY 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END
From portfolio_project..Nashville_housing

UPDATE Nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END

--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID	
				) row_num

From portfolio_project..Nashville_housing
)
DELETE  
FROM RowNumCTE
Where row_num >1

-------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

Select *
From portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 