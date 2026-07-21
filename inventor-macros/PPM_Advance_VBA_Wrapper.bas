' VBA macro (NOT an iLogic rule) -- paste into Inventor's VBA Editor.
' Confirmed real syntax, converged independently across three separate
' Autodesk Community forum threads (same GUID, same method signature
' each time), plus Autodesk's own APS devblog confirming the GUID.
'
' PURPOSE: sidesteps the Global Form reopen problem (D-672/OQ-215)
' entirely. Instead of a floating form window that has to survive
' repeated document closes, this is a keyboard shortcut assigned
' directly to a VBA macro -- nothing to tear down, so the E_FAIL issue
' from ShowGlobal can't occur here.
'
' SETUP:
'   1. In Inventor: Tools tab -> Macro panel -> Visual Basic Editor
'      (or Alt+F11).
'   2. In the VBA Editor: right-click your project in the tree on the
'      left -> Insert -> Module.
'   3. Paste this entire block into the new module.
'   4. Save (Ctrl+S), close the VBA Editor.
'   5. Back in Inventor: Tools tab -> Customize -> Keyboard tab.
'   6. In Categories, look for "Macros" (not "Add-Ins" -- that's for
'      the 2023.2+ direct-rule shortcuts we don't have). Find
'      "PPM_Advance" in the list.
'   7. Click in the Keys field, press your desired shortcut (e.g.
'      Ctrl+Shift+N for "Next"), click Assign, then OK.
'   8. Test: open any document, make it active, press the shortcut --
'      it should run PPM_TestAdvanceOneStep exactly as if you'd clicked
'      the Global Form button, but with no form involved at all.

' EDIT THIS if you rename the external rule:
Public Sub PPM_Advance()
    RuniLogic "PPM_TestAdvanceOneStep"
End Sub

Public Sub RuniLogic(ByVal RuleName As String)
    Dim iLogicAuto As Object
    Dim oDoc As Document
    Set oDoc = ThisApplication.ActiveDocument
    If oDoc Is Nothing Then
        MsgBox "Missing Inventor Document"
        Exit Sub
    End If
    Set iLogicAuto = GetiLogicAddin(ThisApplication)
    If (iLogicAuto Is Nothing) Then
        MsgBox "Could not find the iLogic add-in -- is it loaded?"
        Exit Sub
    End If
    iLogicAuto.RunExternalRule oDoc, RuleName
End Sub

Function GetiLogicAddin(oApplication As Inventor.Application) As Object
    Dim addIns As ApplicationAddIns
    Set addIns = oApplication.ApplicationAddIns
    Dim addIn As ApplicationAddIn
    Dim customAddIn As ApplicationAddIn
    For Each addIn In addIns
        If (addIn.ClassIdString = "{3BDD8D79-2179-4B11-8A5A-257B1C0263AC}") Then
            Set customAddIn = addIn
            Exit For
        End If
    Next
    If Not customAddIn Is Nothing Then
        If Not customAddIn.Activated Then customAddIn.Activate
        Set GetiLogicAddin = customAddIn.Automation
    End If
End Function
