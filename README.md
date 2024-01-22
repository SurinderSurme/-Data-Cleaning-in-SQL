# -Data-Cleaning-in-SQL


## Overview

This set of SQL queries aims to perform various data operations on the 'Nashville$' table within the 'Portfolio Project' database. The operations include standardizing date formats, populating missing data, breaking down address columns, and updating categorical values.

---

## Standardize Date Format

### 1. Select Original and Converted SaleDate

- Selects original SaleDate and its converted format using the CONVERT function.
- Adds a new column 'SaleDateConverted' to the table and updates it with the converted SaleDate value
  
Select saleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project]..['Nashville'$]

ALTER TABLE  ['Nashville'$]
Add SaleDateConverted Date;

Update  ['Nashville'$]
SET SaleDateConverted = CONVERT(Date, SaleDate)

Populate Property Address Data
##  Select and Update PropertyAddress Data
### Selects all columns from the 'Nashville$' table.
### Populates missing PropertyAddress values by updating them from non-null instances with the same ParcelID.

Select *
From [Portfolio Project]..['Nashville'$]
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..['Nashville'$] a
JOIN [Portfolio Project]..['Nashville'$] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..['Nashville'$]a
JOIN [Portfolio Project]..['Nashville'$] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Breaking Out Address into Individual Columns (Address, City, State)
## Split PropertyAddress into Individual Columns
## Selects PropertyAddress and extracts its components (Address, City) into new columns.
## Adds new columns 'PropertySplitAddress' and 'PropertySplitCity' to the table.

Select PropertyAddress
From [Portfolio Project]..['Nashville'$]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Portfolio Project]..['Nashville'$]

ALTER TABLE ['Nashville'$]
Add PropertySplitAddress Nvarchar(255);

Update ['Nashville'$]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE ['Nashville'$]
Add PropertySplitCity Nvarchar(255);

Update ['Nashville'$]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
Standardize OwnerAddress and Break Out into Individual Columns
##  Standardize OwnerAddress and Split into Individual Columns
## Selects OwnerAddress and extracts its components (State, City, Address) into new columns.
## Adds new columns 'OwnerSplitAddress', 'OwnerSplitCity', and 'OwnerSplitState' to the table.

Select OwnerAddress
From [Portfolio Project]..['Nashville'$]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..['Nashville'$]

ALTER TABLE ['Nashville'$]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..['Nashville'$]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE ['Nashville'$]
Add OwnerSplitCity Nvarchar(255);

Update ['Nashville'$]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE ['Nashville'$]
Add OwnerSplitState Nvarchar(255);

Update ['Nashville'$]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
Change Y and N to Yes and No in "Sold as Vacant" Field
5. Change Y and N to Yes and No in "Sold as Vacant" Field
Selects distinct values of SoldAsVacant along with their counts.
Updates the 'Nashville$' table, modifying the SoldAsVacant column values based on a CASE statement.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From[Portfolio Project]..['Nashville'$]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	  





