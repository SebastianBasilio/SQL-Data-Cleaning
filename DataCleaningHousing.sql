use PortfolioProject;

select * from [NashvilleHousing];

-- 1. Estandarizar la Fecha --------------------------------------------------------------------------------------
select SaleDate, CONVERT(date, SaleDate) from NashvilleHousing

--Forma1
UPDATE [NashvilleHousing]
SET SaleDate = CONVERT(date, SaleDate) 

--Forma2
ALTER TABLE [NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- 2. Lleno la columna PropertyAddress puesto que contiene nulls ---------------------------------------------------

select count(PropertyAddress)
from NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as Address
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 3. Separo la columna PropertyAddrees en dos (dirección, ciudad) ejem:1808  FOX CHASE DR, GOODLETTSVILLE ----------------------------------------------------

select PropertyAddress
from NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as City
from NashvilleHousing

--Address
ALTER TABLE [NashvilleHousing]
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

--Ciudad
ALTER TABLE [NashvilleHousing]
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

-- 4. Separo la columna OwnerAddrees en tres (dirección, ciudad, estado) ejem:1808  FOX CHASE DR, GOODLETTSVILLE, TN ----------------------------------
select OwnerAddress from NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),1) as State,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),3) as Address
from NashvilleHousing

--Address
ALTER TABLE [NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

--Ciudad
ALTER TABLE [NashvilleHousing]
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

--State
ALTER TABLE [NashvilleHousing]
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

-- 5. Cambio los valores Y por Yes y N por No para Estandarizar ---------------------------------------------------------------------

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	END

-- 6. Remuevo duplicados -------------------------------------------------------------------------------------------
WITH RowNumCTE as(
	select *,
		ROW_NUMBER() OVER (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
	from NashvilleHousing)

delete
from RowNumCTE
where row_num>1

-- 7. Remuevo columnas no utilizadas ---------------------------------------------------------------------------------
select * from NashvilleHousing

ALTER TABLE NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
Drop COLUMN SaleDate
