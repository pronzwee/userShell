pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick

Singleton {
   id: root

   property bool locked: false
   property bool authentication: pam.active
   property bool authFailed: false
   property string pendingPassword: ""

   PamContext {
      id: pam
      config: "quickshell"
      onCompleted: (result) => {
         if (result === PamResult.Success) {
            root.unlock()
         } else {
            root.authFailed = true
         }
      }
      onError: (error) => {
         root.authFailed = true
      }
      onPamMessage: {
         if (pam.responseRequired) {
            pam.respond(root.pendingPassword)
            root.pendingPassword = ""
         }
      }
   }   
   function lock() {
      if (root.locked) return
      authFailed = false
      root.locked = true
   }
   
   function unlock() {
      authFailed = false
      root.locked = false
   }
   
   function authenticate(password) {
      if (pam.active) return
      authFailed = false
      pendingPassword = password
      pam.start()
   }
   
   IpcHandler {
      target: "lockscreen"
      function lock(): void { root.lock() }
      function isLocked(): bool { return root.locked }
   }
}
