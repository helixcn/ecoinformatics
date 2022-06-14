library(here)
library(LPSC)
library(openxlsx)

testdat <- read.xlsx("sample_checklist_to_clean.xlsx")

# 查询多个学名的接受名

## 要使用get_accepted_name，则先要生成能用于查询的学名（不能有命名人）
scientific_name_parsed <- plantlist::parse_taxa(testdat$Latin.name) # 因有命名人，所以先parse
names_to_search <- paste(scientific_name_parsed$GENUS_PARSED, 
      scientific_name_parsed$SPECIES_PARSED, 
      scientific_name_parsed$INFRASPECIFIC_RANK_PARSED, 
      scientific_name_parsed$INFRASPECIFIC_EPITHET_PARSED)

## 查询
res_LPSC_2022_accepted_names <- get_accepted_name(names_to_search)

## 保存结果
write.xlsx(res_LPSC_2022_accepted_names, "res_LPSC_2022_accepted_names.xlsx")
