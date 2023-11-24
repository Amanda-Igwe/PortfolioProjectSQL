SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


 /*

 Cleaning Data in SQL Queries

 */


 Select *
 From PortfolioProject.dbo.NashvilleHousing


 --Standardize Date format using the CONVERT function instead of CAST 


 Select SaleDateConverted, CONVERT(Date, SaleDate)
 From PortfolioProject.dbo.NashvilleHousing


 Update NashvilleHousing 
 SET SaleDate = CONVERT(Date, SaleDate)


 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;

 Update NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)



 --Populate Property Address data
 Select *
 From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, z.ParcelID, z.PropertyAddress, ISNULL(a.PropertyAddress, z.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing z
	on a.ParcelID = z.ParcelID
	AND a.[UniqueID] <> z.[UniqueID]
Where  a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, z.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing z
	on a.ParcelID = z.ParcelID
	AND a.[UniqueID] <> z.[UniqueID]
Where  a.PropertyAddress is null




--Breaking out Address into Individual columns (Address, City, State)

Select PropertyAddress
 From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


--Creating two colunmns for Address 

ALTER TABLE NashvilleHousing
 Add PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



 
ALTER TABLE NashvilleHousing
 Add PropertySplitCity Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




 Select *

From PortfolioProject.dbo.NashvilleHousing


--Splitting Owner Address Column

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)



 
ALTER TABLE NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

 
 ALTER TABLE NashvilleHousing
 Add OwnerSplitState Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


 --Run the query to see the changes 
 Select *
From PortfolioProject.dbo.NashvilleHousing



--Lets change Y and N to Yes and No in 'Sold as vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


--Replacing the Y and N to Yes and No

Select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END



--Removing Duplicates

WITH RowNumCTE AS (
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
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
--Select *  We change here to DELETE in other to delete the 104 rows populated that are duplicates 
--DELETE ( Here we comment the delete to put Select again to recheck if there are any duplicates since 104 rows was deleted already)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress




--Deleting Unused Columns. Here, I will be deleting the OwnerAddress, TaxDistrict, PropertyAddress Column for practice.

Select *
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


-- Deleting the SaleDate Colunm as well 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate