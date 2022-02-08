
--cleaning data in sql queries 

Select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER Table NashvilleHousing
Alter Column SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address data

--Some Addresse's are null and since we might have the address with a previous owner we can copy prior owner's address to the null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


--CHARINDEX will search whatever character/string you want to look for. The -1 is the -1 position to get rid of the comma in the output,
--otherwise the output would include the comma
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address 
From PortfolioProject.dbo.NashvilleHousing


ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER Table NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing 
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

Select * 
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing



--Another way to seperate columnn info based on commas. Note that PARSENAME is meant to seperate on periods, 
--so you have to convert commas to periods.
SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 
from PortfolioProject.dbo.NashvilleHousing


ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER Table NashvilleHousing 
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing 
SET OwnerSplitCity =  PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER Table NashvilleHousing 
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing 
SET OwnerSplitState =  PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 

SELECT * 
From PortfolioProject.dbo.NashvilleHousing




--Replacing words/letters as needed. In this case we are replacing just the n and y in the soldasvacant colunmn to No and Yes. 

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant 
order by 2


SELECT SoldAsVacant 
, CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	   When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant 
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	   When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant 
	   END


--Remove Duplicates Be careful in normal databases, we don't always want to delete duplicates 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY 
						UniqueID)row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
) 
Select *
--use the delete to delete everything, but comment it out and use the select * to verify all the dups have been deleted
--Delete
FROM RowNumCTE
Where row_num > 1 
--Order by PropertyAddress 





--Don't delete columns  from regular databases as that is bad practice, but this is how you would do it


SELECT * 
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
