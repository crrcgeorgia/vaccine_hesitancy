use "https://caucasusbarometer.org/downloads/omnibus/CRRC_Omnibus_Public_Wave7.dta", clear


recode d1 (5/6=1)(nonmissing=0), gen(empl)
recode d2 (4/5=1)(nonmissing=0), gen(high_ed)

gen assets_index = 0

foreach x of varlist d3_* {
replace assets_index = assets_index + 1 if `x' == 1
}

recode d6 (3=1)(nonmissing=0), gen(georgian)

recode d8 (-9/-1=.)

recode d8 (1/2=1 "Regular") (3/4=2 "Less often") (5=0 "Never"), gen(rel_att)

recode age (18/34=1 "18-34") (35/54=2 "35/54") (55/119=3 "55+"), gen(agegroup)

recode c2_10 (-9/-3=.) (-2/-1=0), gen(covid_exp)

recode c3 (-9/-2=.) (-1=4)

recode c5 (-9/-2=.) (-1=3 "Don't know") (1/2=2 "No") (3/4=1 "Yes"), gen(vac_hes)

recode c4 (-9/-2=.) (-1=3)

recode m4 (-9 -3 =.) (1=1 "GD") (-5 -2 -1= 3 "Unaffilated") (nonmissing = 2 "Opposition"), gen(party)

recode m3 (-9 -3 =.) (1=1 "Every day") (2/4=2 "Less often") (5=3 "Never"), gen(internet)

recode d9_1 (-2/0=0)(nonmissing=1), gen(children)

recode c1_1 (1/2=1 "No trust") (3/4=2 "Trust") (-2/-1=3 "Uncertain")(-9 -3 =.), gen(gov_trust)

recode c6_a (1=1) (9=1) (24=1) (2=2) (4=2) (6=2) (8=2) (19=2) (22=2) (3=3) (10=3) (11=3) (13=3) (14=3) (25=3) (5=4) (7=6) (12=6) (15=6) (16=5) (17=5) (18=1) (20=6) (21=1) (23=1), gen(c6)
replace c6 = 4 if c6_b == 26
replace c6 = 6 if c6_b == 27
replace c6 = 6 if c6_b == 28
replace c6 = 6 if c6_b == 29

recode c6 (-9 -3 -7 =.) (-2/-1=98)

lab def c6 1 "Does not trust vaccines" 2 "Afraid of side effects" 3 "Do not need it" 4 "Already had COVID-19" 5 "Afraid of vaccination" 6 "Other", modify
lab val c6 c6

recode c6 (1=1 "Do not trust vaccines") (nonmissing=0 "Other"), gen(c6_rec)

svy: logit c6_rec i.sex i.agegroup i.stratum empl high_ed georgian i.party i.internet i.rel_att children covid_exp

margins party

svy: prop c6_rec, over(party)



/// Demographic model

svy: prop vac_hes

svy: mlogit vac_hes i.sex i.agegroup i.stratum empl high_ed georgian i.internet children covid_exp i.rel_att

svy: tab vac_hes sex, col pearson

svy: tab vac_hes party, col pearson


// attitudes

svy: mlogit vac_hes i.c3 i.c4 i.gov_trust i.party

margins, at(party=(1 2 3)) atmeans

marginsplot


/// combine 

svy: mlogit vac_hes i.sex i.agegroup i.stratum empl high_ed georgian i.internet children covid_exp i.rel_att i.party i.c3 i.c4 i.gov_trust

margins, at(party=(1 2 3)) atmeans

marginsplot
