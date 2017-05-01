#!/bin/bash

csvjson $1.csv -d',' -q'"' | python -m json.tool > $1.json

FIELDS=$(head -n1 $1.csv | sed 's/\,/\"\,\"/g' | sed 's/^/\"/g' | sed 's/$/\"/g')

cat <<EOF > store.$1.js
Ext.define('$2.store.$1', { 

    extend:"Ext.data.Store",
    model:"$2.model.$1",
    autoLoad: true
});
EOF


cat <<EOF > model.$1.js
Ext.define('$2.model.$1', {

    extend: 'Ext.data.Model',
    schema: {
        namespace: '$2.model'

    },

    fields:[$FIELDS],

    proxy: {
        type: 'ajax',
        url: '/app/model/$1.json',
        format: 'json',
        reader: {
            type:'json'

        }

    }
});
EOF

COLUMNS=$(echo $FIELDS | gsed 's/"\([A-Za-z_]\+\)"/{ text:"\1", dataIndex: "\1"  },\r\n/g' | gsed 's/^,//')

cat <<EOF > list.$1.js
Ext.define('$2.view.main.$1List', {
    extend: 'Ext.grid.Panel',
    xtype: '$1list',

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
