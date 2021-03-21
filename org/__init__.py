

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