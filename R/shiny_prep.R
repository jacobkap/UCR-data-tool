library(asciiSetupReader)
library(dplyr)
setwd("C:/Users/user/Dropbox/R_project/ucrdatatool/data")
load("UCR_offenses_known_yearly_1960_2016.rda")
ucr <- UCR_offenses_known_yearly_1960_2016
rm(UCR_offenses_known_yearly_1960_2016); gc()
names(ucr) <- tolower(names(ucr))
ucr$year <- as.numeric(ucr$year)
ucr$population <- ucr$population_1 + ucr$population_2 + ucr$population_3
names(ucr)[1] <- "state"

# Remove NA values
ucr <- ucr[!is.na(ucr$state),]
ucr <- ucr[ucr$months_reported == "december is the last month reported", ]

crosswalk_names <- c("^ORIGINATING_AGENCY_IDENTIFIER_7_CHARACTERS_FROM_UCR_FILES$" = "ori",
                     "^ORIGINATING_AGENCY_IDENTIFIER_7_CHARACTER$" = "ori",
                     "^UCR_ORIGINATING_AGENCY_IDENTIFIER$"         = "ori",
                     "^AGENCY_NAME$"                               = "agency",
                     "^UCR_AGENCY_NAME$"                           = "agency"

)

crosswalk            <- spss_ascii_reader("crosswalk.txt", "crosswalk.sps")
names(crosswalk)     <- str_replace_all(names(crosswalk), crosswalk_names)
crosswalk2005        <- spss_ascii_reader("crosswalk2005.txt", "crosswalk2005.sps")
names(crosswalk2005) <- str_replace_all(names(crosswalk2005), crosswalk_names)
crosswalk2005        <- crosswalk2005[!crosswalk2005$ori %in% crosswalk$ori, ]
crosswalk            <- bind_rows(crosswalk, crosswalk2005)
crosswalk1996        <- spss_ascii_reader("crosswalk1996.txt", "crosswalk1996.sps")
names(crosswalk1996) <- str_replace_all(names(crosswalk1996), crosswalk_names)
crosswalk1996        <- crosswalk1996[!crosswalk1996$ori %in% crosswalk$ori, ]
crosswalk            <- bind_rows(crosswalk, crosswalk1996)
crosswalk            <- crosswalk[, c("ori", "agency")]
crosswalk            <- crosswalk[!is.na(crosswalk$ori), ]
crosswalk            <- crosswalk[crosswalk$ori != "Not in UCR",]

ucr <- left_join(ucr, crosswalk)
to_remove <- c("population_1", "county_1", "core_city_indication", "division",
               "msa_1", "population_2", "county_2", "covered_by_code",
               "msa_2", "population_3", "county_3", "months_reported",
               "msa_3", "followup_indication", "special_mailing_group",
               "special_mailing_address", "mailing_address_line_1",
               "mailing_address_line_2",
               "mailing_address_line_3", "mailing_address_line_4", "zip_code")
ucr <- ucr[, names(ucr)[!names(ucr) %in% to_remove]]
ucr <- ucr[!is.na(ucr$agency),]
ucr$state <- sapply(ucr$state, simple_cap)
ucr$agency <- sapply(ucr$agency, simple_cap)
setwd("C:/Users/user/Dropbox/R_project/ucrdatatool/shiny_data")
save(ucr, file = "ucr.rda")


crime_names <- c("murder"                = "Murder",
                 "manslaughter"         = "Manslaughter",
                 "rape_total"           = "Rape Total",
                 "force_rape"           = "Forcible Rape",
                 "att_rape"             = "Attempted Rape",
                 "robbery_total"        = "Robbery Total",
                 "gun_robbery"          = "Robbery -  Gun",
                 "knife_robbery"        = "Robbery - Knife",
                 "oth_weap_robbery"     = "Robbery - Other Weapon",
                 "strong_arm_robbery"   = "Robbery - Strong Arm",
                 "assault_total"        = "Assault Total",
                 "agg_assault"          = "Aggravated Assault",
                 "gun_assault"          = "Assault -  Gun",
                 "knife_assault"        = "Assault - Knife",
                 "oth_weap_assault"     = "Assault - Other Weapon",
                 "hand_feet_assault"    = "Assault - Strong Arm",
                 "simple_assault"       = "Simple Assault",
                 "burglary_total"       = "Burglary Total",
                 "burg_force_entry"     = "Burglary - Forcible Entry",
                 "burg_no_force_entry"  = "Burglary - Nonforcible Entry",
                 "att_burglary"         = "Attempted",
                 "larceny_total"        = "Larceny Total",
                 "mtr_vhc_theft_total"  = "Mtor Vehicle Theft",
                 "auto_theft"           = "Auto Theft",
                 "truck_bus_theft"      = "Truck/Bus Theft",
                 "oth_vhc_theft"        = "Other Vehicle Theft",
                 "officers_kill_by_acc" = "Officers Killed by Accident",
                 "officers_kill_by_fel" = "Officers Killed by Felony",
                 "officers_assaulted"   = "Officers Assaulted"
                 )

crimes <- data.frame(shiny_names = crime_names,
                     real_names = names(crime_names),
                     stringsAsFactors = FALSE)
rownames(crimes) <- 1:nrow(crimes)
save(crimes, file = "crimes.rda")
save(crime_names, file = "crime_names.rda")
