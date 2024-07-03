-- 1. 
SELECT COUNT(*)
FROM 
(
	(SELECT npi
	 FROM prescriber)
	 EXCEPT
	 (SELECT npi
	 FROM prescription)
) AS sub;

--2.
--a.
SELECT generic_name, SUM(total_claim_count) as total_claims
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY total_claims DESC
LIMIT 5;

--b. 
SELECT generic_name
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY sum(total_claim_count) DESC
LIMIT 5

--c.
(
SELECT generic_name, SUM(total_claim_count) as total_claims
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY total_claims DESC
LIMIT 5
)
INTERSECT
(
SELECT generic_name
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY sum(total_claim_count) DESC
LIMIT 5);

--3.
--a.
SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
FROM prescriber 
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5 

--b.
SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
FROM prescriber 
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5

--c.
	(SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
	FROM prescriber 
	INNER JOIN prescription
	USING (npi)
	WHERE nppes_provider_city = 'NASHVILLE'
	GROUP BY npi, nppes_provider_city
	ORDER BY total_claims DESC
	LIMIT 5)
UNION
	(SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
	FROM prescriber 
	INNER JOIN prescription
	USING (npi)
	WHERE nppes_provider_city = 'MEMPHIS'
	GROUP BY npi, nppes_provider_city
	ORDER BY total_claims DESC
	LIMIT 5)
UNION
	(SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
	FROM prescriber 
	INNER JOIN prescription
	USING (npi)
	WHERE nppes_provider_city = 'KNOXVILLE'
	GROUP BY npi, nppes_provider_city
	ORDER BY total_claims DESC
	LIMIT 5)
UNION
	(SELECT npi, sum(total_claim_count) as total_claims, nppes_provider_city
	FROM prescriber 
	INNER JOIN prescription
	USING (npi)
	WHERE nppes_provider_city = 'Chattanooga'
	GROUP BY npi, nppes_provider_city
	ORDER BY total_claims DESC
	LIMIT 5)

-- 4.
SELECT county, overdose_deaths
FROM overdose_deaths
INNER JOIN fips_county
USING (fipscounty)
WHERE year = 2017 AND overdose_deaths > (SELECT AVG (overdose_deaths) FROM overdose_deaths WHERE year = 2017);

-- 5.
-- a.
SELECT sum(population) 
FROM population;

--b.
SELECT county, population, ROUND(100*population / (SELECT sum(population) FROM population),2) AS population_pct
FROM population
INNER JOIN fips_county
USING (fipscounty);
