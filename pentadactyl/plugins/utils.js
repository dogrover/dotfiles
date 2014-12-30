function bangtab(url, bang) {
    commands.execute((bang ? 'open': 'tabnew') + ' ' + url)
}

function bangcmd(cmd, desc, url) {
    commands.execute('command! ' + cmd + ' -bang -description "' + desc + '" -js plugins.utils.bangtab("' + url + '", bang)')
}
