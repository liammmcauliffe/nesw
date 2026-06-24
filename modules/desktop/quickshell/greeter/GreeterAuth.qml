pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Greetd
import qs.common

QtObject {
    id: root

    property string password: ""
    property string statusText: ""

    signal passwordRejected()

    function submit(): void {
        if (!Greetd.available) {
            statusText = "greetd unavailable";
            return;
        }

        statusText = "";
        Greetd.createSession(Session.defaultUser);
    }

    function clearPassword(): void {
        password = "";
        passwordRejected();
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse): void {
            if (error)
                root.statusText = message;
            if (responseRequired)
                Greetd.respond(root.password);
        }

        function onAuthFailure(message): void {
            root.statusText = message;
            root.clearPassword();
        }

        function onReadyToLaunch(): void {
            Greetd.launch([Session.sessionCommand]);
        }

        function onError(error): void {
            root.statusText = error;
        }
    }
}
