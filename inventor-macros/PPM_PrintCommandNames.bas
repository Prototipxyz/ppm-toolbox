' VBA macro (NOT an iLogic rule) -- paste into the same VBA module as
' PPM_Advance_VBA_Wrapper, or a new module, doesn't matter which.
'
' Confirmed real source: Autodesk's own official Developer Blog
' ("Running Commands Using the API"), which describes this exact
' technique for finding command internal names.
'
' PURPOSE: exploring whether ControlDefinition.Execute() can close a
' document THROUGH THE SAME PATHWAY as clicking the native X -- since
' manual closing is confirmed to preserve the Global Form, but calling
' Document.Close() directly does not. Execute() might behave like a
' real click and also preserve the form. Need the exact real internal
' command name for "Close" first, rather than guessing at it.
'
' This macro doesn't test anything about our actual problem yet -- it
' just dumps ALL command names to a text file so we can find the right
' one to try next.
'
' HOW TO RUN:
'   1. Paste this into the VBA Editor (Alt+F11), in a module (the same
'      one as PPM_Advance_VBA_Wrapper is fine, or a new one).
'   2. Place your cursor anywhere inside this Sub, press F5 (or the Run
'      button) to run it.
'   3. It creates C:\Temp\PPM_CommandNames.txt (creates the C:\Temp
'      folder first if it doesn't already exist).
'   4. Open that file in Notepad, press Ctrl+F, search for "close"
'      (case doesn't matter).
'   5. Send me every matching line -- there will likely be several
'      (e.g. one for "Close", one for "Close All", one for "Close
'      Window") -- send all of them so we can pick the right one.

Public Sub PPM_PrintCommandNames()
    ' Create C:\Temp if it doesn't already exist.
    If Dir("C:\Temp", vbDirectory) = "" Then
        MkDir "C:\Temp"
    End If

    Dim oCommandMgr As CommandManager
    Set oCommandMgr = ThisApplication.CommandManager

    Dim oFileNum As Integer
    oFileNum = FreeFile
    Open "C:\Temp\PPM_CommandNames.txt" For Output As #oFileNum

    Dim oControlDef As ControlDefinition
    For Each oControlDef In oCommandMgr.ControlDefinitions
        Print #oFileNum, oControlDef.InternalName & " -- " & oControlDef.DisplayName
    Next

    Close #oFileNum

    MsgBox "Done. Wrote command list to C:\Temp\PPM_CommandNames.txt" & vbCrLf & _
        "Open it and search for 'close'."
End Sub
