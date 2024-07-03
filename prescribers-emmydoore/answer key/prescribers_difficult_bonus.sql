--USING A SINGLE CTE:
--CTE that sums up opioid claims
with opioid_y AS (
	SELECT 
		p2.specialty_description, 
		SUM(p1.total_claim_count) AS claims
	FROM prescription as p1
	LEFT JOIN prescriber as p2
	ON p1.npi = p2.npi
	LEFT JOIN drug as d
	ON p1.drug_name = d.drug_name
	WHERE opioid_drug_flag = 'Y' 
	GROUP BY specialty_description
	ORDER BY specialty_description DESC)
--Main query that includes all drugs, not just opioids. This allows me to reference the CTE that calculates for just opioids so I can do math using both to get my percent.
SELECT 
	p2.specialty_description, 
	SUM(p1.total_claim_count) AS claims, 
	COALESCE(ROUND(o.claims/SUM(p1.total_claim_count)*100, 2),0) AS perc_opioid
FROM prescription as p1
LEFT JOIN prescriber as p2
ON p1.npi = p2.npi
LEFT JOIN opioid_y as o
ON p2.specialty_description = o.specialty_description
GROUP BY p2.specialty_description, o.claims
ORDER BY perc_opioid DESC;




--USING TWO CTEs:
--CTE that sums up all drugs
WITH all_drugs AS (
	SELECT 
		specialty_description, 
		SUM(total_claim_count) AS total_claims
	FROM prescriber
	INNER JOIN prescription
	USING (npi)
	GROUP BY specialty_description
	ORDER BY total_claims DESC),
--CTE that sums up all opioids
opioids AS (
	SELECT 
		specialty_description, 
		SUM(total_claim_count) AS total_claims
	FROM prescriber
	INNER JOIN prescription
	USING (npi)
	INNER JOIN drug
	USING (drug_name)
	WHERE opioid_drug_flag = 'Y'
	GROUP BY specialty_description
	ORDER BY total_claims DESC)
--Main query that uses the two CTEs to calculate percentage
SELECT 
	specialty_description,
	COALESCE(opioids.total_claims, 0) as opioid_claims,
	all_drugs.total_claims as total_claims, 
	COALESCE(opioids.total_claims, 0) / all_drugs.total_claims AS opioids_percentage
FROM opioids
RIGHT JOIN all_drugs
USING (specialty_description)
ORDER BY opioids_percentage DESC;
--Normally the fewer CTEs you use, the more efficient your query, but in this case this query runs faster than the one with one CTE. The specifics of why this is remain a mystery.





--USING A CASE STATEMENT:
SELECT 
	p2.specialty_description, 
	SUM(p1.total_claim_count) AS claims, 
	COALESCE(ROUND(SUM
				   (CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)
					/SUM(p1.total_claim_count)*100,2),0) AS perc_opioid
FROM prescription as p1
LEFT JOIN prescriber as p2
ON p1.npi = p2.npi
LEFT JOIN drug as d
ON p1.drug_name = d.drug_name
GROUP BY p2.specialty_description
ORDER BY perc_opioid DESC;
--The quickest of all queries in this script