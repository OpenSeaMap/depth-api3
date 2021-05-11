from django import forms

userdb_columns = ["user_name",
                  "forename",
                  "surname",
                  "acceptedEmailContact",
                  "organisation",
                  "country",
                  "language",
                  "phone",
                  "password"]


def _queryhelper():
    out = ""
    for col_entry in userdb_columns:
        out += col_entry + ","
    return out[:-1]


def to_decimal_string(x):
    neu = ''
    i = 1
    n = 0
    while i <= len(x):
        neu += x[len(x)-i]
        i += 1
        n += 1
        if n == 3:
            neu += '.'
            n = 0
    x = ''
    i = 1
    while i <= len(neu):
        x += neu[len(neu)-i]
        i += 1
#    print("String: ", x, "Länge: ", len(neu))
    return x
