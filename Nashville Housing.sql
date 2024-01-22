select * from [Portfolio Project]..['Nashville'$]
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project]..['Nashville'$]


ALTER TABLE  ['Nashville'$]
Add SaleDateConverted Date;

Update  ['Nashville'$]
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

-- Select all columns from the 'Nashville$' table
-- The table is assumed to have a structure similar to the SELECT query below

Select *
From [Portfolio Project]..['Nashville'$]
Order by ParcelID;


-- Select columns from two instances (a and b) of the 'Nashville$' table
-- where PropertyAddress is null in the first instance (a)


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..['Nashville'$] a
JOIN [Portfolio Project]..['Nashville'$]  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Update rows in the 'Nashville$' table where PropertyAddress is null
-- with a non-null PropertyAddress from another row with the same ParcelID


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..['Nashville'$]a
JOIN [Portfolio Project]..['Nashville'$] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


 --------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)



-- Selects the PropertyAddress column from the 'Nashville$' table

Select PropertyAddress
From [Portfolio Project]..['Nashville'$]



-- Selects two substrings from the PropertyAddress column:
-- 1. From the beginning of the string to the first comma (',')
-- 2. From the character after the first comma to the end of the string


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Portfolio Project]..['Nashville'$]




-- Alters the structure of the 'Nashville$' table by adding a new column PropertySplitAddress of type Nvarchar(255)

ALTER TABLE ['Nashville'$]
Add PropertySplitAddress Nvarchar(255);



-- Updates the rows in the 'Nashville$' table, setting the new PropertySplitAddress column
-- to the substring from the beginning of the PropertyAddress column to the first comma (',')


Update ['Nashville'$]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE ['Nashville'$]
Add PropertySplitCity Nvarchar(255);

Update ['Nashville'$]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--


Select *
From [Portfolio Project]..['Nashville'$]



-- Selects the OwnerAddress column from the 'Nashville$' table

Select OwnerAddress
From [Portfolio Project]..['Nashville'$]

-- Selects three columns by parsing the OwnerAddress column:
-- 1. OwnerSplitState: The state part (third component) of the parsed OwnerAddress
-- 2. OwnerSplitCity: The city part (second component) of the parsed OwnerAddress
-- 3. OwnerSplitAddress: The address part (first component) of the parsed OwnerAddress


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..['Nashville'$]


-- Adds a new column OwnerSplitAddress of type Nvarchar(255) to the 'Nashville$' table

ALTER TABLE ['Nashville'$]
Add OwnerSplitAddress Nvarchar(255);


-- Updates the rows in the 'Nashville$' table, setting the OwnerSplitAddress column
-- to the parsed state part (third component) of the OwnerAddress


-- Adds a new column OwnerSplitCity of type Nvarchar(255) to the 'Nashville$' table



Update [Portfolio Project]..['Nashville'$]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- Updates the rows in the 'Nashville$' table, setting the OwnerSplitCity column
-- to the parsed city part (second component) of the OwnerAddress


ALTER TABLE ['Nashville'$]
Add OwnerSplitCity Nvarchar(255);


-- Adds a new column OwnerSplitState of type Nvarchar(255) to the 'Nashville$' table

Update ['Nashville'$]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- Updates the rows in the 'Nashville$' table, setting the OwnerSplitState column
-- to the parsed address part (first component) of the OwnerAddress


ALTER TABLE ['Nashville'$]
Add OwnerSplitState Nvarchar(255);

Update ['Nashville'$]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Selects all columns from the 'Nashville$' table after the updates
Select *
From [Portfolio Project]..['Nashville'$]


------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Selects distinct values of SoldAsVacant along with their counts
-- Groups the results by SoldAsVacant and orders them by count in descending order

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From[Portfolio Project]..['Nashville'$]
Group by SoldAsVacant
order by 2


-- Selects the SoldAsVacant column along with a CASE statement to map 'Y' to 'Yes', 'N' to 'No', and keep other values as they are

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project]..['Nashville'$]

-- Updates the 'Nashville$' table, modifying the SoldAsVacant column values based on the CASE statement

Update ['Nashville'$]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------
-- Remove Duplicates

-- Common Table Expression (CTE) to assign a row number to each record based on specified criteria

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

From [Portfolio Project]..['Nashville'$]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Selects all columns from the CTE where the row number is greater than 1, indicating duplicates
Select *
From [Portfolio Project]..['Nashville'$]




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- Selects all columns from the 'Nashville$' table before any changes

Select *
From[Portfolio Project]..['Nashville'$]

-- Drops specified columns (OwnerAddress, TaxDistrict, PropertyAddress, SaleDate) from the 'Nashville$' table
ALTER TABLE [Portfolio Project]..['Nashville'$]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate