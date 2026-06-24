import Quickshell

ShellRoot {
    GreeterAuth {
        id: auth
    }

    GreeterScreen {
        auth: auth
    }
}
