library(jsonlite)
library(httr)

char_attr = GET('https://api.kuroganehammer.com/api/characterattributes?game=ultimate',
           add_headers('content-type' = 'application/json'))
char_attr_text = content(char_attr, 'text')
char_attr_json = fromJSON(char_attr_text, flatten = TRUE)
char_attr = as_tibble(char_attr_json)


char_attr = GET('https://api.kuroganehammer.com/api/attributes?game=ultimate',
                add_headers('content-type' = 'application/json'))
char_attr_text = content(char_attr, 'text')
char_attr_json = fromJSON(char_attr_text, flatten = TRUE)
char_attr = as_tibble(char_attr_json)
