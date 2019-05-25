#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         Luuuuuis

#ce ----------------------------------------------------------------------------

#include <json.au3>
#include <Misc.au3>

FileCreateShortcut(@ScriptFullPath, @StartupDir & "\PasteClient.lnk")

If _Singleton(@ScriptName, 1) = 0 Then
   TrayTip(@ScriptName & " is already running", "Stop all other applications", 3, 2)
   Exit
EndIf

ConsoleWrite("PasteClient by @realluuuuuis started!" & @LF)


HotKeySet("!u", "_KeyPressed")


While 1
   Sleep(1000)
WEnd

Func _KeyPressed()
   ; Wurde gedrückt

   $Clip = ClipGet()
   If @error Then
	  ConsoleWrite("ERROR!" & @error)
   EndIf


   if StringLeft($Clip, 24) = "https://haste.luis.team/" Then
	  ; open haste
	  ShellExecute($Clip)
   Else
	  _Upload($Clip)
   EndIf


EndFunc


Func _Upload($Clip)

   $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
   $oHTTP.Open("POST", "https://haste.luis.team/documents", False)
   $oHTTP.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5")
   $oHTTP.Send($Clip)
   $response = $oHTTP.ResponseText

   ConsoleWrite($oHTTP.Status & @LF)

   Switch $oHTTP.Status
	  Case 400
		 TrayTip("Error while uploading!", "400 Bad Request", 3, 2)
		 Exit
	  Case 413
		 TrayTip("Error while uploading!", "413 Payload Too Large", 3, 2)
		 Exit
	  Case 500
		 TrayTip("Error while uploading!", "500 Internal Server Error", 3, 2)
		 Exit
   EndSwitch

   $object = json_decode($response) ; {"key":"123","deleteSecret":"123"}
   $key = json_get($object, '["key"]')
   $delete = json_get($object, '["deleteSecret"]')
   ConsoleWrite("key = " & $key & @LF)
   ConsoleWrite("deleteSecret = " & $delete & @LF)

   ClipPut("https://haste.luis.team/" & $key)

   TrayTip("Erfolgreich hochgeladen!", "The link was copied into the clipboard. Press Alt+U to open it in your browser.", 3, 1)

EndFunc