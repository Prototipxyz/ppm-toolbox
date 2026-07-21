' Add this Sub to the SAME VBA module as PPM_Advance (below
' GetiLogicAddin is fine, same as before). It reuses the existing
' RuniLogic and GetiLogicAddin helpers already pasted in -- no need to
' duplicate them.

Public Sub PPM_TestExecuteCloseTrigger()
    RuniLogic "PPM_TestExecuteClose"
End Sub
