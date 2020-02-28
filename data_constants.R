mapped_names = c("Banjo.*Kazooie" = 'Banjo & Kazooie',
                 'Bowser Jr.' = 'Bowser Jr',
                 'Pit, but edgy' = 'Dark Pit',
                 'Dank Samus' = 'Dark Samus',
                 'Dr.*Mario' = 'Dr Mario',
                 'Educated Mario' =  'Dr Mario',
                 'Duck Hunt Duo' = 'Duck Hunt',
                 '^Dedede$' =  'King Dedede',
                 'K.*Rool'  = 'King K Rool',
                 'Mega.*[m|M]an' = 'Mega Man',
                 'Mii Sword.*' = 'Mii Swordfighter',
                 '.*Game.*Watch' = 'Mr Game & Watch',
                 '^P[a|A][c|C].*M[a|A][n|N]$'  = 'Pac Man',
                 'Pok.*mon Trainer' = 'Pokemon Trainer',
                 '^R.*[O|o].*[B|b]\\.?$' = 'Rob',
                 'Rosalina' = 'Rosalina & Luma')

char_list = read.csv('data/char_list.csv', stringsAsFactors = FALSE)

melee_bonuses = c('easter' = 'Character Call voices, Classic narrator, Narrator at Melee Mode/nr_name08.dsp.wav',
                  'READY' = 'Character Call voices, Classic narrator, Narrator at Melee Mode/nr_name2c.dsp.wav',
                  'GO' = 'Character Call voices, Classic narrator, Narrator at Melee Mode/nr_name26.dsp.wav',
                  'GAME' = 'Character Call voices, Classic narrator, Narrator at Melee Mode/nr_name25.dsp.wav')
