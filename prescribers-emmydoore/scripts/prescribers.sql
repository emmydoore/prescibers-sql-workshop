-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

select npi, 
		sum(total_claim_count) 
		as total_number_of_claims
from prescriber
inner join prescription
using (npi)
group by npi
order by sum(total_claim_count) desc;
--Answer: Prescriber 1881634483, 99,707 claims

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

select npi, 
	nppes_provider_first_name, 
	nppes_provider_last_org_name,  
	specialty_description, 
	sum(total_claim_count) 
	as total_number_of_claims
from prescriber
inner join prescription
using (npi)
group by npi, 
	nppes_provider_first_name, 
	nppes_provider_last_org_name,  
	specialty_description
order by sum(total_claim_count) desc;
--Answer: Bruce Pendley, 99,707 claims

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

select specialty_description, 
		sum(total_claim_count) 
		as total_number_of_claims
from prescriber
inner join prescription
using (npi)
group by specialty_description 
order by total_number_of_claims desc;
--Answer: Family Practice, 9,752,347

--     b. Which specialty had the most total number of claims for opioids?

select p1.specialty_description, 
		sum(p2.total_claim_count) 
		as opioid_claims
		--fixed alias
from prescriber as p1
inner join prescription as p2
using (npi)
inner join drug as d
using (drug_name)
where opioid_drug_flag='Y'
group by p1.specialty_description 
order by total_number_of_claims desc;
--Nurse Practioner, 900,845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

select p1.specialty_description, 
		count(p2.drug_name) as drug_count
		--added count ^
from prescriber as p1
left join prescription as p2
using (npi)
group by p1.specialty_description
having count(p2.drug_name)=0;
--Answer: There are 15 specialities that have no associated prescriptions

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

select p1.specialty_description, 
		round(count(opioid_drug_flag)/sum(p2.total_claim_count) *100,3) 
		as opioid_percentage_of_total
from prescriber as p1
inner join prescription as p2
using (npi)
inner join drug as d
using (drug_name)
where d.opioid_drug_flag='Y'
group by p1.specialty_description
order by opioid_percentage_of_total desc;
--Answer: General Acute Care Hospital and Critical Care (Intensivists) have the highest percentage of opiod prescriptions with 9.091% each

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

 select generic_name, 
 		cast(round(sum(total_drug_cost),2) as money) 
		as total_drug_cost
 from drug
 inner join prescription
 using (drug_name)
 group by generic_name
 order by total_drug_cost desc;
--Answer: INSULIN GLARGINE,HUM.REC.ANLOG, $104,264,066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

 select generic_name, 
 		cast(ROUND(sum(total_drug_cost)/sum(total_day_supply), 2) as money) 
		as total_cost_per_day
 from drug
 inner join prescription
 using (drug_name)
 group by generic_name
 order by sum(total_drug_cost)/sum(total_day_supply) desc;
 --Answer: C1 ESTERASE INHIBITOR, $3,495.22 per day
 
-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

select drug_name, 
		case when opioid_drug_flag='Y' then 'opioid'
		 when antibiotic_drug_flag='Y' then 'antibiotic'
		 else 'neither' end as drug_type 
from drug
group by drug_name, 
		drug_type
order by drug_name;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

select case when opioid_drug_flag='Y' then 'opioid'
		when antibiotic_drug_flag='Y' then 'antibiotic'
		else 'neither' end as drug_type,
		sum(cast(total_drug_cost as money)) 
		as total_drug_cost
from drug
inner join prescription
using (drug_name)
where opioid_drug_flag='Y'
or antibiotic_drug_flag='Y'
group by drug_type
order by total_drug_cost desc;
--Answer: Opioids

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

select count(distinct cbsa) as cbsas_in_TN
from cbsa
WHERE cbsaname like '%TN%';
--Answer: 10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
select cbsaname, cbsa, sum(population) as total_population
from cbsa
inner join population
using (fipscounty)
--took out filter for TN
group by cbsaname, 
		cbsa
order by sum(population) desc;
--Answer: 
--Largest: Nashville-Davidson--Murfreesboro--Franklin, TN- 1,830,410 
--Smallest: Morristown, TN- 116,352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

select  county, 
		f.state, 
		population
from population 
left join cbsa
using (fipscounty)
inner join fips_county as f
using (fipscounty)
where cbsa is null
order by population desc;
--Answer: Sevier County, TN- 95,523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

select drug_name, 
		total_claim_count
		--took out sum ^
from prescription
where total_claim_count>=3000
order by total_claim_count desc;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

select drug_name, 
		case when opioid_drug_flag='Y' then 'opioid'
		 else 'not an opioid' end as drug_type,
		total_claim_count
		--took out sum ^
from prescription
inner join drug 
using (drug_name)
where total_claim_count>=3000
order by total_claim_count desc;

--     c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.

select drug_name, 
case when opioid_drug_flag='Y' then 'opioid'
		 else 'not an opioid' end as drug_type,
		 total_claim_count,
		 --took out sum ^
		 nppes_provider_first_name,
		 nppes_provider_last_org_name
from prescription
inner join drug
using (drug_name)
inner join prescriber
using (npi)
where total_claim_count>=3000
order by total_claim_count desc;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.


--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

select npi, 
		drug_name
from prescriber
cross join drug
where specialty_description='Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' 
	and opioid_drug_flag = 'Y'
group by npi, drug_name;

		
--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

select p1.npi, 
		d.drug_name, 
		sum(total_claim_count) as total_claim_count
from prescriber as p1
cross join drug as d
full join prescription as p2
using (drug_name, npi)
--added npi ^
where specialty_description='Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' 
	and opioid_drug_flag = 'Y'
group by p1.npi, 
		d.drug_name;


--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

select p1.npi, 
		d.drug_name, 
		COALESCE(sum(total_claim_count),0) 
		as total_claim_count
from prescriber as p1
cross join drug as d
full join prescription as p2
using (drug_name, npi)
where specialty_description='Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' 
	and opioid_drug_flag = 'Y'
group by p1.npi, 
		d.drug_name;
