#!/bin/bash - 
#===============================================================================
#
#          FILE: csvToExtGrid.sh
# 
#         USAGE: ./csvToExtGrid.sh [CsvNameWithoutExtention] [AppName]
# 
#   DESCRIPTION: Create Model Store and View for CSV
# 
#       OPTIONS: ---
#  REQUIREMENTS: csv2json via npm
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Dusty Carver, 
#  ORGANIZATION: DoubleAI
#       CREATED: ---
#      REVISION: 05/02/2017 15:08 
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#!/bin/bash

csv2json $1.csv -d',' -q'"' | python -m json.tool > model/$1.json

sed -i '1s;^;{\n\t"payload":\n;' model/$1.json
echo ',"status": 200, "success": true }' >> model/$1.json

FIELDS=$(head -n1 $1.csv | sed 's/\,/\"\,\"/g' | sed 's/^/\"/g' | sed 's/$/\"/g')
cat <<EOF > store/$1.js
Ext.define('$2.store.$1', { 
    storeId: '$1',
    extend:"Ext.data.Store",
    model:"$2.model.$1",
    autoLoad: true
});
EOF


cat <<EOF > model/$1.js
Ext.define('$2.model.$1', {

    extend: '$2.model.Base',
    fields:[$FIELDS],

    proxy: {
        type: 'ajax',
        url: '/app/model/$1.json',
        format: 'json',
        reader: {
            type:'json',
            
            rootProperty: 'payload'
        }

    }
});
EOF

COLUMNS=$(echo $FIELDS | sed 's/"\([A-Za-z_]\+\)"/{ text:"\1", dataIndex: "\1"  },\r\n/g' | sed 's/^,//')
LOWER=$(echo $1 | tr '[:upper:]' '[:lower:]' )
cat <<EOF > view/$1.js
Ext.define('$2.view.main.$1', {
    extend: 'Ext.grid.Grid',
    alias: 'widget.$LOWER',

    requires: [
        '$2.store.$1'
    ],

    title: '$1',

    store: '$1',
    height: '100%',
    columns: [
        $COLUMNS
        ],

    listeners: {
        select: 'onItemSelected'
    }
});
EOF
