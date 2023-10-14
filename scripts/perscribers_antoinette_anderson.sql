-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi
ORDER BY sum_total_claim_count DESC
LIMIT 10;

-- Prescriber 1881634483
 
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT npi, nppes_provider_last_org_name,nppes_provider_first_name, specialty_description, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_last_org_name,nppes_provider_first_name, specialty_description
ORDER BY sum_total_claim_count DESC

-- Bruce PEndley, Family Practice, 99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, total_claim_count, prescription.npi
FROM prescriber
INNER JOIN prescription
USING (npi)
ORDER BY total_claim_count DESC


-- Family Practice


--     b. Which specialty had the most total number of claims for opioids?
SELECT COUNT(total_claim_count) as opioid_claim_count, opioid_drug_flag, prescriber.specialty_description
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE opioid_drug_flag ='Y'
GROUP BY opioid_drug_flag, prescriber.specialty_description
ORDER BY opioid_claim_count DESC;

-- Nurse Practitioner


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT COUNT(prescription.drug_name)AS prescription_drugs, prescriber.specialty_description
FROM prescription
FULL JOIN prescriber
USING(npi)
GROUP BY prescriber.specialty_description
ORDER BY prescription_drugs 

-- There are 15 specialties that have no associated prescriptions. 




--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS generic_drug_cost
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug.generic_name 
ORDER BY generic_drug_cost DESC


--- Insulin Glargine, HUm.Rec.Anlog


-- Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, 
 ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS daily_cost
FROM prescription
LEFT JOIN drug
 USING (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC;

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;

SELECT drug_name, opioid_drug_flag, antibiotic_drug_flag
FROM drug

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT SUM(total_drug_cost) AS money,
 CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
 ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
WHERE
CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
 ELSE 'neither' END<>'neither'
GROUP BY CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
 ELSE 'neither' END

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT DISTINCT(cbsaname) AS cbsa_name_count
FROM cbsa
WHERE cbsaname LIKE '%TN%'

-- There are 10 cbsa in Tennessee.

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, SUM(population) AS sum_population
FROM CBSA
INNER JOIN fips_county
USING (fipscounty)
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname
order BY sum_population DESC;

-- largest: Davidson County 
-- smallest: Morristown



--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT fips_county.county, SUM(population.population) AS population
FROM fips_county
INNER JOIN population
USING (fipscounty)
GROUP BY fips_county.county
ORDER BY population DESC;

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name , total_claim_count
FROM prescription
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name , total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count > 3000 
	AND opioid_drug_flag ='Y'

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name , SUM(total_claim_count) AS opioid_claim_count, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE total_claim_count > 3000
	AND opioid_drug_flag ='Y'
GROUP BY drug_name, nppes_provider_first_name, nppes_provider_last_org_name, opioid_drug_flag
	
	
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT  drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
FROM prescription
INNER JOIN prescriber
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

	

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
SELECT nppes_provider_last_org_name, nppes_provider_first_name, npi, prescription.drug_name, total_claim_count
FROM prescriber
FULL JOIN prescription
USING (npi)
ORDER BY total_claim_count
	
	
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT  nppes_provider_last_org_name, nppes_provider_first_name, npi, prescription.drug_name, COALESCE(total_claim_count, '0') AS total_claims
FROM prescriber
FULL JOIN prescription
USING (npi)
ORDER BY total_claim_count DESC;

