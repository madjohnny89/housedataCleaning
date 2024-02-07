--Select data to first visualize

select *
from housedata

select SaleDate, CONVERT(date, SaleDate) as SaleDateConverted
from housedata

Alter Table housedata
add SaleDateConverted date;

update housedata
set SaleDateConverted = CONVERT(date, SaleDate)


select ParcelID, PropertyAddress, count(ParcelID) as Pcounts, COUNT(PropertyAddress) as propertyCount
from housedata
group by ParcelID, PropertyAddress
order by 2 desc


--- there are some identical parcelID for which, everything is same except for the propertyaddress is null in one of the pair. 
--In this process, we will populate the null property address with the other propertyaddress of the pair

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from housedata a
join housedata b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from housedata a
join housedata b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--- breaking address

--this is one way
select PropertyAddress, SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as HomeAddress,
SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) As CityAddress
from housedata


-- adding these split columns

Alter TABLE housedata
add PropertySplitAddress nvarchar(255)

update housedata
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter TABLE housedata
add PropertySplitCity nvarchar(255)

update housedata
set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

select *
from housedata

select OwnerAddress, PropertyAddress
from housedata

---simpler method

select PARSENAME(replace(OwnerAddress,',', '.'), 1) as OwnerState, 
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as OwnerHome
From housedata

Alter table housedata
add OwnerSplitState nvarchar(255);

Alter table housedata
add OwnerSplitCity nvarchar(255);

Alter table housedata
add OwnerSplitAddress nvarchar(255);

update housedata
set
OwnerSplitState = PARSENAME(replace(OwnerAddress,',', '.'), 1),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

select *
from housedata

----- making all y to yes and all n to no in soldAsVacant

select distinct(SoldAsVacant), count(soldAsVacant)
from housedata
group by SoldAsVacant


select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end
from housedata

--lets update the table

update housedata
set 
SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end


-- lets remove duplicates

select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice, 
				LegalReference
				Order by 
					UniqueID
					) row_num

from housedata
order by ParcelID

-- I wanted to find out row_num >1 but I cannot do it in select statement, therefore, I have to use CTE

With CTERow as (
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice, 
				LegalReference
				Order by 
					UniqueID
					) row_num

from housedata
)
select *
from CTERow
where row_num >1

--- we can delete it

With CTERow as (
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice, 
				LegalReference
				Order by 
					UniqueID
					) row_num

from housedata
)
delete 
from CTERow
where row_num >1


--- lets delete unused columns

select *
from housedata

alter table housedata
drop column PropertyAddress, Saledate, TaxDistrict

alter table housedata
drop column OwnerAddress