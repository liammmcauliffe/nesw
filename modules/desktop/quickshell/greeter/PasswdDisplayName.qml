pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.Greetd
import qs.common

Item {
    id: root

    visible: false

    property string username: Greetd.user || Session.defaultUser
    property string displayName: root.username

    function parsePasswd(text): string {
        const user = root.username;
        if (!user)
            return "";
        if (!text)
            return user;

        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (!line || line.startsWith("#"))
                continue;

            const fields = line.split(":");
            if (fields.length < 5 || fields[0] !== user)
                continue;

            const gecos = fields[4].trim();
            if (!gecos)
                return user;

            const comma = gecos.indexOf(",");
            const name = (comma >= 0 ? gecos.slice(0, comma) : gecos).trim();
            return name || user;
        }

        return user;
    }

    function refresh(): void {
        root.displayName = root.parsePasswd(passwdFile.text());
    }

    FileView {
        id: passwdFile
        path: "/etc/passwd"
        watchChanges: true
        printErrors: false
        onLoaded: root.refresh()
    }

    onUsernameChanged: {
        if (passwdFile.path)
            root.refresh();
    }
}
