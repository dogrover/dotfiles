'use strict';

let BZ = {
    // Command names
    CMD_ADD_QUERY  : 'bugzilla-add-query',
    CMD_GET_QUERIES: 'bugzilla-get-queries',
    CMD_NEW_BUG    : 'bugzilla-new-bug',
    CMD_SEARCH_BUGS: 'bugzilla-search-bugs',

    // Option names
    OPT_BASE_URL: 'bugzilla-base-url',
    OPT_PRODUCT : 'bugzilla-product',
    OPT_PROTOCOL: 'bugzilla-use-https',

    // Argument names
    ARG_AUTHOR    : '-authorID',
    ARG_BUG_ID    : '-bug',
    ARG_QUERY_NAME: '-queryName',
    ARG_PRODUCT   : '-product',

    // Things bugzilla can do
    Action: {
        action: {
            'enter'   : 'enter_bug.cgi',
            'show_bug': 'show_bug.cgi',
            'query'   : 'buglist.cgi',
            'search'  : 'query.cgi',
        },
        completer: function(context, args) {
            context.completions = BZ.Action.action;
        },
        do_action: function(action, params, new_tab) {
            let page = BZ.Action.action[action];
            let str = BZ.as_param_string(params);
            let url = BZ.get_url() + '/' + page + '?' + str;
            let where = new_tab ? dactyl.CURRENT_TAB : dactyl.NEW_TAB;
            dactyl.open(url, { where: where });
        },
    },

    // Tracks names for commonly used products
    Product: {
        product: [
            'McAfee Foundation Services',
        ],
        completer: function(context) {
            context.completions = BZ.Product.product.map( function(p) { return [p,p]; } );
            // context.completions = BZ.Product.product;
        },
    },

    // Tracks the user's named queries (saved searches)
    Query: {
        query: {
        },
        completer: function(context, args) {
            context.completions = BZ.Query.query;
        },
    },

    abbreviations: {
        'bugzilla': 'bz',
    },

    flag_url_update: function (args) {
        BZ._modified_url = true;
        return args;
    },

    // Returns the cached base URL. Rebuilds it first, if needed.
    get_url: function() {
        if (BZ._modified_url) {
            BZ._url = [
                options[BZ.OPT_PROTOCOL],
                '://',
                options[BZ.OPT_BASE_URL],
            ].join('');
            BZ._modified_url = false;
        }
        return BZ._url;
    },

    // Converts a hashtable of keys (strings) and values to a parameter string
    as_param_string: function(params) {
        let str = [];
        for(var p in params) if (params.hasOwnProperty(p)) {
                str.push(encodeURIComponent(p) + '=' + encodeURIComponent(params[p]));
        }
        return str.join('&');
    },

    // Create a spec from a dash-delimited name. Abbreviations consist of the
    // first character of each group. A leading sequence of non-word characters
    // (the "prefix") retains only its first character in the abbreviation.
    // Examples:
    //     - 'my-command-name' -> 'mcn'
    //     - '-argName'        -> '-a'
    //     - '--long-arg-name' -> '-lan'
    build_spec: function(name) {
        let orig_name = name;
        let prefix = name.match(/^[^A-Z_a-z]+/) || '';
        if (prefix) {
            // There shouldn't be any more than one match, so just get the first
            name = name.substring(prefix[0].length);
            // We don't want multiple non-word characters leading an
            // abbreviation, so only use the first one in the sequence
            prefix = prefix[0][0];
        }
        let words = name.split('-');
        let abbr = words.map( function(w) { return BZ.abbreviations[w] || w[0] } );
        return [orig_name, prefix + abbr.join('')];
    },

    // Called in response to a 'DOMLoad' event on the base URL
    // TODO: Apply styles to BZ list page
    apply_styles: function() {
    },
};

// Options
group.options.add(
    BZ.build_spec(BZ.OPT_BASE_URL),
    'The base url of the Bugzilla server',
    'string', 'bugzilla.mozilla.org',
    {
        setter: BZ.flag_url_update,
    }
);

group.options.add(
    BZ.build_spec(BZ.OPT_PROTOCOL),
    'Toggles between https and http protocols',
    'boolean', true,
    {
        setter: function(value) {
            BZ.flag_url_update();
            return (value ? 'https' : 'http');
        },
    }
);

group.options.add(
    BZ.build_spec(BZ.OPT_PRODUCT),
    'Sets the default product used for some actions',
    'string', 'Firefox',
    {
        // completer: BZ.Product.completer,
    }
);

// Commands
group.commands.add(
    BZ.build_spec(BZ.CMD_NEW_BUG),
    'Enter a new bug',
    function (args) {
        let prod = args[BZ.ARG_PRODUCT] || options[BZ.OPT_PRODUCT];
        let params = {
            'product': prod,
        }
        BZ.Action.do_action('enter', params, args.bang);
    }, {
        argCount: '?',
        bang: true,
        options: [
            {
                names: BZ.build_spec(BZ.ARG_PRODUCT),
                description: 'The product the bug is filed against',
                type: CommandOption.STRING,
                // completer: BZ.Product.completer,
            },
        ],
    }
);

group.commands.add(
    BZ.build_spec(BZ.CMD_GET_QUERIES),
    'Get a list of saved queries for the logged in user',
    function (args) {
        let queries = { };
        let clip = [ '" Created by the ' + BZ.CMD_GET_QUERIES + ' command' ];
        let named = content.window.document.querySelectorAll('a[href*="namedcmd="]');
        // For some reason, removing the ".*"s and using the global flag
        // doesn't work.
        let regex = /.*sharer_id=(\d+).*/;

        // Add each link to the list of saved queries, overwriting the current
        // list. Create a sequence of commands for adding those queries to
        // a .penta file, and push it to the clipboard.
        for (let i = 0; i < named.length; ++i) {
            // The inner text can contain &nbsp; elements
            let name = named.item(i).text.replace(/ /g, ' ');
            let author = regex.exec(named.item(i).href);
            author = author ? author[1] : null;
            let sharearg = author ? (' ' + BZ.ARG_AUTHOR + ' ' + author) : '';
            clip.push(BZ.CMD_ADD_QUERY + ' ' + BZ.ARG_QUERY_NAME + " '" + name + "'" + sharearg);
            queries[name] = author;
        }
        clip.push('');
        BZ.Query.query = queries;
        dactyl.clipboardWrite(clip.join("\r\n"), true);
    }, {
        argCount: '0',
    }
);

group.commands.add(
    BZ.build_spec(BZ.CMD_ADD_QUERY),
    'Remember the name of a Bugzilla saved query',
    function(args) {
        let author = args[BZ.ARG_AUTHOR] || null;
        BZ.Query.query[args[BZ.ARG_QUERY_NAME]] = author;
    }, {
        argCount: '0',
        options: [
            {
                names: BZ.build_spec(BZ.ARG_QUERY_NAME),
                description: 'The name of the saved Bugzilla query',
                type: CommandOption.STRING,
                completer: BZ.Query.completer,
            },
            {
                names: BZ.build_spec(BZ.ARG_AUTHOR),
                description: 'For shared queries, the "sharer_id" of the query author',
                type: CommandOption.STRING,
            },
        ],
    }
);

group.commands.add(
    BZ.build_spec(BZ.CMD_SEARCH_BUGS),
    'Visit a bug or the search page, or run a saved query',
    function(args) {
        let bug_id = (args.length) ? args[0] : args[BZ.ARG_BUG_ID];
        let query = args[BZ.ARG_QUERY_NAME];
        let action = 'search';
        let params = { };

        if (bug_id) {
            // If we got a bug ID, build the show_bug URL
            action = 'show_bug';
            params = { 'id': bug_id, };
        } else if (query) {
            // A query could be ours, or shared
            action = 'query';
            params = { 'namedcmd': query, };
            let sharer = BZ.Query.query[query];
            if (sharer) {
                params['cmdtype'] = 'dorem';
                params['remaction'] = 'run';
                params['sharer_id'] = sharer;
            } else {
                params['cmdtype'] = 'runnamed';
            }
        }
        BZ.Action.do_action(action, params, args.bang);
    }, {
        argCount: '?',
        bang: true,
        options: [
            {
                names: BZ.build_spec(BZ.ARG_BUG_ID),
                description: 'The ID of the Bugzilla ticket',
                type: CommandOption.INT,
            },
            {
                names: BZ.build_spec(BZ.ARG_QUERY_NAME),
                description: 'The name of the saved Bugzilla query',
                type: CommandOption.STRING,
                completer: BZ.Query.completer,
            },
        ],
    }
);

