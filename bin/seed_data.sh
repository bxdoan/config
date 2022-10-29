#!/usr/bin/env bash
# Author: Doan Bui (bxdoan93@gmail.com)
CURRENT_TIME=`date +%Y-%m-%d`
psqldb_admin="djadmin"      # Database name
psqldb_atlas="atlas"      # Database name
dsql="docker exec -it gc_postgres_dn psql -U postgres"
username_pass="pbkdf2_sha256\$320000\$WqQIYEvdrBBKb340yDkxUy\$19sHcOVAdVADmxuVySgpRbCOaYPDrcxzvk5jza+57A0="  # admin

USERNAME=$1
if [[ -z $USERNAME ]]; then USERNAME="don"; fi

function create_and_seed {
     # Insert some seeding data users


   echo "Insert some seeding data auth_user"
   $dsql -d $psqldb_admin -c "INSERT INTO auth_user (first_name, last_name, username, password, email, is_superuser, is_staff, is_active, date_joined) VALUES
             ('${USERNAME}', 'bui', '${USERNAME}', '${username_pass}', '${USERNAME}@g.com', true, true, true, '${CURRENT_TIME} 04:11:53.664044+00');"

  # Show customers table
   $dsql -d $psqldb_admin -c "SELECT * FROM auth_user;"
}

function create_and_seed_usr {
     # Insert some seeding data users
  echo "Insert some seeding data user"

#   $dsql -d $psqldb_atlas -c "INSERT INTO groups (name, sponsor_message, email) VALUES
#             ('gigacover', 'sponsor_message', '${USERNAME}@g.com');"
#   $dsql -d $psqldb_atlas -c "INSERT INTO users (first_name, last_name, password, nricfin, email, \"createdAt\", \"updatedAt\") VALUES
#             ('${USERNAME}', 'bui', '${username_pass}', 'S7515739H', '${USERNAME}@g.com', '${CURRENT_TIME} 04:11:53.664044+00', '${CURRENT_TIME} 04:11:53.664044+00');"
   $dsql -d $psqldb_atlas -c "INSERT INTO policies (first_name, last_name, nricfin, policy_number, email, product, plan, insurer, policy_start, policy_end) VALUES
             ('${USERNAME}', 'bui', 'S7515739H', 'HEP00001-1028440-001', '${USERNAME}@g.com', 'pml', 'pml80', 'etiqa', '${CURRENT_TIME}', '${CURRENT_TIME}');"
  # Show customers table
   $dsql -d $psqldb_atlas -c "SELECT * FROM users;"
}


create_and_seed_usr
